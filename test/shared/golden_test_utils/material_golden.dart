import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meta/meta.dart';
import 'package:tic_tac_toe_app/design_system/foundations/theme.dart';

import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'devices.dart';

typedef WidgetProvider = ValueGetter<Widget>;
typedef WidgetTesterHook = WidgetTesterCallback;
typedef WidgetTesterHookSync = FutureOr<void> Function(WidgetTester tester);

const Size _defaultSize = Size(800, 600);
final _semanticsDebuggerDefaultFontFamily = GoogleFonts.raleway(color: Colors.black, fontSize: 10, height: 0.8);

@isTestGroup
void screenTestGolden(
  String screenName, {
  required String tag,
  required WidgetProvider builder,
  WidgetTesterHook? whenWidgetPumped,
  WidgetTesterHookSync? beforeWidgetPump,
  int? pumpMillis,
  bool showSemanticsDebugger = true,
  bool skipLabeledTapTargetGuideline = false,
  bool skipTapTargetSizeGuideline = false,
  bool skipContrastGuideline = true,
  bool withTabletScreens = false,
  bool withLandscapeScreens = false,
  bool withLightModeScreen = true,
  bool semanticAccessibleNavigation = false,
  Finder? finder,
  double? semanticPhoneHeight,
  TargetPlatform platform = TargetPlatform.android,
  Size? surfaceSize,
  bool autoHeight = true,
  Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates,
}) {
  group(screenName, (() {
    testGoldens('Test Semantics Golden $screenName', (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      try {
        await _runGoldenTest(
          tester: tester,
          widget: builder(),
          tag: tag,
          themeMode: ThemeMode.dark,
          whenWidgetPumped: whenWidgetPumped,
          beforeWidgetPump: beforeWidgetPump,
          devices: [
            (semanticPhoneHeight != null)
                ? Devices.semanticsScreen.copyWith(size: Size(Devices.semanticsScreen.size.width, semanticPhoneHeight))
                : Devices.semanticsScreen,
          ],
          finder: finder ?? find.byKey(Key(tag)),
          showSemanticsDebugger: showSemanticsDebugger,
          semanticAccessibleNavigation: semanticAccessibleNavigation,
          localizationsDelegates: localizationsDelegates,
          autoHeight: autoHeight,
        );

        // Vérifie les guidelines accessibilité
        if (skipContrastGuideline && skipTapTargetSizeGuideline && skipLabeledTapTargetGuideline) {
          await _checkTextContrast(tester);
        } else {
          await _testA11y(tester, skipLabeledTapTargetGuideline, skipContrastGuideline, skipTapTargetSizeGuideline);
        }
      } finally {
        semanticsHandle.dispose();
      }
    });

    testGoldens('Test dark theme Golden $screenName', (tester) async {
      final screens = Devices.screens(
        includeLandscapeMode: withLandscapeScreens,
        includeTabletLandscape: withTabletScreens,
      );

      await _runGoldenTest(
        tester: tester,
        widget: builder(),
        tag: tag,
        themeMode: ThemeMode.dark,
        whenWidgetPumped: whenWidgetPumped,
        beforeWidgetPump: beforeWidgetPump,
        devices: screens,
        finder: finder ?? find.byKey(Key(tag)),
        platform: platform,
        surfaceSize: surfaceSize,
        localizationsDelegates: localizationsDelegates,
        autoHeight: autoHeight,
      );
    });

    testGoldens('Test light theme Golden $screenName', (tester) async {
      await _runGoldenTest(
        tester: tester,
        widget: builder(),
        tag: tag,
        themeMode: ThemeMode.light,
        whenWidgetPumped: whenWidgetPumped,
        beforeWidgetPump: beforeWidgetPump,
        devices: [Devices.lightModeScreen],
        finder: finder ?? find.byKey(Key(tag)),
        platform: platform,
        surfaceSize: surfaceSize,
        localizationsDelegates: localizationsDelegates,
        autoHeight: autoHeight,
      );
    });
  }));
}

