// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_local_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localGameRepositoryHash() =>
    r'3c3f89dbd762075e127571f9504a3ec5c5e6042d';

/// Kept alive: it is the in-memory database of the local games, created on the home screen and played on the board.
///
/// Copied from [localGameRepository].
@ProviderFor(localGameRepository)
final localGameRepositoryProvider =
    Provider<LocalGameRepositoryInterface>.internal(
      localGameRepository,
      name: r'localGameRepositoryProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$localGameRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalGameRepositoryRef = ProviderRef<LocalGameRepositoryInterface>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
