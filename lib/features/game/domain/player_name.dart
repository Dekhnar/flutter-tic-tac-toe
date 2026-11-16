/// A player's name as the server accepts it. Its length counts UTF-16 code units, as `firestore.rules` do: an emoji
/// can count for two, or four for a flag.
abstract final class PlayerName {
  static const maxLength = 20;

  static bool isTooLong(String name) => name.length > maxLength;
}
