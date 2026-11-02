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
    extends
        $FunctionalProvider<LocalGameRepositoryInterface, LocalGameRepositoryInterface, LocalGameRepositoryInterface>
    with $Provider<LocalGameRepositoryInterface> {
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
  $ProviderElement<LocalGameRepositoryInterface> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  LocalGameRepositoryInterface create(Ref ref) {
    return localGameRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalGameRepositoryInterface value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<LocalGameRepositoryInterface>(value));
  }
}

String _$localGameRepositoryHash() => r'652b9e948abe448fea918a9a43e2262b50e6826f';

@ProviderFor(onlineGameRepository)
const onlineGameRepositoryProvider = OnlineGameRepositoryProvider._();

final class OnlineGameRepositoryProvider
    extends
        $FunctionalProvider<OnlineGameRepositoryInterface, OnlineGameRepositoryInterface, OnlineGameRepositoryInterface>
    with $Provider<OnlineGameRepositoryInterface> {
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
  $ProviderElement<OnlineGameRepositoryInterface> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  OnlineGameRepositoryInterface create(Ref ref) {
    return onlineGameRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnlineGameRepositoryInterface value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<OnlineGameRepositoryInterface>(value));
  }
}

String _$onlineGameRepositoryHash() => r'bee552f70f4e5c57c1d0f2a152a56d5b148c0e88';

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
