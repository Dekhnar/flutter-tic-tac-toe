// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_modes_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Creating or joining the game the player chose: loading meanwhile, the error when it failed.

@ProviderFor(GameModesSelectionNotifier)
const gameModesSelectionProvider = GameModesSelectionNotifierProvider._();

/// Creating or joining the game the player chose: loading meanwhile, the error when it failed.
final class GameModesSelectionNotifierProvider extends $AsyncNotifierProvider<GameModesSelectionNotifier, void> {
  /// Creating or joining the game the player chose: loading meanwhile, the error when it failed.
  const GameModesSelectionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameModesSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameModesSelectionNotifierHash();

  @$internal
  @override
  GameModesSelectionNotifier create() => GameModesSelectionNotifier();
}

String _$gameModesSelectionNotifierHash() => r'5a0fee7ef3333e4e1a335da7618d2d1abcb472f8';

/// Creating or joining the game the player chose: loading meanwhile, the error when it failed.

abstract class _$GameModesSelectionNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<AsyncValue<void>, void>, AsyncValue<void>, Object?, Object?>;
    element.handleValue(ref, null);
  }
}
