import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The layers the README describes, kept by what each file of `lib/` imports.
void main() {
  final imports = _importsOfLib();

  /// Fails with every import of a file matching [from] that matches [forbidden].
  void expectNoImport({required bool Function(String file) from, required bool Function(String uri) forbidden}) {
    final violations = [
      for (final MapEntry(key: file, value: uris) in imports.entries)
        if (from(file))
          for (final uri in uris)
            if (forbidden(uri)) '$file imports $uri',
    ];
    expect(violations, isEmpty);
  }

  bool isFirebase(String uri) => uri.startsWith('package:firebase_') || uri.startsWith('package:cloud_firestore/');

  test('every import names its package, so that the rules below see where it leads', () {
    expect(imports, contains('lib/composition.dart'));
    expectNoImport(from: (_) => true, forbidden: (uri) => !uri.startsWith('package:') && !uri.startsWith('dart:'));
  });

  test('the domain is plain Dart, independent of every other layer and package', () {
    const allowed = [
      'dart:',
      'package:freezed_annotation/',
      'package:tic_tac_toe_app/features/game/domain/',
      'package:tic_tac_toe_app/shared/exceptions/expected_exception.dart',
    ];

    expectNoImport(from: (file) => file.contains('/domain/'), forbidden: (uri) => !allowed.any(uri.startsWith));
  });

  test('the application layer uses the domain, never an implementation, a screen or Flutter', () {
    expectNoImport(
      from: (file) => file.contains('/application/'),
      forbidden:
          (uri) =>
              uri.contains('/data/') ||
              uri.contains('/presentation/') ||
              uri.startsWith('package:flutter/') ||
              isFirebase(uri),
    );
  });

  test('the presentation layer never reaches an implementation', () {
    expectNoImport(
      from: (file) => file.contains('/presentation/'),
      forbidden: (uri) => uri.contains('/game/data/') || isFirebase(uri),
    );
  });

  test('the data layer implements the domain, and knows nothing of the layers above it', () {
    expectNoImport(
      from: (file) => file.contains('/game/data/'),
      forbidden: (uri) => uri.contains('/application/') || uri.contains('/presentation/'),
    );
  });

  test('only the composition root picks the implementations', () {
    expectNoImport(
      from: (file) => file != 'lib/composition.dart' && !file.contains('/game/data/') && !file.contains('/firebase/'),
      forbidden: (uri) => uri.contains('/game/data/') || uri.contains('/shared/firebase/'),
    );
  });

  test('the design system and the shared code know no feature', () {
    expectNoImport(
      from: (file) => file.startsWith('lib/design_system/') || file.startsWith('lib/shared/'),
      forbidden: (uri) => uri.contains('/features/'),
    );
  });

  test('a feature knows nothing of the app around it: its router, its composition', () {
    const app = [
      'package:tic_tac_toe_app/routing/',
      'package:tic_tac_toe_app/composition.dart',
      'package:tic_tac_toe_app/app.dart',
    ];

    expectNoImport(from: (file) => file.startsWith('lib/features/'), forbidden: (uri) => app.any(uri.startsWith));
  });
}

/// The imports and exports of each hand-written file of `lib/`.
Map<String, List<String>> _importsOfLib() {
  final directive = RegExp(r'''^(?:import|export)\s+['"]([^'"]+)['"]''', multiLine: true);
  final generated = RegExp(r'\.(g|freezed|gr)\.dart$');

  return {
    for (final file in Directory('lib').listSync(recursive: true).whereType<File>())
      if (file.path.endsWith('.dart') && !generated.hasMatch(file.path) && !file.path.startsWith('lib/generated/'))
        file.path: [for (final match in directive.allMatches(file.readAsStringSync())) match.group(1) ?? ''],
  };
}
