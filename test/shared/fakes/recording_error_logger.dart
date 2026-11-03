import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';

final class RecordingErrorLogger implements ErrorLogger {
  final reports = <({Object error, bool fatal})>[];

  List<Object> get errors => [for (final report in reports) report.error];

  @override
  void log(Object error, StackTrace? stackTrace, {bool fatal = false}) => reports.add((error: error, fatal: fatal));
}
