// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session_start_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Creating or joining the game the player chose: loading meanwhile, the error when it failed. The player stops waiting
/// by cancelling, or after [timeLimit] with a [TimeoutException]. A session that comes afterwards is left at once:
/// nobody opens its board, and an opponent must not wait in it.

@ProviderFor(GameSessionStartNotifier)
const gameSessionStartProvider = GameSessionStartNotifierProvider._();

/// Creating or joining the game the player chose: loading meanwhile, the error when it failed. The player stops waiting
/// by cancelling, or after [timeLimit] with a [TimeoutException]. A session that comes afterwards is left at once:
/// nobody opens its board, and an opponent must not wait in it.
final class GameSessionStartNotifierProvider extends $AsyncNotifierProvider<GameSessionStartNotifier, void> {
  /// Creating or joining the game the player chose: loading meanwhile, the error when it failed. The player stops waiting
  /// by cancelling, or after [timeLimit] with a [TimeoutException]. A session that comes afterwards is left at once:
  /// nobody opens its board, and an opponent must not wait in it.
  const GameSessionStartNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameSessionStartProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameSessionStartNotifierHash();

  @$internal
  @override
  GameSessionStartNotifier create() => GameSessionStartNotifier();
}

String _$gameSessionStartNotifierHash() => r'9bd8603067abae0a57756cc611cabaa8cd91eb34';

/// Creating or joining the game the player chose: loading meanwhile, the error when it failed. The player stops waiting
/// by cancelling, or after [timeLimit] with a [TimeoutException]. A session that comes afterwards is left at once:
/// nobody opens its board, and an opponent must not wait in it.

abstract class _$GameSessionStartNotifier extends $AsyncNotifier<void> {
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
