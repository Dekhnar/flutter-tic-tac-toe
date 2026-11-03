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

/// Plays the AI's turns in the game of [session] for as long as it is watched, until [stop]. Every change of the game
/// restarts the thinking, so the AI always plays on the game as it is.

@ProviderFor(AiOpponentNotifier)
const aiOpponentProvider = AiOpponentNotifierFamily._();

/// Plays the AI's turns in the game of [session] for as long as it is watched, until [stop]. Every change of the game
/// restarts the thinking, so the AI always plays on the game as it is.
final class AiOpponentNotifierProvider
    extends $NotifierProvider<AiOpponentNotifier, void> {
  /// Plays the AI's turns in the game of [session] for as long as it is watched, until [stop]. Every change of the game
  /// restarts the thinking, so the AI always plays on the game as it is.
  const AiOpponentNotifierProvider._({
    required AiOpponentNotifierFamily super.from,
    required GameSession super.argument,
  }) : super(
         retry: null,
         name: r'aiOpponentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$aiOpponentNotifierHash();

  @override
  String toString() {
    return r'aiOpponentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AiOpponentNotifier create() => AiOpponentNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AiOpponentNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$aiOpponentNotifierHash() =>
    r'5459324bc0a5010aa3f979973a7d95d3598a51f0';

/// Plays the AI's turns in the game of [session] for as long as it is watched, until [stop]. Every change of the game
/// restarts the thinking, so the AI always plays on the game as it is.

final class AiOpponentNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          AiOpponentNotifier,
          void,
          void,
          void,
          GameSession
        > {
  const AiOpponentNotifierFamily._()
    : super(
        retry: null,
        name: r'aiOpponentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Plays the AI's turns in the game of [session] for as long as it is watched, until [stop]. Every change of the game
  /// restarts the thinking, so the AI always plays on the game as it is.

  AiOpponentNotifierProvider call(GameSession session) =>
      AiOpponentNotifierProvider._(argument: session, from: this);

  @override
  String toString() => r'aiOpponentProvider';
}

/// Plays the AI's turns in the game of [session] for as long as it is watched, until [stop]. Every change of the game
/// restarts the thinking, so the AI always plays on the game as it is.

abstract class _$AiOpponentNotifier extends $Notifier<void> {
  late final _$args = ref.$arg as GameSession;
  GameSession get session => _$args;

  void build(GameSession session);
  @$mustCallSuper
  @override
  void runBuild() {
    build(_$args);
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
