// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionGameRepository)
const sessionGameRepositoryProvider = SessionGameRepositoryFamily._();

final class SessionGameRepositoryProvider
    extends $FunctionalProvider<GameRepositoryInterface, GameRepositoryInterface, GameRepositoryInterface>
    with $Provider<GameRepositoryInterface> {
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
  $ProviderElement<GameRepositoryInterface> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  GameRepositoryInterface create(Ref ref) {
    final argument = this.argument as GameSession;
    return sessionGameRepository(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameRepositoryInterface value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<GameRepositoryInterface>(value));
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

String _$sessionGameRepositoryHash() => r'4d66c29ea71c96861f678602907a4eccab63025e';

final class SessionGameRepositoryFamily extends $Family
    with $FunctionalFamilyOverride<GameRepositoryInterface, GameSession> {
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

String _$gameHash() => r'dc560d098e185fe79394b8c6421996240bc26b07';

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

/// A local game lives as long as something watches it: once its board closes, the game is forgotten. Retrying the
/// game watches it again in the same rebuild, which keeps it.

@ProviderFor(localGameLifetime)
const localGameLifetimeProvider = LocalGameLifetimeFamily._();

/// A local game lives as long as something watches it: once its board closes, the game is forgotten. Retrying the
/// game watches it again in the same rebuild, which keeps it.

final class LocalGameLifetimeProvider extends $FunctionalProvider<void, void, void> with $Provider<void> {
  /// A local game lives as long as something watches it: once its board closes, the game is forgotten. Retrying the
  /// game watches it again in the same rebuild, which keeps it.
  const LocalGameLifetimeProvider._({required LocalGameLifetimeFamily super.from, required GameId super.argument})
    : super(
        retry: null,
        name: r'localGameLifetimeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localGameLifetimeHash();

  @override
  String toString() {
    return r'localGameLifetimeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    final argument = this.argument as GameId;
    return localGameLifetime(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<void>(value));
  }

  @override
  bool operator ==(Object other) {
    return other is LocalGameLifetimeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$localGameLifetimeHash() => r'9b6a5200feea9b64920530b0e0227f89eeb780be';

/// A local game lives as long as something watches it: once its board closes, the game is forgotten. Retrying the
/// game watches it again in the same rebuild, which keeps it.

final class LocalGameLifetimeFamily extends $Family with $FunctionalFamilyOverride<void, GameId> {
  const LocalGameLifetimeFamily._()
    : super(
        retry: null,
        name: r'localGameLifetimeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A local game lives as long as something watches it: once its board closes, the game is forgotten. Retrying the
  /// game watches it again in the same rebuild, which keeps it.

  LocalGameLifetimeProvider call(GameId gameId) => LocalGameLifetimeProvider._(argument: gameId, from: this);

  @override
  String toString() => r'localGameLifetimeProvider';
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

String _$gameActionsHash() => r'161434bc5e0d7893efab8d7768a29661dfa4b2b7';

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
