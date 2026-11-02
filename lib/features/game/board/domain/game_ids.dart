/// Identifies a game; online, it is also the code players share to join it.
extension type const GameId(String value) {}

/// Identifies a player: the Firebase user id online, a fixed seat id on a local game.
extension type const PlayerId(String value) {}
