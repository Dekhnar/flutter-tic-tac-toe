// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_board_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the board asks before leaving: only a game it shows can end for an opponent, not one that failed to load,
/// since nothing is left to leave.

@ProviderFor(leaveNeedsConfirmation)
const leaveNeedsConfirmationProvider = LeaveNeedsConfirmationFamily._();

/// Whether the board asks before leaving: only a game it shows can end for an opponent, not one that failed to load,
/// since nothing is left to leave.

final class LeaveNeedsConfirmationProvider extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Whether the board asks before leaving: only a game it shows can end for an opponent, not one that failed to load,
  /// since nothing is left to leave.
  const LeaveNeedsConfirmationProvider._({
    required LeaveNeedsConfirmationFamily super.from,
    required GameSession super.argument,
  }) : super(
         retry: null,
         name: r'leaveNeedsConfirmationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$leaveNeedsConfirmationHash();

  @override
  String toString() {
    return r'leaveNeedsConfirmationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as GameSession;
    return leaveNeedsConfirmation(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<bool>(value));
  }

  @override
  bool operator ==(Object other) {
    return other is LeaveNeedsConfirmationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$leaveNeedsConfirmationHash() => r'8f5ef7ffcc88713493f50f879a90a83c3b6227cc';

/// Whether the board asks before leaving: only a game it shows can end for an opponent, not one that failed to load,
/// since nothing is left to leave.

final class LeaveNeedsConfirmationFamily extends $Family with $FunctionalFamilyOverride<bool, GameSession> {
  const LeaveNeedsConfirmationFamily._()
    : super(
        retry: null,
        name: r'leaveNeedsConfirmationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the board asks before leaving: only a game it shows can end for an opponent, not one that failed to load,
  /// since nothing is left to leave.

  LeaveNeedsConfirmationProvider call(GameSession session) =>
      LeaveNeedsConfirmationProvider._(argument: session, from: this);

  @override
  String toString() => r'leaveNeedsConfirmationProvider';
}
