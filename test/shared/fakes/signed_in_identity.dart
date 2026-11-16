import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/domain/player_identity.dart';

/// A device signed in as [player], once [player] completes.
final class SignedInIdentity implements PlayerIdentity {
  SignedInIdentity(PlayerId player) : _player = Future.value(player);

  SignedInIdentity.later(this._player);

  final Future<PlayerId> _player;

  @override
  Future<PlayerId> signIn() => _player;
}
