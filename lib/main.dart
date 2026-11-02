import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe_app/app.dart';
import 'package:tic_tac_toe_app/composition.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_handlers.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The handlers catch what fails during startup too: until the app's logger exists, errors go to the console.
  ErrorLogger errorLogger = const DeveloperErrorLogger();
  registerErrorHandlers(() => errorLogger);

  final container = await createAppContainer();
  errorLogger = container.read(errorLoggerProvider);
  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