Future<void> _runGoldenTest({
  required WidgetTester tester,
  required Widget widget,
  required String tag,
  required ThemeMode themeMode,
  WidgetTesterHook? whenWidgetPumped,
  WidgetTesterHookSync? beforeWidgetPump,
  List<Device>? devices,
  Finder? finder,
  TargetPlatform? platform,
  Size? surfaceSize,
  Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates,
  bool showSemanticsDebugger = false,
  bool semanticAccessibleNavigation = false,
  bool autoHeight = true,
}) async {
  try {
    await beforeWidgetPump?.call(tester);

    await tester.pumpWidgetBuilder(
      MaterialGolden(
        key: Key(tag),
        themeMode: themeMode,
        platform: platform ?? TargetPlatform.android,
        localizationsDelegates: localizationsDelegates,
        showSemanticsDebugger: showSemanticsDebugger,
        child: widget,
      ),
      wrapper:
          (child) => switch (showSemanticsDebugger) {
            true => SemanticsDebugger(
              labelStyle: _semanticsDebuggerDefaultFontFamily,
              child: _MediaQueryCustomizer(accessibleNavigation: semanticAccessibleNavigation, child: child),
            ),
            false => child,
          },
      surfaceSize: surfaceSize ?? _defaultSize,
    );

    await whenWidgetPumped?.call(tester);

    await multiScreenGolden(
      tester,
      tag,
      devices: devices,
      finder: finder ?? find.byKey(Key(tag)),
      autoHeight: autoHeight,
    );
  } finally {
    debugNetworkImageHttpClientProvider = null;
  }
}

/// MediaQuery personnalisé pour accessibleNavigation
class _MediaQueryCustomizer extends StatelessWidget {
  final bool accessibleNavigation;
  final Widget child;

  const _MediaQueryCustomizer({required this.accessibleNavigation, required this.child});

  @override
  Widget build(BuildContext context) =>
      MediaQuery(data: MediaQuery.of(context).copyWith(accessibleNavigation: accessibleNavigation), child: child);
}

/// MaterialApp wrapper avec thèmes, localisations et plateformes
class MaterialGolden extends StatelessWidget {
  final Widget child;
  final List<NavigatorObserver>? navigatorObservers;
  final ThemeMode? themeMode;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final TargetPlatform platform;
  final bool showSemanticsDebugger;

  const MaterialGolden({
    super.key,
    required this.child,
    this.navigatorObservers,
    this.themeMode = ThemeMode.dark,
    this.platform = TargetPlatform.android,
    this.localizationsDelegates,
    this.showSemanticsDebugger = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: navigatorObservers ?? const [],
      localizationsDelegates: [
        I18n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ...?localizationsDelegates,
      ],
      debugShowCheckedModeBanner: false,
      showSemanticsDebugger: showSemanticsDebugger,
      supportedLocales: I18n.delegate.supportedLocales,
      locale: const Locale('fr'),
      themeMode: themeMode,
      theme: ThemeBuilder.buildLightThemeData().copyWith(platform: platform),
      darkTheme: ThemeBuilder.buildDarkThemeData().copyWith(platform: platform),
      home: Material(child: child),
    );
  }
}

/// Vérifie plusieurs guidelines d’accessibilité Flutter
///
/// Ces règles permettent de garantir que ton interface :
/// - est lisible (contraste du texte)
/// - est utilisable facilement (zones tapables assez grandes)
/// - est accessible aux lecteurs d’écran (labels disponibles)
///
/// Chaque règle peut être ignorée individuellement via un booléen `skip...`
Future<void> _testA11y(
  WidgetTester tester,
  bool skipLabeledTapTargetGuideline,
  bool skipContrastGuideline,
  bool skipTapTargetSizeGuideline,
) async {
  // 1️⃣ Vérifie que tous les éléments interactifs (boutons, icônes, etc.)
  // ont un label d’accessibilité (pour TalkBack, VoiceOver, etc.)
  //
  // Exemple :
  // ❌  IconButton(icon: Icon(Icons.close), onPressed: () {})
  // ✅  IconButton(icon: Icon(Icons.close), tooltip: 'Fermer', onPressed: () {})
  if (!skipLabeledTapTargetGuideline) {
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  }

  // 2️⃣ Vérifie le contraste du texte par rapport à son fond.
  // S’assure que les couleurs respectent les normes WCAG (≥4.5:1)
  //
  // Exemple :
  // ❌ Text('Annuler', style: TextStyle(color: Colors.grey[400])) sur fond blanc
  // ✅ Text('Annuler', style: TextStyle(color: Colors.grey[800])) sur fond blanc
  if (!skipContrastGuideline) {
    await _checkTextContrast(tester);
  }

  // 3️⃣ Vérifie la taille minimale des zones cliquables
  // (au moins 48x48px sur Android, 44x44px sur iOS)
  //
  // Exemple :
  // ❌ GestureDetector(onTap: () {}, child: Icon(Icons.add, size: 20))
  // ✅ GestureDetector(onTap: () {}, child: Padding(padding: EdgeInsets.all(12), child: Icon(Icons.add, size: 20)))
  if (!skipTapTargetSizeGuideline) {
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  }
}

/// Vérifie uniquement le contraste du texte.
///
/// Pratique pour les tests rapides de lisibilité,
/// sans lancer tous les contrôles d’accessibilité complets.
Future<void> _checkTextContrast(WidgetTester tester) => expectLater(tester, meetsGuideline(textContrastGuideline));
