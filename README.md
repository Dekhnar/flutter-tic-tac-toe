# Tic Tac Toe – Flutter

A 3×3 tic-tac-toe game, playable:

- **Online (1v1)** between two devices through **Cloud Firestore**, by sharing a game code
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

1. Create a Firebase project, enable **Firestore** and the **Anonymous** sign-in provider, and register the Android and/or Apple apps.
2. Copy [`firebase_options.example.json`](firebase_options.example.json) to `firebase_options.json` (git-ignored) and fill it with the values of each app (Firebase console → Project settings → Your apps).
3. Deploy the security rules: `firebase deploy --only firestore:rules`.
4. Let Firestore delete games 30 days after their creation, with a [TTL policy](https://firebase.google.com/docs/firestore/ttl) on `expiresAt` for the `games` collection and the `moves` collection group:
   ```bash
   gcloud firestore fields ttls update expiresAt --collection-group=games --enable-ttl
   gcloud firestore fields ttls update expiresAt --collection-group=moves --enable-ttl
   ```
5. Run with the options: `flutter run --dart-define-from-file=firebase_options.json`.

Only Android, iOS and macOS read these options; other platforms run offline. **macOS:** Firebase Auth stores its session in the keychain, which needs the *Keychain Sharing* capability, and so a development team: enable it in Xcode (Runner → Signing & Capabilities). Without it, signing in fails and the home screen asks to retry.

---

## Architecture

Feature-first, each feature split into layers:

```text
lib/
 ├─ main.dart               # Firebase (optional), error handlers, ProviderContainer
 ├─ composition.dart        # binds the domain contracts to their implementations
 ├─ app.dart                # MaterialApp, themes, i18n, router
 ├─ shared/                 # Firebase environment, routing, error logging
 ├─ design_system/          # foundations (theme, dimensions, typography) and components
 └─ features/game/
     ├─ home/               # game mode selection: creates or joins the game, then opens the board
     ├─ creation/           # create / join dialogs
     └─ board/
         ├─ domain/         # Game, GameRules, TicTacToeAI, GameException, repository and identity contracts
         ├─ data/           # Firestore and in-memory repositories, Firestore commands, anonymous Firebase identity
         ├─ application/    # GameSession, GameSessionStarter, the game and the actions on it (Riverpod)
         └─ presentation/   # board screen, error messages
```

- **`GameRules`** is the single source of truth for moves and rounds: win detection in constant time (row, column and diagonal counters), turn order, scores, next round starter. A refused move throws the `GameException` that says why. Both repositories apply it.
- **Contracts, bound in one place.** The domain declares the repositories and the player identity as providers that throw until bound (`game_providers.dart`); [`composition.dart`](lib/composition.dart) binds them, the online ones only when Firebase is initialized. Nothing else imports an implementation.
- **The home screen starts a `GameSession`** through `GameSessionStarter`: it creates the local game, or signs in anonymously and creates or joins the online one. The home notifier is loading meanwhile (a barrier covers the modes) and holds the error when it fails (unknown code, game already full), which the screen shows.
- **On the board, `gameProvider` only watches the game** and **`GameActions` acts on it**: loading while the repository handles a move, a start or a new round — the board takes no other action meanwhile — and the error when it refused, shown as a message. A local game lives as long as its board: closing the board forgets it.
- **Repositories** implement `LocalGameRepositoryInterface` (in memory, drives the AI) and `OnlineGameRepositoryInterface` (Firestore). Every online write runs in a transaction that re-reads the game, and the game stream only emits once the game and its moves describe the same turn.
- **Players** are `PlayerId`s — the anonymous Firebase uid online, a fixed seat on a local game — and their names are stored apart from their ids.

### Online data model and security rules

- `games/{gameId}`: the game id is the code players share. Players (`fromId` plays X, `toId` plays O) and their names, status, board counters, scores, current round and player, and `expiresAt`.
- `games/{gameId}/moves/{round}:{cell}`: one document per move; its id makes a cell impossible to play twice in a round. A move expires with its game.

The board is stored twice on purpose: the **moves** are what players see, the **counters** (`boardState`) are what the rules check — rules cannot loop over a collection, so the counters let them validate a move and its outcome in constant time.

[`firestore.rules`](firestore.rules) describe every write the app makes — create, join, start, move, new round — with the exact fields each one may write, and refuse anything else. Games can be read with their code but never listed. A move must come from the signed-in player whose turn it is, and is checked against the board: the counters move by exactly the played cell, the round ends only on a real line or a full board, and only the winner scores. The integration tests exercise these rules on the emulator, including a cheating client.

---

## Stack

- **Riverpod 3** (`flutter_riverpod`, `riverpod_annotation`, `riverpod_lint`) for state management and DI
- **auto_route** for typed navigation
- **freezed** + **json_serializable** for the immutable domain model
- **Firebase Auth** (anonymous) + **Cloud Firestore** for the online mode
- **intl** + ARB files for i18n (English, French); theme and language follow the device
- **google_fonts** (Raleway, bundled in `assets/google_fonts`)

---

## Development

```bash
# Generated code (freezed, json, riverpod, auto_route)
dart run build_runner build

# Translations: edit lib/l10n/intl_*.arb; the Flutter Intl IDE plugin regenerates lib/generated

# Static analysis, including riverpod_lint
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

- **Unit tests** cover the rules, the AI (every game a player can play against it, none won), both repositories (Firestore through `fake_cloud_firestore`), starting a session and the game mode selection.
- **Widget tests** drive the screens through robots: scenarios read as player actions and selectors live in one place. The home screen runs inside the real app and router, from the mode to the board. Online scenarios play the opponent through a second `FirestoreGameRepository` on the same fake database.
- **Goldens** ([Alchemist](https://pub.dev/packages/alchemist)) render each board state in dark, light, large text and semantics views, with the real fonts. Text rasterization differs slightly between OSes: regenerate them on macOS.
- **Integration tests** run the real app on a device against the emulators: local and AI games, a full online round against a second device, join errors, and the security rules refusing a cheating client (listing games, a game with extra fields or no expiry, taking a seat, playing out of turn, a fake victory, an inflated score, a deletion). Without the emulators, the online ones are skipped.

Coverage, without generated files (requires `lcov`):

```bash
flutter test --coverage
lcov --remove coverage/lcov.info '**/*.g.dart' '**/*.freezed.dart' '**/*.gr.dart' 'lib/generated/**' -o coverage/lcov.info
genhtml coverage/lcov.info -o coverage
```
