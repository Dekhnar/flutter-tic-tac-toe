import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/design_system/foundations/theme.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';

import 'devices.dart';

/// Renders [scenario] on every [GoldenScreen] (`goldens/ci/<fileName>.<screen>.png`) and checks that every tap target
/// carries a label for screen readers.
void screenTestGolden(
  String scenario, {
  required ValueGetter<Widget> builder,
  required String fileName,
  Interaction? whilePerforming,
}) {
  group(scenario, () {
    for (final screen in GoldenScreen.values) {
      goldenTest(
        'renders on the ${screen.name} screen',
        fileName: '$fileName.${screen.name}',
        textScaleFactor: screen.textScaleFactor,
        whilePerforming: whilePerforming,
        builder:
            () => SizedBox.fromSize(
              size: screen.size,
              child: MaterialGolden(
                themeMode: screen.themeMode,
                child: switch (screen.showSemantics) {
                  true => SemanticsDebugger(child: builder()),
                  false => builder(),
                },
              ),
            ),
      );
    }

    testWidgets('labels every tap target for screen readers', (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(MaterialGolden(child: builder()));
        await tester.pumpAndSettle();
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      } finally {
        semanticsHandle.dispose();
      }
    });
  });
}

/// MaterialApp with the app themes and localizations.
class MaterialGolden extends StatelessWidget {
  final Widget child;
  final ThemeMode? themeMode;
  final TargetPlatform platform;

  const MaterialGolden({
    super.key,
    required this.child,
    this.themeMode = ThemeMode.dark,
    this.platform = TargetPlatform.android,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        I18n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      supportedLocales: I18n.delegate.supportedLocales,
      locale: const Locale('fr'),
      themeMode: themeMode,
      theme: ThemeBuilder.buildLightThemeData().copyWith(platform: platform),
      darkTheme: ThemeBuilder.buildDarkThemeData().copyWith(platform: platform),
      home: Material(child: child),
    );
  }
}
