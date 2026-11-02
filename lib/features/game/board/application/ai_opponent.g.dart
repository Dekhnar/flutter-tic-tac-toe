// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_opponent.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How long the AI seems to think: the player sees their own move land before the answer.

@ProviderFor(aiThinkingTime)
const aiThinkingTimeProvider = AiThinkingTimeProvider._();

/// How long the AI seems to think: the player sees their own move land before the answer.

final class AiThinkingTimeProvider extends $FunctionalProvider<Duration, Duration, Duration> with $Provider<Duration> {
  /// How long the AI seems to think: the player sees their own move land before the answer.
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
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return aiThinkingTime(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Duration>(value));
  }
}

String _$aiThinkingTimeHash() => r'8ffe49ff93c8c554b6bb4ca7776623d46f57d063';

/// Plays the AI's turns in the game of [session], as the player's moves are played: through [GameActions].

@ProviderFor(aiOpponent)
const aiOpponentProvider = AiOpponentFamily._();

/// Plays the AI's turns in the game of [session], as the player's moves are played: through [GameActions].

final class AiOpponentProvider extends $FunctionalProvider<void, void, void> with $Provider<void> {
  /// Plays the AI's turns in the game of [session], as the player's moves are played: through [GameActions].
  const AiOpponentProvider._({required AiOpponentFamily super.from, required GameSession super.argument})
    : super(
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
  $ProviderElement<void> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    final argument = this.argument as GameSession;
    return aiOpponent(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<void>(value));
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

String _$aiOpponentHash() => r'c1d7d41a6ce9c56829f5ab3bab175dcc2c914383';

/// Plays the AI's turns in the game of [session], as the player's moves are played: through [GameActions].

final class AiOpponentFamily extends $Family with $FunctionalFamilyOverride<void, GameSession> {
  const AiOpponentFamily._()
    : super(
        retry: null,
        name: r'aiOpponentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Plays the AI's turns in the game of [session], as the player's moves are played: through [GameActions].

  AiOpponentProvider call(GameSession session) => AiOpponentProvider._(argument: session, from: this);

  @override
  String toString() => r'aiOpponentProvider';
}
