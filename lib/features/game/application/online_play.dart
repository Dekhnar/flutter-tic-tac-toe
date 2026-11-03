import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/player_identity.dart';
import 'package:tic_tac_toe_app/shared/exceptions/expected_exception.dart';

part 'online_play.freezed.dart';

/// Whether this run of the app offers online play. Only [OnlinePlayAvailable] carries the online services, so no code
/// reaches them while it is off.
@freezed
sealed class OnlinePlay with _$OnlinePlay {
  const factory OnlinePlay.available({required PlayerIdentity identity, required OnlineGameRepository repository}) =
      OnlinePlayAvailable;

  const factory OnlinePlay.unavailable(OnlineUnavailableReason reason) = OnlinePlayUnavailable;
}

enum OnlineUnavailableReason {
  /// The build carries Firebase options, but Firebase failed to start with them.
  failedToStart,

  /// The build carries no Firebase options for this platform.
  notConfigured,
}

/// The player asked for online play while it is off.
final class OnlineUnavailableException implements ExpectedException {
  OnlineUnavailableException(this.reason);

  final OnlineUnavailableReason reason;

  @override
  String toString() => 'OnlineUnavailableException(${reason.name})';
}
