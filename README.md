# Tic Tac Toe – Flutter

A 3×3 tic-tac-toe game, playable:

- **Online (1v1)** through **Cloud Firestore**, by sharing a game link
- **Locally (1v1)** on the same device
- **Solo against an AI** that wins when it can, blocks when it must, and otherwise prefers the center, then corners

---

## Getting started

The Flutter version is pinned in [`mise.toml`](mise.toml) (**3.41.1**). With [mise](https://mise.jdx.dev): `mise install`; otherwise install that version by any other means.

```bash
flutter pub get
flutter run
```

The app runs right after a clone: **local and AI games need no setup**. Without Firebase options, the online mode stays visible but tells the player it is unavailable.

### Enabling the online mode

1. Create a Firebase project with Firestore enabled, and register the Android and/or Apple apps.
2. Copy [`firebase_options.example.json`](firebase_options.example.json) to `firebase_options.json` (git-ignored) and fill it with the values of each app (Firebase console → Project settings → Your apps).
3. Deploy the security rules: `firebase deploy --only firestore:rules`.
4. Run with the options:

   ```bash
   flutter run --dart-define-from-file=firebase_options.json
   ```

Only Android, iOS and macOS read these options; other platforms run offline.

---

## Architecture

Feature-first, each feature split into layers:

```text
lib/
 ├─ main.dart               # Firebase (optional), error handlers, ProviderContainer
 ├─ app.dart                # MaterialApp, themes, i18n, router
 ├─ shared/                 # bootstrap, Firebase environment, routing, notifications, errors
 ├─ design_system/          # foundations (theme, dimensions, typography) and components
 └─ features/game/
     ├─ home/               # game mode selection
     ├─ creation/           # create / join dialogs
     └─ board/
         ├─ domain/         # Game model, GameRules, TicTacToeAI, repository interface — pure Dart
         ├─ data/           # Firestore and in-memory repositories, Firestore commands
         ├─ application/    # GameNotifier (Riverpod)
         └─ presentation/   # board screen
```

- **`GameRules`** is the single source of truth for moves and rounds: win detection in constant time (row, column and diagonal counters), turn order, scores, next round starter. Both repositories apply it.
- **`GameRepositoryInterface`** has two implementations: `GameRepository` (Firestore, every write in a transaction that re-reads the game) and `GameLocalRepository` (in memory, also drives the AI).
- **`GameNotifier`** creates or joins the game and streams it (Riverpod owns the subscription), and serializes the player actions. A refused move says why (not your turn, cell taken, round over…); any other failure is logged and shown as a "please retry" message. An unknown or deleted game ends the stream in a `GameNotFoundException`, shown as a blocking error.

### Online data model

- `games/{gameId}`: players (`fromId` plays X, `toId` plays O), status, board counters, scores, current round and player.
- `games/{gameId}/moves/{round}:{cell}`: one document per move; its id makes a cell impossible to play twice in a round.

[`firestore.rules`](firestore.rules) only allow a game to be joined once, a move to be created by the player whose turn it is, never edited or deleted, and to advance the game by exactly one turn; identities never change and a score only grows by the round just won.

**Known limitation:** players are identified by the name they type, not by an account. The rules prevent taking over a game or rewriting its history, but a modified client could still play the opponent's turn. Closing that gap requires Firebase Authentication (anonymous sign-in is enough) and rules based on `request.auth.uid`.

---

## Stack

- **flutter_riverpod / riverpod_annotation** (+ `riverpod_lint`) for state management and DI
- **auto_route** for typed navigation
- **freezed** + **json_serializable** for the immutable domain model
- **Firebase Core** + **Cloud Firestore** for the online mode
- **intl** + ARB files for i18n (English, French)
- **google_fonts** (Raleway, bundled in `assets/google_fonts`)

---

## Development

```bash
# Generated code (freezed, json, riverpod, auto_route)
dart run build_runner build --delete-conflicting-outputs

# Translations: edit lib/l10n/intl_*.arb; the Flutter Intl IDE plugin regenerates lib/generated

# Static analysis, including riverpod_lint
flutter analyze
dart run custom_lint
```

---

## Tests

```bash
flutter test                                   # everything
flutter test --exclude-tags golden             # without goldens
flutter test --tags golden --update-goldens    # regenerate goldens after an intended visual change
```

- **Unit tests** cover the rules, the AI, both repositories (Firestore through `fake_cloud_firestore`) and the game mode selection.
- **Widget tests** drive the board screen through a robot (`_GameBoardScreenRobot`): scenarios read as player actions and selectors live in one place. Online scenarios play the opponent through a second `GameRepository` on the same fake database.
- **Goldens** ([Alchemist](https://pub.dev/packages/alchemist)) render each board state in dark, light, large text and semantics views, with the real fonts. Text rasterization differs slightly between OSes: regenerate them on macOS.

Coverage, without generated files (requires `lcov`):

```bash
flutter test --coverage
lcov --remove coverage/lcov.info '**/*.g.dart' '**/*.freezed.dart' '**/*.gr.dart' 'lib/generated/**' -o coverage/lcov.info
genhtml coverage/lcov.info -o coverage
```
