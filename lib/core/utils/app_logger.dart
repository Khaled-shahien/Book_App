import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Central logging / error-reporting seam.
///
/// Logs only in debug and profile builds, so tokens, queries and PII never
/// reach release logs. [reportError] is the single place to plug in a crash
/// reporter (e.g. Firebase Crashlytics) — see docs/HUMAN_ACTIONS.md.
abstract final class AppLogger {
  /// Optional hook for a crash reporter; set once in `main()`.
  static void Function(Object error, StackTrace? stack, {bool fatal})?
  errorReporter;

  static void debug(String message) {
    if (!kReleaseMode) developer.log(message, name: 'book_app');
  }

  static void reportError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) {
    if (!kReleaseMode) {
      developer.log(
        reason ?? 'error',
        name: 'book_app',
        error: error,
        stackTrace: stack,
      );
    }
    errorReporter?.call(error, stack, fatal: fatal);
  }
}
