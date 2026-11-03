// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session_start_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Starting the game the player chose: loading meanwhile, then the error if it failed. The player stops waiting by
/// cancelling, or after [timeLimit].

@ProviderFor(GameSessionStartNotifier)
const gameSessionStartProvider = GameSessionStartNotifierProvider._();

/// Starting the game the player chose: loading meanwhile, then the error if it failed. The player stops waiting by
/// cancelling, or after [timeLimit].
final class GameSessionStartNotifierProvider
    extends $AsyncNotifierProvider<GameSessionStartNotifier, void> {
  /// Starting the game the player chose: loading meanwhile, then the error if it failed. The player stops waiting by
  /// cancelling, or after [timeLimit].
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

String _$gameSessionStartNotifierHash() =>
    r'815a74fb1ba1795c4f975a722e7deaa7eb5a78c8';

/// Starting the game the player chose: loading meanwhile, then the error if it failed. The player stops waiting by
/// cancelling, or after [timeLimit].

abstract class _$GameSessionStartNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
