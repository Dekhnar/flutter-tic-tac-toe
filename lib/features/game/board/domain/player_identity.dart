import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';

/// Who this device plays as online.
abstract interface class PlayerIdentity {
  Future<PlayerId> signIn();
}
