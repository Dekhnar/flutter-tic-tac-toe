// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_board_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the player does on the board: loading while the game handles it, then the error if it was refused or failed.
/// One action at a time, each given [timeLimit] to complete.

@ProviderFor(GameBoardActionsNotifier)
const gameBoardActionsProvider = GameBoardActionsNotifierFamily._();

/// What the player does on the board: loading while the game handles it, then the error if it was refused or failed.
/// One action at a time, each given [timeLimit] to complete.
final class GameBoardActionsNotifierProvider
    extends $AsyncNotifierProvider<GameBoardActionsNotifier, void> {
  /// What the player does on the board: loading while the game handles it, then the error if it was refused or failed.
  /// One action at a time, each given [timeLimit] to complete.
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
    r'b3dd64625a12284be00fc16deda441a456186183';

/// What the player does on the board: loading while the game handles it, then the error if it was refused or failed.
/// One action at a time, each given [timeLimit] to complete.

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

  /// What the player does on the board: loading while the game handles it, then the error if it was refused or failed.
  /// One action at a time, each given [timeLimit] to complete.

  GameBoardActionsNotifierProvider call(GameSession session) =>
      GameBoardActionsNotifierProvider._(argument: session, from: this);

  @override
  String toString() => r'gameBoardActionsProvider';
}

/// What the player does on the board: loading while the game handles it, then the error if it was refused or failed.
/// One action at a time, each given [timeLimit] to complete.

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

/// The cell of a move this device made, until the game shows it: online, the game comes back on its own stream, after
/// the server's answer. Only [GameBoardActionsNotifier] sets it.

@ProviderFor(PendingMoveNotifier)
const pendingMoveProvider = PendingMoveNotifierFamily._();

/// The cell of a move this device made, until the game shows it: online, the game comes back on its own stream, after
/// the server's answer. Only [GameBoardActionsNotifier] sets it.
final class PendingMoveNotifierProvider
    extends $NotifierProvider<PendingMoveNotifier, Cell?> {
  /// The cell of a move this device made, until the game shows it: online, the game comes back on its own stream, after
  /// the server's answer. Only [GameBoardActionsNotifier] sets it.
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
    r'75ea8878924e149e5410e78f389e1b8674b8b00d';

/// The cell of a move this device made, until the game shows it: online, the game comes back on its own stream, after
/// the server's answer. Only [GameBoardActionsNotifier] sets it.

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

  /// The cell of a move this device made, until the game shows it: online, the game comes back on its own stream, after
  /// the server's answer. Only [GameBoardActionsNotifier] sets it.

  PendingMoveNotifierProvider call(GameSession session) =>
      PendingMoveNotifierProvider._(argument: session, from: this);

  @override
  String toString() => r'pendingMoveProvider';
}

/// The cell of a move this device made, until the game shows it: online, the game comes back on its own stream, after
/// the server's answer. Only [GameBoardActionsNotifier] sets it.

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

/// Only a game the board shows can end for an opponent: one that failed to load leaves nothing to confirm.

@ProviderFor(leaveNeedsConfirmation)
const leaveNeedsConfirmationProvider = LeaveNeedsConfirmationFamily._();

/// Only a game the board shows can end for an opponent: one that failed to load leaves nothing to confirm.

final class LeaveNeedsConfirmationProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Only a game the board shows can end for an opponent: one that failed to load leaves nothing to confirm.
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
    r'8f5ef7ffcc88713493f50f879a90a83c3b6227cc';

/// Only a game the board shows can end for an opponent: one that failed to load leaves nothing to confirm.

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

  /// Only a game the board shows can end for an opponent: one that failed to load leaves nothing to confirm.

  LeaveNeedsConfirmationProvider call(GameSession session) =>
      LeaveNeedsConfirmationProvider._(argument: session, from: this);

  @override
  String toString() => r'leaveNeedsConfirmationProvider';
}
