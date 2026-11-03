// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_opponent.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Gives the player time to see their own move land before the answer.

@ProviderFor(aiThinkingTime)
const aiThinkingTimeProvider = AiThinkingTimeProvider._();

/// Gives the player time to see their own move land before the answer.

final class AiThinkingTimeProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// Gives the player time to see their own move land before the answer.
  const AiThinkingTimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiThinkingTimeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiThinkingTimeHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return aiThinkingTime(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$aiThinkingTimeHash() => r'8ffe49ff93c8c554b6bb4ca7776623d46f57d063';

/// Plays the AI's turns in the game of [session] for as long as it is watched. Every change of the game restarts the
/// thinking, so the AI always plays on the game as it is.

@ProviderFor(aiOpponent)
const aiOpponentProvider = AiOpponentFamily._();

/// Plays the AI's turns in the game of [session] for as long as it is watched. Every change of the game restarts the
/// thinking, so the AI always plays on the game as it is.

final class AiOpponentProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Plays the AI's turns in the game of [session] for as long as it is watched. Every change of the game restarts the
  /// thinking, so the AI always plays on the game as it is.
  const AiOpponentProvider._({
    required AiOpponentFamily super.from,
    required GameSession super.argument,
  }) : super(
         retry: null,
         name: r'aiOpponentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$aiOpponentHash();

  @override
  String toString() {
    return r'aiOpponentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    final argument = this.argument as GameSession;
    return aiOpponent(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AiOpponentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$aiOpponentHash() => r'c6868526ca10963b567c2b47397b97bcd6d02c5d';

/// Plays the AI's turns in the game of [session] for as long as it is watched. Every change of the game restarts the
/// thinking, so the AI always plays on the game as it is.

final class AiOpponentFamily extends $Family
    with $FunctionalFamilyOverride<void, GameSession> {
  const AiOpponentFamily._()
    : super(
        retry: null,
        name: r'aiOpponentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Plays the AI's turns in the game of [session] for as long as it is watched. Every change of the game restarts the
  /// thinking, so the AI always plays on the game as it is.

  AiOpponentProvider call(GameSession session) =>
      AiOpponentProvider._(argument: session, from: this);

  @override
  String toString() => r'aiOpponentProvider';
}
