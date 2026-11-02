// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_mode_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Creating or joining the game the player chose: loading meanwhile, the error when it failed.

@ProviderFor(GameModeSelectionNotifier)
const gameModeSelectionProvider = GameModeSelectionNotifierProvider._();

/// Creating or joining the game the player chose: loading meanwhile, the error when it failed.
final class GameModeSelectionNotifierProvider extends $AsyncNotifierProvider<GameModeSelectionNotifier, void> {
  /// Creating or joining the game the player chose: loading meanwhile, the error when it failed.
  const GameModeSelectionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameModeSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameModeSelectionNotifierHash();

  @$internal
  @override
  GameModeSelectionNotifier create() => GameModeSelectionNotifier();
}

String _$gameModeSelectionNotifierHash() => r'c6bf374499b19b3e28d96161021100c63f18084d';

/// Creating or joining the game the player chose: loading meanwhile, the error when it failed.

abstract class _$GameModeSelectionNotifier extends $AsyncNotifier<void> {
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
