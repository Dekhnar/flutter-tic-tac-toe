# Tic Tac Toe – Flutter

A 3×3 tic-tac-toe game, playable:

- **Online (1v1)** between two devices through **Cloud Firestore**: the host shares a six-character game code
- **Locally (1v1)** on the same device
- **Solo against an AI** that never loses: it searches the whole game tree (minimax with alpha-beta pruning)

---

## Getting started

The Flutter version is pinned in [`mise.toml`](mise.toml) (**3.41.1**). With [mise](https://mise.jdx.dev): `mise install`; otherwise install that version by any other means.

```bash
flutter pub get
flutter run
```

The app runs right after a clone: **local and AI games need no setup**. Without Firebase, the online mode stays visible but tells the player this build does not offer it.

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

- **Crashlytics**, collecting from release builds only. Android does not upload the R8 mapping, which needs `google-services.json`: enable `mappingFileUploadEnabled` in `android/app/build.gradle.kts` once the project has one. For symbolicated iOS reports, add Crashlytics' dSYM upload script to the Runner build phases.
- **App Check**: Play Integrity on Android, App Attest on Apple platforms (DeviceCheck where App Attest is not supported), the debug providers in debug builds (allow their token in the console). iOS release builds carry the App Attest entitlement ([`Runner.entitlements`](ios/Runner/Runner.entitlements)); enable *App Attest* for the App ID in the Apple developer account. Register the apps in App Check, and turn on enforcement for Firestore and Auth only once the console's App Check metrics show nearly all requests verified.

Each of these starts on its own, within 5 s: a failure leaves out only what depends on it, and is reported once the app knows where (through Crashlytics when it started). Online play stays on unless Firebase itself fails to start; the online mode then says it could not start.

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

```text
lib/
 ├─ main.dart               # error handlers, then runs the app
 ├─ composition.dart        # startup (Firebase, Crashlytics, App Check), and the implementation behind each contract
 ├─ app.dart                # MaterialApp, themes, i18n, router
 ├─ routing/                # the router, and the game's navigation implemented with it
 ├─ shared/                 # Firebase environment, errors and their logging
 ├─ design_system/          # foundations (theme, dimensions) and components
 └─ features/game/
     ├─ domain/             # Game, Board, GameCode, GameRules, TicTacToeAI, GameException, repository contracts
     ├─ data/               # Firestore and in-memory repositories, the Firestore game document, anonymous identity
     ├─ application/        # OnlinePlay, GameSession, GameSessionStarter, the game stream, the AI opponent
     └─ presentation/       # error messages, then one folder per screen, with the notifiers of its state:
         ├─ home/           #   game modes; starts the game (loading, cancel, time limit), then opens the board
         ├─ creation/       #   create / join dialogs, the player name field
         └─ board/          #   header, grid, round actions; the actions on the board (busy, error, time limit)
```

**Layers.** The domain is plain Dart. The application uses the domain only, and exposes each contract as a provider that throws until [`composition.dart`](lib/composition.dart) binds it. Presentation never imports the data layer, and a feature never imports the app around it (router, composition). Shared code imports no feature. [`architecture_test.dart`](test/architecture_test.dart) fails on an import that breaks one of these rules.

**Decisions**

- **`GameRules` is the only place a game changes**: join, start, move, next round, leave. A refusal throws the `GameException` that says why. A request already fulfilled, which happens when both players ask at once, returns `GameChange.alreadyDone()` and writes nothing. Both repositories store what the rules return, and `firestore.rules` enforce the same rules on the server.
- **`GameCode`** is the online game id: six characters without 0/O and 1/I. The join dialog checks a code on the device, and finds it in pasted text, such as the invitation the host shared.
- **`OnlinePlay`** is either available, with the repository and identity it needs, or unavailable, with the reason. No code reaches the online services otherwise.
- **State the screens show lives with them.** `GameSessionStartNotifier` (home) and `GameBoardActionsNotifier` (board) hold the loading and error states and run one action at a time. They stop waiting after 15 s and 10 s respectively, with `ServerNotAnsweringException`; so does the game stream when its first game takes over 10 s, and the board then offers to retry. A move ends only once the board shows the game it changed: online, that game comes on its own stream after the server's answer, so the board takes no other action until then, and `pendingMoveProvider` holds the cell of the move meanwhile. The application layer holds no UI state.
- **A move from this device is for `GameSession.playsFor`**: this device's player online, the player whose turn it is on a local game, never the AI. The board's notifier checks the game as it is when a tap arrives, and ignores any other move: two taps can land in the same frame.
- **A session that starts after the player stopped waiting opens no board.** A game created for it is left, since nobody else knows its code. A seat taken in someone else's game is kept: joining is idempotent, so the player's retry opens that game.
- **The AI** watches the game of a local session against it and, after a thinking time, plays the move `TicTacToeAI` picks through the repository. It stops when the board closes.
- **Leaving the board leaves the game**, however the player goes back. A local game is forgotten, and the opponent of an online one sees it abandoned, so the board asks first while an opponent is seated.
- **Navigation:** screens are auto_route routes, but they do not import the router. They go through `GameNavigation`, a contract of the feature that `lib/routing/` implements with the router and composition binds. Closing the board closes any dialog over it. Dialogs open with `showDialog` and close themselves with `Navigator.pop`.

**Errors.** `ExpectedException`s (refusals, the server not answering) are shown to the player and logged as breadcrumbs. Anything else is reported to Crashlytics. A write the server refuses outside the game's rules, such as an App Check failure or an outdated app, is a `ServerRefusedException`: it is reported, and the player is told the server refused the action.

**Known limits.** A device that is killed or loses its network does not leave its game. The board shows an opponent who has not played for a minute as inactive, and the player can leave; telling a closed app from a slow player would take a presence heartbeat (an RTDB `onDisconnect`, or a `lastSeen` field and a scheduled function). The strict field lists of the rules make every new document field a joint release of the app and the rules. Game creation is limited only by App Check.

### Online data model and security rules

One document per game, `games/{code}`. It holds the players (`hostId` plays X, `guestId` plays O) and their names, the status, the scores, the current round and player, and the board as nine cells (`'X'`, `'O'` or `''`). It also holds what only the server needs: `createdAt`, `updatedAt` and `expiresAt`.

[`GameDocument`](lib/features/game/data/dto/game_document.dart) maps a `Game` to that document and back, and names every field once (`GameField`). Each write is a `GameWrite` listing the fields it changes, the same list [`firestore.rules`](firestore.rules) allow for that write. A test reads the rules to keep both lists equal, and checks that the server sets every time a write carries.

The rules also enforce the following:
- games are created only under a code the app could draw, and read with it, never listed;
- names are at most 20 UTF-16 code units, as the app counts them;
- a move comes from the player whose turn it is, and is checked against the board: one empty cell takes the mark, the round ends only on a real line or a full board, and only the winner scores.

Every write runs in a transaction. The rules check a write against the game as it is when the write lands, so a transaction that read the game before the other player changed it fails with `permission-denied`, not a conflict Firestore would retry. The repository then runs it again while the game's `updatedAt` keeps changing in between, three times at most; the refusal of a game nobody changed stands.

---

## Stack

- **Riverpod 3** (`flutter_riverpod`, `riverpod_annotation`, `riverpod_lint`) for state management and DI
- **auto_route** for typed navigation
- **freezed** for the immutable domain model
- **Firebase Auth** (anonymous) + **Cloud Firestore** for the online mode, **Crashlytics** and **App Check** on a real project
- **share_plus** to send the game code
- **gen-l10n** + ARB files for i18n (English, French); theme and language follow the device
- **Raleway**, declared in `pubspec.yaml` (Regular only: the medium styles render in it too)

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

# Formatting (120 columns): hand-written files only, generated ones keep the generators' output
dart format $(git ls-files '*.dart' | grep -vE '\.(g|freezed|gr)\.dart$|^lib/generated/')
```

---

## Tests

```bash
flutter test                                   # unit, widget and golden tests
flutter test --exclude-tags golden             # without goldens
flutter test --tags golden --update-goldens    # regenerate goldens after an intended visual change, on macOS

# End-to-end on a simulator or emulator, with the Firebase emulators running (see above)
flutter test integration_test --dart-define-from-file=firebase_emulator.json
```

- **Unit tests** cover:
  - the rules, and `GameCode`, including reading it from the invitation in every language;
  - the AI (every game a player can play against it, none won) and its timing, in fake time;
  - both repositories (Firestore through `fake_cloud_firestore`, including refused and stale transactions), and the anonymous identity;
  - the Firebase environment, and startup with each Firebase step failing;
  - starting a session (cancelled, or given up after its time limit), and the actions on the board;
  - the layer rules (`architecture_test.dart`), and the agreement between the app's writes and `firestore.rules`. The rules are read by their braces and brackets, not their layout.
- **Widget tests** drive the screens through robots, so scenarios read as player actions:
  - the home screen runs inside the real app and router, from the mode to the board;
  - the board is laid out on a phone, a landscape phone, and windows barely wider than tall;
  - online scenarios play the opponent through a second `FirestoreGameRepository` on the same fake database.
- **Goldens** ([Alchemist](https://pub.dev/packages/alchemist)) render each board state and the game modes in dark, light, large-text and semantics views, in two sets:
  - `goldens/macos/` with the real fonts, checked on macOS only, since text rasterizes differently on each OS;
  - `goldens/ci/` with text drawn as boxes, the same on every OS.
- **Accessibility:** each golden scenario, the home screen and its dialogs are checked against the guidelines in both themes: labelled tap targets of the minimum size on Android and iOS, and text contrast.
- **Integration tests** run the real app on a device against the emulators (without them, the online ones are skipped):
  - local and AI games, a full online round against a second device, and join errors;
  - the security rules refusing a cheating client: listing games, a game with extra fields or no expiry, taking a seat, a name too long, leaving a game one does not play, a forged time, playing out of turn, a fake victory, marking the opponent's cell, an inflated score, and a deletion;
  - two players asking for the same change at once.

Coverage, without generated files (requires `lcov`):

```bash
flutter test --coverage
lcov --remove coverage/lcov.info '**/*.g.dart' '**/*.freezed.dart' '**/*.gr.dart' 'lib/generated/**' -o coverage/lcov.info
genhtml coverage/lcov.info -o coverage
```
