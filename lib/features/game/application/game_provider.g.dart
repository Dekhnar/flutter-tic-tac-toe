// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Throws while online play is off: no online session exists then.

@ProviderFor(onlineGameRepository)
const onlineGameRepositoryProvider = OnlineGameRepositoryProvider._();

/// Throws while online play is off: no online session exists then.

final class OnlineGameRepositoryProvider
    extends
        $FunctionalProvider<
          OnlineGameRepository,
          OnlineGameRepository,
          OnlineGameRepository
        >
    with $Provider<OnlineGameRepository> {
  /// Throws while online play is off: no online session exists then.
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
  $ProviderElement<OnlineGameRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnlineGameRepository create(Ref ref) {
    return onlineGameRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnlineGameRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnlineGameRepository>(value),
    );
  }
}

String _$onlineGameRepositoryHash() =>
    r'01dd80836672d60888a77e610ab37783eb562a36';

@ProviderFor(sessionGameRepository)
const sessionGameRepositoryProvider = SessionGameRepositoryFamily._();

final class SessionGameRepositoryProvider
    extends $FunctionalProvider<GameRepository, GameRepository, GameRepository>
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
  $ProviderElement<GameRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GameRepository create(Ref ref) {
    final argument = this.argument as GameSession;
    return sessionGameRepository(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameRepository>(value),
    );
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

String _$sessionGameRepositoryHash() =>
    r'c7cc9425e3866630f3f24dc1075743200e4f2975';

final class SessionGameRepositoryFamily extends $Family
    with $FunctionalFamilyOverride<GameRepository, GameSession> {
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

final class GameProvider
    extends $FunctionalProvider<AsyncValue<Game>, Game, Stream<Game>>
    with $FutureModifier<Game>, $StreamProvider<Game> {
  const GameProvider._({
    required GameFamily super.from,
    required GameSession super.argument,
  }) : super(
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
  $StreamProviderElement<Game> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

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

String _$gameHash() => r'1690103473974fe733f26dd2b4e1d396061b1532';

final class GameFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Game>, GameSession> {
  const GameFamily._()
    : super(
        retry: _noRetry,
        name: r'gameProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GameProvider call(GameSession session) =>
      GameProvider._(argument: session, from: this);

  @override
  String toString() => r'gameProvider';
}
