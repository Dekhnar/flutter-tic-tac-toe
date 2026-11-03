import 'package:tic_tac_toe_app/features/game/domain/game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/player_identity.dart';
import 'package:tic_tac_toe_app/shared/exceptions/expected_exception.dart';

/// Whether this run of the app offers online play. The services it needs come with [OnlinePlayAvailable] only, so no
/// code can reach them while it is off.
sealed class OnlinePlay {
  const OnlinePlay();
}

final class OnlinePlayAvailable extends OnlinePlay {
  const OnlinePlayAvailable({required this.identity, required this.repository});

  final PlayerIdentity identity;
  final OnlineGameRepository repository;
}

final class OnlinePlayUnavailable extends OnlinePlay {
  const OnlinePlayUnavailable(this.reason);

  final OnlineUnavailableReason reason;
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
