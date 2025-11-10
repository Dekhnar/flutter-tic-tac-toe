import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tic_tac_toe_app/design_system/components/data_display/animated_splash.dart';
import 'package:tic_tac_toe_app/design_system/components/feedback/base_loading_retry_button.dart';
import 'package:tic_tac_toe_app/design_system/foundations/assets.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/routing/app_router_provider.dart';
import 'package:tic_tac_toe_app/shared/bootstrap/bootstrap_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  static const localizationsDelegates = <LocalizationsDelegate>[
    I18n.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    DefaultCupertinoLocalizations.delegate,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrapState = ref.watch(bootstrapServiceProvider);
    final boostrapData = bootstrapState.valueOrNull;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: localizationsDelegates,
      supportedLocales: I18n.delegate.supportedLocales,
      locale: boostrapData?.locale,
      theme: boostrapData?.theme,
      darkTheme: boostrapData?.darkTheme,
      themeMode: boostrapData?.themeMode,
      routerDelegate: ref.watch(appRouterProvider).delegate(navigatorObservers: () => [AutoRouteObserver()]),
      routeInformationParser: ref.watch(appRouterProvider).defaultRouteParser(),
      builder: (context, child) {
        return switch (bootstrapState) {
          final state when state.isLoading => Scaffold(
            body: Center(child: BaseAnimatedSplash(imagePath: Assets.images.appIcon)),
          ),
          AsyncError() => Scaffold(
            body: Center(child: BaseLoadingRetryButton(onPressed: () => ref.refresh(bootstrapServiceProvider))),
          ),
          AsyncData() => child ?? const SizedBox.shrink(),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}
