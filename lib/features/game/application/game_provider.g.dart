// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The online games, for as long as online play is available: an online session only exists then.

@ProviderFor(onlineGameRepository)
const onlineGameRepositoryProvider = OnlineGameRepositoryProvider._();

/// The online games, for as long as online play is available: an online session only exists then.

final class OnlineGameRepositoryProvider
    extends $FunctionalProvider<OnlineGameRepository, OnlineGameRepository, OnlineGameRepository>
    with $Provider<OnlineGameRepository> {
  /// The online games, for as long as online play is available: an online session only exists then.
  const OnlineGameRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onlineGameRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onlineGameRepositoryHash();

  @$internal
  @override
  $ProviderElement<OnlineGameRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  OnlineGameRepository create(Ref ref) {
    return onlineGameRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnlineGameRepository value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<OnlineGameRepository>(value));
  }
}

String _$onlineGameRepositoryHash() => r'01dd80836672d60888a77e610ab37783eb562a36';

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

/// What is done on the board, by the player or the AI: loading while the game handles it, the error when it refused
/// or failed.

@ProviderFor(GameActionsNotifier)
const gameActionsProvider = GameActionsNotifierFamily._();

/// What is done on the board, by the player or the AI: loading while the game handles it, the error when it refused
/// or failed.
final class GameActionsNotifierProvider extends $AsyncNotifierProvider<GameActionsNotifier, void> {
  /// What is done on the board, by the player or the AI: loading while the game handles it, the error when it refused
  /// or failed.
  const GameActionsNotifierProvider._({
    required GameActionsNotifierFamily super.from,
    required GameSession super.argument,
  }) : super(
         retry: null,
         name: r'gameActionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$gameActionsNotifierHash();

  @override
  String toString() {
    return r'gameActionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GameActionsNotifier create() => GameActionsNotifier();

  @override
  bool operator ==(Object other) {
    return other is GameActionsNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gameActionsNotifierHash() => r'f8b33dd0a4689f49d4987db3a85355495b9a9b7f';

/// What is done on the board, by the player or the AI: loading while the game handles it, the error when it refused
/// or failed.

final class GameActionsNotifierFamily extends $Family
    with $ClassFamilyOverride<GameActionsNotifier, AsyncValue<void>, void, FutureOr<void>, GameSession> {
  const GameActionsNotifierFamily._()
    : super(
        retry: null,
        name: r'gameActionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What is done on the board, by the player or the AI: loading while the game handles it, the error when it refused
  /// or failed.

  GameActionsNotifierProvider call(GameSession session) => GameActionsNotifierProvider._(argument: session, from: this);

  @override
  String toString() => r'gameActionsProvider';
}

/// What is done on the board, by the player or the AI: loading while the game handles it, the error when it refused
/// or failed.

abstract class _$GameActionsNotifier extends $AsyncNotifier<void> {
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
