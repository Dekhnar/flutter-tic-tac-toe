// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session_starter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the dependencies themselves rather than a `Ref`, which may be disposed before a creation completes.

@ProviderFor(gameSessionStarter)
const gameSessionStarterProvider = GameSessionStarterProvider._();

/// Holds the dependencies themselves rather than a `Ref`, which may be disposed before a creation completes.

final class GameSessionStarterProvider
    extends $FunctionalProvider<GameSessionStarter, GameSessionStarter, GameSessionStarter>
    with $Provider<GameSessionStarter> {
  /// Holds the dependencies themselves rather than a `Ref`, which may be disposed before a creation completes.
  const GameSessionStarterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameSessionStarterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameSessionStarterHash();

  @$internal
  @override
  $ProviderElement<GameSessionStarter> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  GameSessionStarter create(Ref ref) {
    return gameSessionStarter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameSessionStarter value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<GameSessionStarter>(value));
  }
}

String _$gameSessionStarterHash() => r'b1f6ae9c62244dae041da7be4369acd54578f861';
