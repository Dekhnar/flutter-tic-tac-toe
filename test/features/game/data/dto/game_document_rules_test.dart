import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/data/dto/game_document.dart';

/// `firestore.rules` and [GameWrite] describe the same protocol twice: this keeps them in step, write by write.
void main() {
  final rules = File('firestore.rules').readAsStringSync();

  const ruleOf = {
    GameWrite.create: 'isCreatedByHost',
    GameWrite.join: 'isJoin',
    GameWrite.start: 'isStart',
    GameWrite.move: 'isMove',
    GameWrite.newRound: 'isNewRound',
    GameWrite.leave: 'isLeave',
  };

  /// The body of `function <name>(...) { ... }`, up to the next function.
  String bodyOf(String function) {
    final start = rules.indexOf(RegExp('function $function\\('));
    if (start < 0) throw TestFailure('firestore.rules has no function $function');

    final next = rules.indexOf('function ', start + 'function '.length);
    return rules.substring(start, next < 0 ? rules.length : next);
  }

  /// The quoted names of the first `hasOnly([...])` of [body]: the fields the rule lets the write change.
  Set<String> allowedFields(String body) {
    final list = RegExp(r'hasOnly\(\[([^\]]*)\]\)').firstMatch(body)?.group(1);
    if (list == null) throw TestFailure('No hasOnly([...]) in:\n$body');

    return {for (final match in RegExp(r"'(\w+)'").allMatches(list)) match.group(1)!};
  }

  for (final write in GameWrite.values) {
    test('the rules let the ${write.name} write change exactly the fields the app writes', () {
      final function = ruleOf[write] ?? (throw TestFailure('No rule mapped for ${write.name}'));

      expect(allowedFields(bodyOf(function)), {for (final field in write.fields) field.name});
    });
  }

  test('every write the app makes has a rule that allows it', () {
    final update = RegExp(r'allow update: if ([^;]*);').firstMatch(rules)?.group(1) ?? '';
    final create = RegExp(r'allow create: if ([^;]*);').firstMatch(rules)?.group(1) ?? '';

    for (final write in GameWrite.values) {
      final allowedBy = write == GameWrite.create ? create : update;
      expect(allowedBy, contains('${ruleOf[write]}()'), reason: write.name);
    }
  });

  test('the server checks the time of every write that carries one', () {
    for (final write in GameWrite.values) {
      final body = bodyOf(ruleOf[write]!);
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
}
