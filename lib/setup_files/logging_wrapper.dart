import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  // Internal Logger instance
  final Logger _logger = Logger(
    printer: PrettyPrinter(),
    output: kDebugMode ? ConsoleOutput() : null, // Only print in debug
  );

  // ------------------------
  // Debug log
  // ------------------------
  void d(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.d(message, error: error, stackTrace: stackTrace);
  }

  // ------------------------
  // Info log
  // ------------------------
  void i(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.i(message, error: error, stackTrace: stackTrace);
  }

  // ------------------------
  // Warning log
  // ------------------------
  void w(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.w(message, error: error, stackTrace: stackTrace);
  }

  // ------------------------
  // Error log
  // ------------------------
  void e(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.e(message, error: error, stackTrace: stackTrace);
  }

  // ------------------------
  // Verbose log
  // ------------------------
  void v(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.v(message, error: error, stackTrace: stackTrace);
  }

  // ------------------------
  // WTF log (extreme error)
  // ------------------------
  void f(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.f(message, error: error, stackTrace: stackTrace);
  }

  void t(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.t(message, error: error, stackTrace: stackTrace);
  }
}
