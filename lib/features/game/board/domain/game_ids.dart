import 'package:freezed_annotation/freezed_annotation.dart';

/// Identifies a game; online, it is also the code players share to join it.
extension type const GameId(String value) {}

/// Identifies a player: the Firebase user id online, a fixed seat id on a local game.
extension type const PlayerId(String value) {}

final class GameIdConverter implements JsonConverter<GameId, String> {
  const GameIdConverter();

  @override
  GameId fromJson(String json) => GameId(json);

  @override
  String toJson(GameId gameId) => gameId.value;
}

final class PlayerIdConverter implements JsonConverter<PlayerId, String> {
  const PlayerIdConverter();

  @override
  PlayerId fromJson(String json) => PlayerId(json);

  @override
  String toJson(PlayerId playerId) => playerId.value;
}
