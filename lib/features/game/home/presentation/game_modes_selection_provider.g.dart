// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_modes_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameModesSelectionNotifierHash() =>
    r'2f6c3fb2dedab78164532e9a980dfde6f79f00de';

/// Whether a game is being created or joined, between the dialog closing and the board opening.
///
/// Copied from [GameModesSelectionNotifier].
@ProviderFor(GameModesSelectionNotifier)
final gameModesSelectionNotifierProvider =
    AutoDisposeNotifierProvider<GameModesSelectionNotifier, bool>.internal(
      GameModesSelectionNotifier.new,
      name: r'gameModesSelectionNotifierProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$gameModesSelectionNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GameModesSelectionNotifier = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
