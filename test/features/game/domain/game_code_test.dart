import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_code.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';

void main() {
  test('a new code has six characters, none a player could misread', () {
    final random = Random(7);
    final codes = [for (var i = 0; i < 200; i++) GameCode.random(random)];

    expect(codes.map((code) => code.value), everyElement(matches(RegExp(r'^[A-HJ-NP-Z2-9]{6}$'))));
  });

  test('a code is read in any case, the spaces around it ignored', () {
    expect(GameCode.tryParse(' ab3cd4 '), GameCode.parse('AB3CD4'));
  });

  test('the invitation the host shares gives its code back, in every language of the app', () {
    final code = GameCode.parse('AB3CD4');

    for (final locale in I18n.supportedLocales) {
      expect(GameCode.tryParse(lookupI18n(locale).shareInvitation(code.value)), code, reason: '$locale');
    }
  });

  test('text without a code holds none: too short, too long, or with a character codes leave out', () {
    for (final text in ['', 'Hello', 'AB3CD', 'AB3CD45', 'AB0CD4', 'ABOCD4', 'AB1CD4', 'ABICD4']) {
      expect(GameCode.tryParse(text), isNull, reason: text);
    }
  });

  test('text with two different codes is not guessed at', () {
    expect(GameCode.tryParse('AB3CD4, or else EF5GH6'), isNull);
    expect(GameCode.tryParse('AB3CD4 (AB3CD4)'), GameCode.parse('AB3CD4'));
  });

  test('parsing text without a code fails', () {
    expect(() => GameCode.parse('Hello'), throwsFormatException);
  });
}
