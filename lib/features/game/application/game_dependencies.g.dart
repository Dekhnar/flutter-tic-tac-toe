// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_dependencies.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Kept alive: local games are created on the home screen, then played on the board.

@ProviderFor(localGameRepository)
const localGameRepositoryProvider = LocalGameRepositoryProvider._();

/// Kept alive: local games are created on the home screen, then played on the board.

final class LocalGameRepositoryProvider
    extends
        $FunctionalProvider<
          LocalGameRepository,
          LocalGameRepository,
          LocalGameRepository
        >
    with $Provider<LocalGameRepository> {
  /// Kept alive: local games are created on the home screen, then played on the board.
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
  $ProviderElement<LocalGameRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalGameRepository create(Ref ref) {
    return localGameRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalGameRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalGameRepository>(value),
    );
  }
}

String _$localGameRepositoryHash() =>
    r'8d5367fbdaef26cd03bfa281fc3d973ef6f7cb27';

@ProviderFor(onlinePlay)
const onlinePlayProvider = OnlinePlayProvider._();

final class OnlinePlayProvider
    extends $FunctionalProvider<OnlinePlay, OnlinePlay, OnlinePlay>
    with $Provider<OnlinePlay> {
  const OnlinePlayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onlinePlayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onlinePlayHash();

  @$internal
  @override
  $ProviderElement<OnlinePlay> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OnlinePlay create(Ref ref) {
    return onlinePlay(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnlinePlay value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnlinePlay>(value),
    );
  }
}

String _$onlinePlayHash() => r'97766840afb0ec06d8f1a73b026738f22e7c3be0';
