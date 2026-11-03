// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_navigation.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Bound in `lib/composition.dart`.

@ProviderFor(gameNavigation)
const gameNavigationProvider = GameNavigationProvider._();

/// Bound in `lib/composition.dart`.

final class GameNavigationProvider
    extends $FunctionalProvider<GameNavigation, GameNavigation, GameNavigation>
    with $Provider<GameNavigation> {
  /// Bound in `lib/composition.dart`.
  const GameNavigationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameNavigationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameNavigationHash();

  @$internal
  @override
  $ProviderElement<GameNavigation> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GameNavigation create(Ref ref) {
    return gameNavigation(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameNavigation value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameNavigation>(value),
    );
  }
}

String _$gameNavigationHash() => r'ba6b65ffc6d0542a5f0e33d883a25ad042b65f72';
