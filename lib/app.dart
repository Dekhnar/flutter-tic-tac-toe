import 'package:flutter/material.dart';

import 'package:tic_tac_toe_app/design_system/foundations/theme.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/routing/app_router.dart';

class App extends StatefulWidget {
  const App({super.key});

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
      localizationsDelegates: I18n.localizationsDelegates,
      supportedLocales: I18n.supportedLocales,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      routerDelegate: _appRouter.delegate(deepLinkBuilder: AppRouter.openBoardsFromHome),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}
