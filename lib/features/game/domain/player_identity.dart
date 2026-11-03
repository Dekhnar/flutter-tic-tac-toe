import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';

abstract interface class PlayerIdentity {
  Future<PlayerId> signIn();
}
