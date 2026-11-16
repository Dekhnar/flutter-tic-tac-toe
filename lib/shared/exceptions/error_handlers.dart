import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';

/// Reports every error nothing caught — in the framework, or anywhere else — as fatal to [errorLogger], which is
/// read at report time: the handlers can be set before the app's logger exists.
/// See https://docs.flutter.dev/testing/errors.
void registerErrorHandlers(ErrorLogger Function() errorLogger) {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    errorLogger().log(details.exception, details.stack, fatal: true);
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    errorLogger().log(error, stackTrace, fatal: true);
    return true;
  };
  ErrorWidget.builder = (details) => _BrokenWidget(details: details);
}

/// Replaces a widget that failed to build; the details only show in debug builds.
class _BrokenWidget extends StatelessWidget {
  const _BrokenWidget({required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final message =
        kDebugMode
            ? details.toString()
            : Localizations.of<I18n>(context, I18n)?.errorRetryLater ?? 'An error occurred.';

    return Material(
      color: colors.error,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimens.standardPadding),
          child: Text(message, style: TextStyle(color: colors.onError)),
        ),
      ),
    );
  }
}
