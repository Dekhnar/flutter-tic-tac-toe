// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionGameRepository)
const sessionGameRepositoryProvider = SessionGameRepositoryFamily._();

final class SessionGameRepositoryProvider extends $FunctionalProvider<GameRepository, GameRepository, GameRepository>
    with $Provider<GameRepository> {
  const SessionGameRepositoryProvider._({
    required SessionGameRepositoryFamily super.from,
    required GameSession super.argument,
  }) : super(
         retry: null,
         name: r'sessionGameRepositoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionGameRepositoryHash();

  @override
  String toString() {
    return r'sessionGameRepositoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GameRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  GameRepository create(Ref ref) {
    final argument = this.argument as GameSession;
    return sessionGameRepository(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameRepository value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<GameRepository>(value));
  }

  @override
  bool operator ==(Object other) {
    return other is SessionGameRepositoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionGameRepositoryHash() => r'c7cc9425e3866630f3f24dc1075743200e4f2975';

final class SessionGameRepositoryFamily extends $Family with $FunctionalFamilyOverride<GameRepository, GameSession> {
  const SessionGameRepositoryFamily._()
    : super(
        retry: null,
        name: r'sessionGameRepositoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SessionGameRepositoryProvider call(GameSession session) =>
      SessionGameRepositoryProvider._(argument: session, from: this);

  @override
  String toString() => r'sessionGameRepositoryProvider';
}

@ProviderFor(game)
const gameProvider = GameFamily._();

final class GameProvider extends $FunctionalProvider<AsyncValue<Game>, Game, Stream<Game>>
    with $FutureModifier<Game>, $StreamProvider<Game> {
  const GameProvider._({required GameFamily super.from, required GameSession super.argument})
    : super(
        retry: _noRetry,
        name: r'gameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameHash();

  @override
  String toString() {
    return r'gameProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Game> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<Game> create(Ref ref) {
    final argument = this.argument as GameSession;
    return game(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GameProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gameHash() => r'5732a176b245e7add54ef3c36ed63dbe2500f862';

final class GameFamily extends $Family with $FunctionalFamilyOverride<Stream<Game>, GameSession> {
  const GameFamily._()
    : super(
        retry: _noRetry,
        name: r'gameProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GameProvider call(GameSession session) => GameProvider._(argument: session, from: this);

  @override
  String toString() => r'gameProvider';
}

/// Whether the board asks before leaving: only a game it shows can end for an opponent, not one that failed to load,
/// since nothing is left to leave.

@ProviderFor(leaveNeedsConfirmation)
const leaveNeedsConfirmationProvider = LeaveNeedsConfirmationFamily._();

/// Whether the board asks before leaving: only a game it shows can end for an opponent, not one that failed to load,
/// since nothing is left to leave.

final class LeaveNeedsConfirmationProvider extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Whether the board asks before leaving: only a game it shows can end for an opponent, not one that failed to load,
  /// since nothing is left to leave.
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
  $ProviderElement<bool> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as GameSession;
    return leaveNeedsConfirmation(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<bool>(value));
  }

  @override
  bool operator ==(Object other) {
    return other is LeaveNeedsConfirmationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$leaveNeedsConfirmationHash() => r'8f5ef7ffcc88713493f50f879a90a83c3b6227cc';

/// Whether the board asks before leaving: only a game it shows can end for an opponent, not one that failed to load,
/// since nothing is left to leave.

final class LeaveNeedsConfirmationFamily extends $Family with $FunctionalFamilyOverride<bool, GameSession> {
  const LeaveNeedsConfirmationFamily._()
    : super(
        retry: null,
        name: r'leaveNeedsConfirmationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the board asks before leaving: only a game it shows can end for an opponent, not one that failed to load,
  /// since nothing is left to leave.

  LeaveNeedsConfirmationProvider call(GameSession session) =>
      LeaveNeedsConfirmationProvider._(argument: session, from: this);

  @override
  String toString() => r'leaveNeedsConfirmationProvider';
}

/// What the player does on the board: loading while the game handles it, the error when it refused or failed.

@ProviderFor(GameActions)
const gameActionsProvider = GameActionsFamily._();

/// What the player does on the board: loading while the game handles it, the error when it refused or failed.
final class GameActionsProvider extends $AsyncNotifierProvider<GameActions, void> {
  /// What the player does on the board: loading while the game handles it, the error when it refused or failed.
  const GameActionsProvider._({required GameActionsFamily super.from, required GameSession super.argument})
    : super(
        retry: null,
        name: r'gameActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameActionsHash();

  @override
  String toString() {
    return r'gameActionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GameActions create() => GameActions();

  @override
  bool operator ==(Object other) {
    return other is GameActionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gameActionsHash() => r'99d68d540c4fef8dfd5601f1ca22eb17be063f7d';

/// What the player does on the board: loading while the game handles it, the error when it refused or failed.

final class GameActionsFamily extends $Family
    with $ClassFamilyOverride<GameActions, AsyncValue<void>, void, FutureOr<void>, GameSession> {
  const GameActionsFamily._()
    : super(
        retry: null,
        name: r'gameActionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What the player does on the board: loading while the game handles it, the error when it refused or failed.

  GameActionsProvider call(GameSession session) => GameActionsProvider._(argument: session, from: this);

  @override
  String toString() => r'gameActionsProvider';
}

/// What the player does on the board: loading while the game handles it, the error when it refused or failed.

abstract class _$GameActions extends $AsyncNotifier<void> {
  late final _$args = ref.$arg as GameSession;
  GameSession get session => _$args;

  FutureOr<void> build(GameSession session);
  @$mustCallSuper
  @override
  void runBuild() {
    build(_$args);
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<AsyncValue<void>, void>, AsyncValue<void>, Object?, Object?>;
    element.handleValue(ref, null);
  }
}
