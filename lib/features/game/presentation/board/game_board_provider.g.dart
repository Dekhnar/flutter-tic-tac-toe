// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_board_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the player does on the board: loading until the board shows the action, then the error if it was refused or
/// failed. One action at a time, each given [timeLimit] to complete.

@ProviderFor(GameBoardActionsNotifier)
const gameBoardActionsProvider = GameBoardActionsNotifierFamily._();

/// What the player does on the board: loading until the board shows the action, then the error if it was refused or
/// failed. One action at a time, each given [timeLimit] to complete.
final class GameBoardActionsNotifierProvider
    extends $AsyncNotifierProvider<GameBoardActionsNotifier, void> {
  /// What the player does on the board: loading until the board shows the action, then the error if it was refused or
  /// failed. One action at a time, each given [timeLimit] to complete.
  const GameBoardActionsNotifierProvider._({
    required GameBoardActionsNotifierFamily super.from,
    required GameSession super.argument,
  }) : super(
         retry: null,
         name: r'gameBoardActionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$gameBoardActionsNotifierHash();

  @override
  String toString() {
    return r'gameBoardActionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GameBoardActionsNotifier create() => GameBoardActionsNotifier();

  @override
  bool operator ==(Object other) {
    return other is GameBoardActionsNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gameBoardActionsNotifierHash() =>
    r'2385a2f03b31c049a42f6a7db08f274581811547';

/// What the player does on the board: loading until the board shows the action, then the error if it was refused or
/// failed. One action at a time, each given [timeLimit] to complete.

final class GameBoardActionsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          GameBoardActionsNotifier,
          AsyncValue<void>,
          void,
          FutureOr<void>,
          GameSession
        > {
  const GameBoardActionsNotifierFamily._()
    : super(
        retry: null,
        name: r'gameBoardActionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What the player does on the board: loading until the board shows the action, then the error if it was refused or
  /// failed. One action at a time, each given [timeLimit] to complete.

  GameBoardActionsNotifierProvider call(GameSession session) =>
      GameBoardActionsNotifierProvider._(argument: session, from: this);

  @override
  String toString() => r'gameBoardActionsProvider';
}

/// What the player does on the board: loading until the board shows the action, then the error if it was refused or
/// failed. One action at a time, each given [timeLimit] to complete.

abstract class _$GameBoardActionsNotifier extends $AsyncNotifier<void> {
  late final _$args = ref.$arg as GameSession;
  GameSession get session => _$args;

  FutureOr<void> build(GameSession session);
  @$mustCallSuper
  @override
  void runBuild() {
    build(_$args);
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}

/// The cell of the move [GameBoardActionsNotifier] runs, for as long as it runs.

@ProviderFor(PendingMoveNotifier)
const pendingMoveProvider = PendingMoveNotifierFamily._();

/// The cell of the move [GameBoardActionsNotifier] runs, for as long as it runs.
final class PendingMoveNotifierProvider
    extends $NotifierProvider<PendingMoveNotifier, Cell?> {
  /// The cell of the move [GameBoardActionsNotifier] runs, for as long as it runs.
  const PendingMoveNotifierProvider._({
    required PendingMoveNotifierFamily super.from,
    required GameSession super.argument,
  }) : super(
         retry: null,
         name: r'pendingMoveProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pendingMoveNotifierHash();

  @override
  String toString() {
    return r'pendingMoveProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PendingMoveNotifier create() => PendingMoveNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Cell? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Cell?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PendingMoveNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pendingMoveNotifierHash() =>
    r'0bec565aad7c3ab1ae851fb9e29e90f6bd93665e';

/// The cell of the move [GameBoardActionsNotifier] runs, for as long as it runs.

final class PendingMoveNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          PendingMoveNotifier,
          Cell?,
          Cell?,
          Cell?,
          GameSession
        > {
  const PendingMoveNotifierFamily._()
    : super(
        retry: null,
        name: r'pendingMoveProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The cell of the move [GameBoardActionsNotifier] runs, for as long as it runs.

  PendingMoveNotifierProvider call(GameSession session) =>
      PendingMoveNotifierProvider._(argument: session, from: this);

  @override
  String toString() => r'pendingMoveProvider';
}

/// The cell of the move [GameBoardActionsNotifier] runs, for as long as it runs.

abstract class _$PendingMoveNotifier extends $Notifier<Cell?> {
  late final _$args = ref.$arg as GameSession;
  GameSession get session => _$args;

  Cell? build(GameSession session);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<Cell?, Cell?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Cell?, Cell?>,
              Cell?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Whether leaving ends the game the board last showed for an opponent. Before the first one shows, an opponent may sit
/// in an online game already; a game gone from the server ends for nobody.

@ProviderFor(leaveNeedsConfirmation)
const leaveNeedsConfirmationProvider = LeaveNeedsConfirmationFamily._();

/// Whether leaving ends the game the board last showed for an opponent. Before the first one shows, an opponent may sit
/// in an online game already; a game gone from the server ends for nobody.

final class LeaveNeedsConfirmationProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether leaving ends the game the board last showed for an opponent. Before the first one shows, an opponent may sit
  /// in an online game already; a game gone from the server ends for nobody.
  const LeaveNeedsConfirmationProvider._({
    required LeaveNeedsConfirmationFamily super.from,
    required GameSession super.argument,
  }) : super(
         retry: null,
         name: r'leaveNeedsConfirmationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$leaveNeedsConfirmationHash();

  @override
  String toString() {
    return r'leaveNeedsConfirmationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as GameSession;
    return leaveNeedsConfirmation(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LeaveNeedsConfirmationProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$leaveNeedsConfirmationHash() =>
    r'63a6e9b181bef62403dde64d3dd8c3f24b56451d';

/// Whether leaving ends the game the board last showed for an opponent. Before the first one shows, an opponent may sit
/// in an online game already; a game gone from the server ends for nobody.

final class LeaveNeedsConfirmationFamily extends $Family
    with $FunctionalFamilyOverride<bool, GameSession> {
  const LeaveNeedsConfirmationFamily._()
    : super(
        retry: null,
        name: r'leaveNeedsConfirmationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether leaving ends the game the board last showed for an opponent. Before the first one shows, an opponent may sit
  /// in an online game already; a game gone from the server ends for nobody.

  LeaveNeedsConfirmationProvider call(GameSession session) =>
      LeaveNeedsConfirmationProvider._(argument: session, from: this);

  @override
  String toString() => r'leaveNeedsConfirmationProvider';
}

/// Whether an online opponent has not played for [inactiveAfter] while it is their turn: their app may be closed or
/// offline. Any change of the game starts the wait again.

@ProviderFor(OpponentInactiveNotifier)
const opponentInactiveProvider = OpponentInactiveNotifierFamily._();

/// Whether an online opponent has not played for [inactiveAfter] while it is their turn: their app may be closed or
/// offline. Any change of the game starts the wait again.
final class OpponentInactiveNotifierProvider
    extends $NotifierProvider<OpponentInactiveNotifier, bool> {
  /// Whether an online opponent has not played for [inactiveAfter] while it is their turn: their app may be closed or
  /// offline. Any change of the game starts the wait again.
  const OpponentInactiveNotifierProvider._({
    required OpponentInactiveNotifierFamily super.from,
    required GameSession super.argument,
  }) : super(
         retry: null,
         name: r'opponentInactiveProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$opponentInactiveNotifierHash();

  @override
  String toString() {
    return r'opponentInactiveProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  OpponentInactiveNotifier create() => OpponentInactiveNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OpponentInactiveNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$opponentInactiveNotifierHash() =>
    r'db49d893213df49ce2592bb794e71f16989dfbd2';

/// Whether an online opponent has not played for [inactiveAfter] while it is their turn: their app may be closed or
/// offline. Any change of the game starts the wait again.

final class OpponentInactiveNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          OpponentInactiveNotifier,
          bool,
          bool,
          bool,
          GameSession
        > {
  const OpponentInactiveNotifierFamily._()
    : super(
        retry: null,
        name: r'opponentInactiveProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether an online opponent has not played for [inactiveAfter] while it is their turn: their app may be closed or
  /// offline. Any change of the game starts the wait again.

  OpponentInactiveNotifierProvider call(GameSession session) =>
      OpponentInactiveNotifierProvider._(argument: session, from: this);

  @override
  String toString() => r'opponentInactiveProvider';
}

/// Whether an online opponent has not played for [inactiveAfter] while it is their turn: their app may be closed or
/// offline. Any change of the game starts the wait again.

abstract class _$OpponentInactiveNotifier extends $Notifier<bool> {
  late final _$args = ref.$arg as GameSession;
  GameSession get session => _$args;

  bool build(GameSession session);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
