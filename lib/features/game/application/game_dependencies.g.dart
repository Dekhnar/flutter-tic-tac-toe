// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_dependencies.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Kept alive: it is the database of the local games, created on the home screen and played on the board.

@ProviderFor(localGameRepository)
const localGameRepositoryProvider = LocalGameRepositoryProvider._();

/// Kept alive: it is the database of the local games, created on the home screen and played on the board.

final class LocalGameRepositoryProvider
    extends $FunctionalProvider<LocalGameRepository, LocalGameRepository, LocalGameRepository>
    with $Provider<LocalGameRepository> {
  /// Kept alive: it is the database of the local games, created on the home screen and played on the board.
  const LocalGameRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localGameRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localGameRepositoryHash();

  @$internal
  @override
  $ProviderElement<LocalGameRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  LocalGameRepository create(Ref ref) {
    return localGameRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalGameRepository value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<LocalGameRepository>(value));
  }
}

String _$localGameRepositoryHash() => r'8d5367fbdaef26cd03bfa281fc3d973ef6f7cb27';

@ProviderFor(onlineGameRepository)
const onlineGameRepositoryProvider = OnlineGameRepositoryProvider._();

final class OnlineGameRepositoryProvider
    extends $FunctionalProvider<OnlineGameRepository, OnlineGameRepository, OnlineGameRepository>
    with $Provider<OnlineGameRepository> {
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

String _$onlineGameRepositoryHash() => r'c60364aa8e785c6b56032665c7e152d54fdaae41';

@ProviderFor(playerIdentity)
const playerIdentityProvider = PlayerIdentityProvider._();

final class PlayerIdentityProvider extends $FunctionalProvider<PlayerIdentity, PlayerIdentity, PlayerIdentity>
    with $Provider<PlayerIdentity> {
  const PlayerIdentityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerIdentityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerIdentityHash();

  @$internal
  @override
  $ProviderElement<PlayerIdentity> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  PlayerIdentity create(Ref ref) {
    return playerIdentity(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerIdentity value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<PlayerIdentity>(value));
  }
}

String _$playerIdentityHash() => r'8ad2fd1dbe92564a73e7d400cbc25cffab0c2ca6';
