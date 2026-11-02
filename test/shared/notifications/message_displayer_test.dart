import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/notifications/message_displayer.dart';
import 'package:tic_tac_toe_app/shared/notifications/message_notifier.dart';

void main() {
  setUpAll(() async => I18n.load(const Locale('fr')));

  testWidgets('a message shows once, on the screen in front, even when the screen below displays messages too', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: const [I18n.delegate, ...GlobalMaterialLocalizations.delegates],
          supportedLocales: I18n.delegate.supportedLocales,
          locale: const Locale('fr'),
          home: const MessageDisplayer(child: Scaffold(body: Text('Home'))),
        ),
      ),
    );
    navigatorKey.currentState?.push(
      MaterialPageRoute<void>(builder: (_) => const MessageDisplayer(child: Scaffold(body: Text('Board')))),
    );
    await tester.pumpAndSettle();

    container.read(messageNotifierProvider.notifier).showMessage(InfoMessage.pleaseRetry);
    await tester.pumpAndSettle();
    expect(find.text(I18n.current.pleaseRetry), findsOneWidget);

    tester.state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger)).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    expect(find.text(I18n.current.pleaseRetry), findsNothing);
  });
}
