import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_code.dart';

part 'game_create_input.freezed.dart';

@freezed
sealed class GameCreateInput with _$GameCreateInput {
  const factory GameCreateInput.local({required String guestName, required String hostName}) = LocalGameInput;

  const factory GameCreateInput.localVsAi({required String hostName}) = LocalVsAiGameInput;

  const factory GameCreateInput.createOnline({required String hostName}) = CreateOnlineGameInput;

  const factory GameCreateInput.joinOnline({required GameCode code, required String guestName}) = JoinOnlineGameInput;
}
