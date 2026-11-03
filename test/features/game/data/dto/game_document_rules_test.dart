import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/data/dto/game_document.dart';

/// `firestore.rules` and [GameWrite] describe the same protocol twice: this keeps them in step, write by write.
void main() {
  final rules = _Rules(File('firestore.rules').readAsStringSync());

  const ruleOf = {
    GameWrite.create: 'isCreatedByHost',
    GameWrite.join: 'isJoin',
    GameWrite.start: 'isStart',
    GameWrite.move: 'isMove',
    GameWrite.newRound: 'isNewRound',
    GameWrite.leave: 'isLeave',
  };

  for (final write in GameWrite.values) {
    test('the rules let the ${write.name} write change exactly the fields the app writes', () {
      final function = ruleOf[write] ?? (throw TestFailure('No rule mapped for ${write.name}'));

      expect(rules.fieldsAllowedBy(function), {for (final field in write.fields) field.name});
    });
  }

  test('every write the app makes has a rule that allows it', () {
    for (final write in GameWrite.values) {
      final allowedBy = rules.condition(write == GameWrite.create ? 'create' : 'update');
      expect(allowedBy, contains('${ruleOf[write]}()'), reason: write.name);
    }
  });

  test('the server checks the time of every write that carries one', () {
    for (final write in GameWrite.values) {
      final body = rules.body(ruleOf[write] ?? '');
      for (final field in write.fields.intersection(GameWrite.serverTimeFields)) {
        final checks = switch ((write, field)) {
          (GameWrite.create, _) => ['game.${field.name} == request.time'],
          (_, GameField.lastPlayAt) => ['isPlayedNow()'],
          _ => ['isUpdatedNow()', 'isPlayedNow()'],
        };
        expect(checks.any(body.contains), isTrue, reason: '${write.name} writes ${field.name} unchecked');
      }
    }
  });

  test('the reader finds a function by its braces, wherever it is and however it is laid out', () {
    final shuffled = _Rules('''
      // function isJoin() { return false; }
      function isStart() { return true; }
      function   isJoin (  )
      {
        let nested = { 'a': 1 };
        return changedKeys().hasOnly(
          [ 'guestId',
            'updatedAt' ]
        );
      }
    ''');

    expect(shuffled.fieldsAllowedBy('isJoin'), {'guestId', 'updatedAt'});
  });
}

/// Reads `firestore.rules` by its syntax: a function is what its braces enclose, a list what its brackets enclose.
/// Comments, line breaks and the order of the functions do not matter.
final class _Rules {
  _Rules(String source) : _source = source.replaceAll(RegExp('//[^\n]*'), '');

  final String _source;

  String body(String function) {
    final declaration = RegExp('function\\s+$function\\s*\\(').firstMatch(_source);
    if (declaration == null) throw TestFailure('firestore.rules has no function $function');

    return _enclosed(_source, _source.indexOf('{', declaration.end), '{', '}');
  }

  /// The condition of `allow <operation>: if <condition>;`.
  String condition(String operation) {
    final allow = RegExp('allow\\s+$operation\\s*:\\s*if').firstMatch(_source);
    if (allow == null) throw TestFailure('firestore.rules allows no $operation');

    return _source.substring(allow.end, _source.indexOf(';', allow.end));
  }

  /// The quoted names in the `hasOnly([...])` of [function]: the fields its write may change.
  Set<String> fieldsAllowedBy(String function) {
    final body = this.body(function);
    final hasOnly = body.indexOf('hasOnly(');
    if (hasOnly < 0) throw TestFailure('$function has no hasOnly([...])');

    final list = _enclosed(body, body.indexOf('[', hasOnly), '[', ']');
    return {for (final name in RegExp("'([^']*)'").allMatches(list)) name.group(1) ?? ''};
  }

  static String _enclosed(String text, int start, String opening, String closing) {
    var depth = 0;
    for (var index = start; index < text.length; index++) {
      if (text[index] == opening) depth++;
      if (text[index] == closing && --depth == 0) return text.substring(start + 1, index);
    }
    throw TestFailure('No $closing closes the $opening at $start');
  }
}
