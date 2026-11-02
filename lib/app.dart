import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:tic_tac_toe_app/design_system/foundations/theme.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/routing/auto_router.dart';

/// Theme and language follow the device settings, including while the app runs.
class App extends StatefulWidget {
  const App({super.key});

  static const localizationsDelegates = <LocalizationsDelegate>[
    I18n.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _appRouter = AppRouter();
  final _darkTheme = ThemeBuilder.buildDarkThemeData();
  final _lightTheme = ThemeBuilder.buildLightThemeData();

  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: App.localizationsDelegates,
      supportedLocales: I18n.delegate.supportedLocales,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      routerDelegate: _appRouter.delegate(deepLinkBuilder: AppRouter.openBoardsFromHome),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}
