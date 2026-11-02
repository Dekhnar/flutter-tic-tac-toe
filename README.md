# Tic Tac Toe – Flutter

A 3×3 tic-tac-toe game, playable:

- **Online (1v1)** between two devices through **Cloud Firestore**, by sharing a six-character game code
- **Locally (1v1)** on the same device
- **Solo against an AI** that never loses: it searches the whole game tree (minimax with alpha-beta pruning)

---

## Getting started

The Flutter version is pinned in [`mise.toml`](mise.toml) (**3.41.1**). With [mise](https://mise.jdx.dev): `mise install`; otherwise install that version by any other means.

```bash
flutter pub get
flutter run
```

The app runs right after a clone: **local and AI games need no setup**. Without Firebase, the online mode stays visible but tells the player it is unavailable.

### Online mode on the local emulators

No Firebase project is needed to play online on a development machine: the [Firebase emulators](https://firebase.google.com/docs/emulator-suite) run Auth and Firestore locally, with the project's security rules.

```bash
# Java 21 and the Firebase CLI (npx firebase-tools@13 works too)
firebase emulators:start --only auth,firestore --project demo-tic-tac-toe

flutter run --dart-define-from-file=firebase_emulator.json
```

Run the app on two simulators or emulators to play against yourself. The Android emulator reaches the host's emulators at `10.0.2.2`; the app maps `localhost` to it.

### Online mode on a Firebase project

1. Create a Firebase project, enable **Firestore** and the **Anonymous** sign-in provider, and register the Android and/or Apple apps: both use the identifier `io.github.dekhnar.tictactoe`.
2. Copy [`firebase_options.example.json`](firebase_options.example.json) to `firebase_options.json` (git-ignored) and fill it with the values of each app (Firebase console → Project settings → Your apps).
3. Deploy the security rules: `firebase deploy --only firestore:rules`.
4. Let Firestore delete games 30 days after their creation, with a [TTL policy](https://firebase.google.com/docs/firestore/ttl) on `expiresAt`:
   ```bash
   gcloud firestore fields ttls update expiresAt --collection-group=games --enable-ttl
   ```
5. Run with the options: `flutter run --dart-define-from-file=firebase_options.json`.

On a real project (never on the emulators), the app also turns on:

- **Crashlytics**, collecting from release builds only; nothing is collected before the app enables it. Android does not upload the R8 mapping, which needs `google-services.json`: enable `mappingFileUploadEnabled` in `android/app/build.gradle.kts` once the project has one. For symbolicated iOS reports, add Crashlytics' dSYM upload script to the Runner build phases.
- **App Check**, with Play Integrity on Android and App Attest (DeviceCheck as a fallback) on Apple platforms; debug builds use the debug providers, whose token the console must allow. Register the apps in App Check, then turn on enforcement for Firestore and Auth.

### Release builds

Android signs release builds with the upload key that `android/key.properties` (git-ignored) describes:

```properties
storeFile=/absolute/path/to/upload-keystore.jks
storePassword=…
keyAlias=upload
keyPassword=…
```

Without that file, Gradle warns and signs with the debug key, so that `flutter run --release` still works on a developer machine. Apple platforms sign with the team set in Xcode.

Only Android, iOS and macOS read the Firebase options; other platforms run offline. **macOS:** Firebase Auth stores its session in the keychain, which needs the *Keychain Sharing* capability, and so a development team: enable it in Xcode (Runner → Signing & Capabilities). Without it, signing in fails and the home screen asks to retry.

---

## Architecture

Feature-first, each feature split into layers:

```text
lib/
 ├─ main.dart               # error handlers, then runs the app
 ├─ composition.dart        # startup (Firebase, Crashlytics, App Check) and the implementation behind each contract
 ├─ app.dart                # MaterialApp, themes, i18n, router
 ├─ shared/                 # Firebase environment, routing, error logging
 ├─ design_system/          # foundations (theme, dimensions, typography) and components
 └─ features/game/
     ├─ domain/             # Game, Player, Board, Cell, GameRules, TicTacToeAI, GameException, repository contracts
     ├─ data/               # Firestore and in-memory repositories, the Firestore game document, anonymous identity
     ├─ application/        # GameSession and its rules, GameSessionStarter, the game and the actions on it, the AI
     └─ presentation/       # the message for each refusal, then one folder per screen:
         ├─ home/           #   game mode selection: creates or joins the game, then opens the board
         ├─ creation/       #   create / join dialogs, the player name field
         └─ board/          #   board screen: header, grid, round actions; portrait and landscape
```

- **`GameRules`** is the single source of truth for every change a game goes through — joining, starting, a move, the next round, leaving — on a `Game` that only holds game concepts (players, board, scores, round). A refusal throws the `GameException` that says why. Both repositories only store what it returns, and the security rules check the same rules on the server.
- **One composition root.** The domain is plain Dart: it declares the repositories and the player identity as interfaces, which the application exposes as providers that throw until bound (`game_dependencies.dart`). [`composition.dart`](lib/composition.dart) starts what the app needs before its first frame and binds every contract — the online ones only when Firebase is initialized — and the one `ErrorLogger` the error handlers and the provider observer share (Crashlytics on a real project). Nothing else imports an implementation.
- **The home screen starts a `GameSession`** through `GameSessionStarter`: it creates the local game, or signs in anonymously and creates or joins the online one. The home notifier is loading meanwhile (a barrier covers the modes) and holds the error when it fails (unknown code, game already full), which the screen shows.
- **On the board, `gameProvider` only watches the game** and **`GameActions` acts on it**: loading while the repository handles a move, a start or a new round — the board takes no other action meanwhile — and the error when it refused, shown as a message.
- **The AI is a player of the application layer**: `aiOpponentProvider` watches the game and, on the AI's turn, plays the move `TicTacToeAI` picks through `GameActions`, after a thinking time. It stops when the board closes. Which seat the AI plays belongs to the `GameSession`, not to the game.
- **Leaving the board leaves the game**, however the player goes back: a local game is forgotten, and the opponent of an online one sees it abandoned — so the board asks first while an opponent is seated. Leaving is an explicit action (`GameActions.leave`), never a side effect of a provider being disposed. A device that is killed or loses its network does not leave: that would take a presence heartbeat.
- **Repositories** implement `LocalGameRepository` (in memory) and `OnlineGameRepository` (Firestore) and only store. Every online write applies `GameRules` to the game read in a transaction.
- **Players** sit in a game's two seats, host (X) and guest (O): a `Player` is a `PlayerId` — the anonymous Firebase uid online, a fixed seat on a local game — with a name and a win count. The Firestore document stores the seats flat, as the rules read them.
- **Navigation:** screens are auto_route routes; dialogs are not, screens open them with `showDialog` and await their result.

### Online data model and security rules

One document per game, `games/{gameId}`: the game id is the code players share, six characters without the ones read alike (0/O, 1/I); the creation picks one no other game uses. It holds the players (`hostId` plays X, `guestId` plays O) and their names, the status, the scores, the current round and player, the board as nine cells (`'X'`, `'O'` or `''`), and what only the server needs: when it was written and `expiresAt`.

[`GameDocument`](lib/features/game/data/dto/game_document.dart) maps a `Game` to that document and back, and names every field once (`GameField`). Each write the app makes is a `GameWrite` listing the fields it changes — the same lists [`firestore.rules`](firestore.rules) allow, write by write — and the rules refuse anything else; a test reads `firestore.rules` to keep the two lists equal, and checks that the server pins every time a write carries. Games can be read with their code but never listed. Names count at most 20 UTF-16 code units, as the rules count them; so do the name field's counter and limit. A move must come from the signed-in player whose turn it is, and is checked against the board: exactly one empty cell takes the player's mark, the round ends only on a real line or a full board, and only the winner scores. The integration tests exercise these rules on the emulator, including a cheating client.

---

## Stack

- **Riverpod 3** (`flutter_riverpod`, `riverpod_annotation`, `riverpod_lint`) for state management and DI
- **auto_route** for typed navigation
- **freezed** for the immutable domain model
- **Firebase Auth** (anonymous) + **Cloud Firestore** for the online mode, **Crashlytics** and **App Check** on a real project
- **share_plus** to send the game code
- **gen-l10n** + ARB files for i18n (English, French); theme and language follow the device
- **google_fonts** (Raleway, bundled in `assets/google_fonts`)

---

## Development

```bash
# Generated code (freezed, riverpod, auto_route)
dart run build_runner build

# Translations: edit lib/l10n/intl_*.arb (intl_en.arb declares the placeholders), then
flutter gen-l10n   # also run by flutter pub get, run and build; writes lib/generated

# Static analysis: strict casts, inference and raw types, plus riverpod_lint
flutter analyze
dart run custom_lint
```

---

## Tests

```bash
flutter test                                   # unit, widget and golden tests
flutter test --exclude-tags golden             # without goldens
flutter test --tags golden --update-goldens    # regenerate goldens after an intended visual change

# End-to-end on a simulator or emulator, with the Firebase emulators running (see above)
flutter test integration_test --dart-define-from-file=firebase_emulator.json
```

- **Unit tests** cover the rules, the AI (every game a player can play against it, none won) and its timing (in fake time), both repositories (Firestore through `fake_cloud_firestore`), the anonymous identity, the composition, starting a session, the game mode selection, and the agreement between the app's writes and `firestore.rules`.
- **Widget tests** drive the screens through robots: scenarios read as player actions and selectors live in one place. The home screen runs inside the real app and router, from the mode to the board. Online scenarios play the opponent through a second `FirestoreGameRepository` on the same fake database.
- **Goldens** ([Alchemist](https://pub.dev/packages/alchemist)) render each board state and the game modes in dark, light, large text and semantics views, with the real fonts. Text rasterization differs slightly between OSes: regenerate them on macOS. Each golden scenario, the home screen and its dialogs are also checked against the accessibility guidelines in both themes: labelled tap targets of the minimum size on Android and iOS, and text contrast.
- **Integration tests** run the real app on a device against the emulators: local and AI games, a full online round against a second device, join errors, and the security rules refusing a cheating client (listing games, a game with extra fields or no expiry, taking a seat, a name too long, leaving a game one does not play, a forged time, playing out of turn, a fake victory, marking the opponent's cell, an inflated score, a deletion), and two players asking for the same change at once. Without the emulators, the online ones are skipped.

Coverage, without generated files (requires `lcov`):

```bash
flutter test --coverage
lcov --remove coverage/lcov.info '**/*.g.dart' '**/*.freezed.dart' '**/*.gr.dart' 'lib/generated/**' -o coverage/lcov.info
genhtml coverage/lcov.info -o coverage
```
