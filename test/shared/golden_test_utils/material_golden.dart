import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tic_tac_toe_app/design_system/foundations/theme.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';

import 'devices.dart';

final _semanticsLabelStyle = GoogleFonts.raleway(color: Colors.black, fontSize: 10, height: 0.8);

/// Renders [scenario] on every [GoldenScreen] (`goldens/<fileName>.<screen>.png`) and checks it against the
/// accessibility guidelines: labelled tap targets of the minimum size on both platforms, and readable text contrast.
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
        pumpWidget: (tester, goldenTree) => _pumpOnScreen(tester, screen, goldenTree),
        whilePerforming: switch (screen.showSemantics) {
          true => _thenRepaintSemantics(whilePerforming),
          false => whilePerforming,
        },
        builder:
            () => _AutoHeightScreen(
              size: screen.size,
              child: MaterialGolden(themeMode: screen.themeMode, child: builder()),
            ),
      );
    }

    for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('meets the accessibility guidelines in ${themeMode.name} mode', (tester) async {
        final semanticsHandle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(MaterialGolden(themeMode: themeMode, child: builder()));
          await tester.pumpAndSettle();
          await whilePerforming?.call(tester);
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
        } finally {
          semanticsHandle.dispose();
        }
      });
    }
  });
}

/// Alchemist pumps the scenario under its own Navigator, which is the one dialogs open in: the safe area and the
/// semantics debugger wrap that whole tree so dialogs get them too.
Future<void> _pumpOnScreen(WidgetTester tester, GoldenScreen screen, Widget goldenTree) async {
  final safeArea = screen.safeArea;
  tester.view.padding = FakeViewPadding(top: safeArea.top, bottom: safeArea.bottom);
  tester.view.viewPadding = FakeViewPadding(top: safeArea.top, bottom: safeArea.bottom);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(switch (screen.showSemantics) {
    true => SemanticsDebugger(labelStyle: _semanticsLabelStyle, child: goldenTree),
    false => goldenTree,
  });
}

/// The semantics debugger paints the tree of the previous frame: one more frame shows the final one.
Interaction _thenRepaintSemantics(Interaction? interaction) => (tester) async {
  final cleanup = await interaction?.call(tester);
  tester.binding.scheduleFrame();
  await tester.pump();
  return cleanup;
};

/// Grows the screen by whatever its vertical scroll view cannot show, so the golden captures the whole content.
class _AutoHeightScreen extends StatefulWidget {
  const _AutoHeightScreen({required this.child, required this.size});

  final Widget child;
  final Size size;

  @override
  State<_AutoHeightScreen> createState() => _AutoHeightScreenState();
}

class _AutoHeightScreenState extends State<_AutoHeightScreen> {
  late double _height = widget.size.height;

  bool _growToFit(ScrollMetricsNotification notification) {
    final hiddenHeight = notification.metrics.maxScrollExtent;
    if (notification.depth == 0 && notification.metrics.axis == Axis.vertical && hiddenHeight > 0) {
      setState(() => _height += hiddenHeight);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: _growToFit,
      child: SizedBox(width: widget.size.width, height: _height, child: widget.child),
    );
  }
}

/// MaterialApp with the app themes and localizations.
class MaterialGolden extends StatelessWidget {
  final Widget child;
  final TargetPlatform platform;
  final ThemeMode? themeMode;

  const MaterialGolden({
    super.key,
    required this.child,
    this.platform = TargetPlatform.android,
    this.themeMode = ThemeMode.dark,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: I18n.localizationsDelegates,
      debugShowCheckedModeBanner: false,
      supportedLocales: I18n.supportedLocales,
      locale: const Locale('fr'),
      themeMode: themeMode,
      theme: ThemeBuilder.buildLightThemeData().copyWith(platform: platform),
      darkTheme: ThemeBuilder.buildDarkThemeData().copyWith(platform: platform),
      home: Material(child: child),
    );
  }
}
