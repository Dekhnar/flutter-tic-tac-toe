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

String _$gameHash() => r'1d9a3c326afe8a3abcf3590264f734b2973202f0';

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

/// A game lives as long as something watches it: once its board closes, a local game is forgotten and the player
/// leaves an online one, which the opponent then sees abandoned. Retrying the game watches it again in the same
/// rebuild, which keeps it.

@ProviderFor(gameLifetime)
const gameLifetimeProvider = GameLifetimeFamily._();

/// A game lives as long as something watches it: once its board closes, a local game is forgotten and the player
/// leaves an online one, which the opponent then sees abandoned. Retrying the game watches it again in the same
/// rebuild, which keeps it.

final class GameLifetimeProvider extends $FunctionalProvider<void, void, void> with $Provider<void> {
  /// A game lives as long as something watches it: once its board closes, a local game is forgotten and the player
  /// leaves an online one, which the opponent then sees abandoned. Retrying the game watches it again in the same
  /// rebuild, which keeps it.
  const GameLifetimeProvider._({required GameLifetimeFamily super.from, required GameSession super.argument})
    : super(
        retry: null,
        name: r'gameLifetimeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameLifetimeHash();

  @override
  String toString() {
    return r'gameLifetimeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    final argument = this.argument as GameSession;
    return gameLifetime(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<void>(value));
  }

  @override
  bool operator ==(Object other) {
    return other is GameLifetimeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gameLifetimeHash() => r'3fc243ba2e357827442d88c30e769801567d4fe6';

/// A game lives as long as something watches it: once its board closes, a local game is forgotten and the player
/// leaves an online one, which the opponent then sees abandoned. Retrying the game watches it again in the same
/// rebuild, which keeps it.

final class GameLifetimeFamily extends $Family with $FunctionalFamilyOverride<void, GameSession> {
  const GameLifetimeFamily._()
    : super(
        retry: null,
        name: r'gameLifetimeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A game lives as long as something watches it: once its board closes, a local game is forgotten and the player
  /// leaves an online one, which the opponent then sees abandoned. Retrying the game watches it again in the same
  /// rebuild, which keeps it.

  GameLifetimeProvider call(GameSession session) => GameLifetimeProvider._(argument: session, from: this);

  @override
  String toString() => r'gameLifetimeProvider';
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

String _$gameActionsHash() => r'ae7b3e5253248ef9496ab3f78960e614b36f5d63';

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
