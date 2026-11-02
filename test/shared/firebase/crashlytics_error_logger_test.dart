import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/shared/firebase/crashlytics_error_logger.dart';

void main() {
  late _RecordingCrashlytics crashlytics;
  late CrashlyticsErrorLogger logger;

  setUp(() {
    crashlytics = _RecordingCrashlytics();
    logger = CrashlyticsErrorLogger(crashlytics);
  });

  test('an error nothing caught becomes a fatal crash report', () {
    logger.log(StateError('broken'), StackTrace.current, fatal: true);

    expect(crashlytics.reports, [_isReport(isA<StateError>(), true)]);
  });

  test('an unexpected error the app caught becomes a non-fatal report', () {
    logger.log(Exception('network unreachable'), StackTrace.current);

    expect(crashlytics.reports, [_isReport(isA<Exception>(), false)]);
    expect(crashlytics.breadcrumbs, isEmpty);
  });

  test('a refusal the player was told about is only a breadcrumb of the next report', () {
    logger.log(MoveNotYourTurnException(), null);

    expect(crashlytics.reports, isEmpty);
    expect(crashlytics.breadcrumbs, [contains('move_not_your_turn')]);
  });
}

Matcher _isReport(Matcher error, bool fatal) =>
    isA<(Object, bool)>().having((report) => report.$1, 'error', error).having((report) => report.$2, 'fatal', fatal);

final class _RecordingCrashlytics implements FirebaseCrashlytics {
  final breadcrumbs = <String>[];
  final reports = <(Object, bool)>[];

  @override
  Future<void> log(String message) async => breadcrumbs.add(message);

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool? printDetails,
    bool fatal = false,
  }) async => reports.add((exception as Object, fatal));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
