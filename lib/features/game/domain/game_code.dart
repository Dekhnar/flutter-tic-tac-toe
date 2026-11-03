import 'dart:math';

import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';

/// The code a host shares for a guest to join: an online game's id. Players read it out and type it, so it has no 0/O
/// or 1/I to confuse.
extension type const GameCode._(String value) implements GameId {
  factory GameCode.random(Random random) => GameCode._(
    String.fromCharCodes([for (var i = 0; i < length; i++) alphabet.codeUnitAt(random.nextInt(alphabet.length))]),
  );

  factory GameCode.parse(String text) => tryParse(text) ?? (throw FormatException('No game code', text));

  static const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const length = 6;

  static final _separators = RegExp('[^A-Z0-9]+');

  /// The code [text] holds, in any case: typed alone, or within the invitation the host shared. Null when [text] holds
  /// no code, or several.
  static GameCode? tryParse(String text) {
    final codes = text.toUpperCase().split(_separators).where(_isCode).toSet();
    return codes.length == 1 ? GameCode._(codes.single) : null;
  }

  static bool _isCode(String word) => word.length == length && word.split('').every(alphabet.contains);
}
