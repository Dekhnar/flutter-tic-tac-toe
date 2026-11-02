import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_handlers.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';

void main() {
  late FlutterExceptionHandler? frameworkHandler;
  late bool Function(Object, StackTrace)? platformHandler;
  late ErrorWidgetBuilder errorWidgetBuilder;

  setUp(() {
    frameworkHandler = FlutterError.onError;
    platformHandler = PlatformDispatcher.instance.onError;
    errorWidgetBuilder = ErrorWidget.builder;
  });

  tearDown(() {
    FlutterError.onError = frameworkHandler;
    PlatformDispatcher.instance.onError = platformHandler;
    ErrorWidget.builder = errorWidgetBuilder;
  });

  test('an error the framework did not catch is reported as fatal, to the logger the app has by then', () {
    final duringStartup = _RecordingLogger();
    final afterStartup = _RecordingLogger();
    var current = duringStartup;
    registerErrorHandlers(() => current);
    current = afterStartup;

    FlutterError.onError?.call(FlutterErrorDetails(exception: StateError('layout broke'), silent: true));

    expect(duringStartup.errors, isEmpty);
    expect(afterStartup.errors, [_isLogged(isA<StateError>(), fatal: true)]);
  });

  test('an error outside the framework is reported as fatal, and handled', () {
    final logger = _RecordingLogger();
    registerErrorHandlers(() => logger);

    final handled = PlatformDispatcher.instance.onError?.call(Exception('channel closed'), StackTrace.current);

    expect(handled, isTrue);
    expect(logger.errors, [_isLogged(isA<Exception>(), fatal: true)]);
  });
}

Matcher _isLogged(Matcher error, {required bool fatal}) =>
    isA<(Object, bool)>().having((logged) => logged.$1, 'error', error).having((logged) => logged.$2, 'fatal', fatal);

final class _RecordingLogger implements ErrorLogger {
  final errors = <(Object, bool)>[];

  @override
  void log(Object error, StackTrace? stackTrace, {bool fatal = false}) => errors.add((error, fatal));
}
