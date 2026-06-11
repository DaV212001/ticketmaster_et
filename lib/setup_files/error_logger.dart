// import 'dart:async';
// import 'dart:io';
//
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:logger/logger.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:stack_trace/stack_trace.dart';
// import 'package:url_launcher/url_launcher.dart';
//
//
// class ErrorLogger {
//   static final Logger _logger = Logger(
//     printer: PrettyPrinter(
//       methodCount: 2, // Number of method calls to be displayed
//       errorMethodCount: 8, // Number of method calls if stacktrace is provided
//       lineLength: 120, // Width of the output
//       colors: true, // Colorful log messages
//       printEmojis: true, // Print an emoji for each log message
//       printTime: true, // Print timestamps
//     ),
//   );
//
//   static const String _logFileName = 'error_logs.txt';
//   static const int _maxLogFiles = 5; // Maximum number of log files to keep
//   static const int _maxLogSize = 5 * 1024 * 1024; // 5MB max log file size
//
//   /// Logs an error with stack trace to both console and file
//   static Future<void> logError(dynamic error, StackTrace? stackTrace) async {
//     _logger.e(error, stackTrace: stackTrace);
//     final timestampIso = DateTime.now().toIso8601String();
//     final timestampLocal = DateTime.now().toString();
//
//     // Format stack trace
//     final trace = stackTrace != null
//         ? Trace.from(stackTrace).terse.toString()
//         : 'No stack trace available';
//
//     // Base error message
//     String errorMessage = error?.toString() ?? 'Unknown error';
//
//     // Extra context for Dio errors
//     String dioContext = '';
//     if (error is DioException) {
//       final req = error.requestOptions;
//       dioContext =
//           '''
// [REQUEST CONTEXT]
// URL: ${req.uri}
// METHOD: ${req.method}
// HEADERS: ${req.headers}
// BODY: ${req.data}
// ''';
//     }
//
//     final errorLog =
//         '''
// [ERROR] $timestampIso ($timestampLocal)
// $errorMessage
// $dioContext
// STACKTRACE:
// $trace
// ----------------------------------------
// ''';
//
//     try {
//       final file = await _getLogFile();
//       if (await file.exists() && await file.length() > _maxLogSize) {
//         await _rotateLogs();
//       }
//       await file.writeAsString(errorLog, mode: FileMode.append);
//
//       // Also log to console for convenience
//       _logger.e(errorMessage, error: error, stackTrace: stackTrace);
//     } catch (e, s) {
//       _logger.t('Failed to write error log to file: $e', stackTrace: s);
//     }
//   }
//
//   /// Gets the log file, creates it if it doesn't exist
//   static Future<File> _getLogFile() async {
//     // Get external storage directory (accessible to user)
//     Directory? directory = await getExternalStorageDirectory();
//
//     // Optional: you can create a subfolder for your app
//     final logDir = Directory('${directory!.path}/EnderaseLogs');
//     if (!await logDir.exists()) {
//       await logDir.create(recursive: true);
//     }
//
//     final file = File('${logDir.path}/$_logFileName');
//
//     if (!await file.exists()) {
//       return await file.create(recursive: true);
//     }
//
//     return file;
//   }
//
//   /// Rotates log files when they reach the maximum size
//   /// Rotates log files when they reach the maximum size
//   static Future<void> _rotateLogs() async {
//     try {
//       final directory = await getExternalStorageDirectory();
//       final logDir = Directory('${directory!.path}/EnderaseLogs');
//       if (!await logDir.exists()) {
//         await logDir.create(recursive: true);
//       }
//
//       final currentLog = File('${logDir.path}/$_logFileName');
//
//       // Delete the oldest log file if we've reached max files
//       final oldestLog = File(
//         '${logDir.path}/$_logFileName.${_maxLogFiles - 1}',
//       );
//       if (await oldestLog.exists()) {
//         await oldestLog.delete();
//       }
//
//       // Rotate existing log files
//       for (var i = _maxLogFiles - 2; i >= 0; i--) {
//         final oldFile = File(
//           '${logDir.path}/$_logFileName${i > 0 ? '.$i' : ''}',
//         );
//         if (await oldFile.exists()) {
//           await oldFile.rename('${logDir.path}/$_logFileName.${i + 1}');
//         }
//       }
//
//       // Create a new empty log file
//       await currentLog.writeAsString('');
//     } catch (e) {
//       _logger.e('Error rotating log files: $e');
//     }
//   }
//
//   /// Gets all log files including rotated ones
//   static Future<List<File>> getAllLogFiles() async {
//     try {
//       final directory = await getExternalStorageDirectory();
//       final logDir = Directory('${directory!.path}/EnderaseLogs');
//       if (!await logDir.exists()) {
//         return [];
//       }
//
//       final logFiles = <File>[];
//
//       // Add the main log file
//       final mainLog = File('${logDir.path}/$_logFileName');
//       if (await mainLog.exists()) {
//         logFiles.add(mainLog);
//       }
//
//       // Add rotated log files
//       for (var i = 1; i <= _maxLogFiles; i++) {
//         final logFile = File('${logDir.path}/$_logFileName.$i');
//         if (await logFile.exists()) {
//           logFiles.add(logFile);
//         }
//       }
//
//       return logFiles;
//     } catch (e) {
//       _logger.e('Failed to get log files: $e');
//       return [];
//     }
//   }
//
//   /// Reads the error log file
//   static Future<String> readErrorLogs() async {
//     try {
//       final file = await _getLogFile();
//       if (await file.exists()) {
//         return await file.readAsString();
//       }
//       return 'No error logs found';
//     } catch (e) {
//       _logger.e('Failed to read error log: $e');
//       return 'Failed to read error log: $e';
//     }
//   }
//
//   /// Clears the error log file
//   static Future<void> clearErrorLogs() async {
//     try {
//       final file = await _getLogFile();
//       if (await file.exists()) {
//         await file.writeAsString('');
//       }
//     } catch (e) {
//       _logger.e('Failed to clear error log: $e');
//       rethrow;
//     }
//   }
//
//   /// Gets all log files including rotated ones
//   // static Future<List<File>> getAllLogFiles() async {
//   //   try {
//   //     final directory = await getApplicationDocumentsDirectory();
//   //     final logFiles = <File>[];
//   //
//   //     // Add the main log file
//   //     final mainLog = File('${directory.path}/$_logFileName');
//   //     if (await mainLog.exists()) {
//   //       logFiles.add(mainLog);
//   //     }
//   //
//   //     // Add rotated log files
//   //     for (var i = 1; i <= _maxLogFiles; i++) {
//   //       final logFile = File('${directory.path}/$_logFileName.$i');
//   //       if (await logFile.exists()) {
//   //         logFiles.add(logFile);
//   //       }
//   //     }
//   //
//   //     return logFiles;
//   //   } catch (e) {
//   //     _logger.e('Failed to get log files: $e');
//   //     return [];
//   //   }
//   // }
//
//   /// Shares error logs via Telegram or other sharing options
//   static Future<void> shareErrorLogs() async {
//     try {
//       final logFiles = await getAllLogFiles();
//
//       if (logFiles.isEmpty) {
//         _logger.i('No error logs found to share');
//         Get.snackbar('No Logs', 'No error logs found to share');
//         return;
//       }
//
//       // Sort files by modification time (newest first)
//       logFiles.sort(
//         (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
//       );
//
//       // Get the most recent log file
//       final latestLog = logFiles.first;
//
//       // Create a temporary directory to store the log file
//       final tempDir = await getTemporaryDirectory();
//       final tempFile = File(
//         '${tempDir.path}/error_log_${DateTime.now().millisecondsSinceEpoch}.txt',
//       );
//
//       // Copy the log file to the temp directory
//       await tempFile.writeAsString(await latestLog.readAsString());
//
//       // Share the file
//       await SharePlus.instance.share(
//         ShareParams(
//           files: [XFile(tempFile.path)],
//           text: 'Error Logs from MATIF App',
//           subject: 'MATIF App Error Logs',
//         ),
//       );
//
//       // Clean up the temporary file after sharing
//       try {
//         await tempFile.delete();
//       } catch (e) {
//         _logger.e('Failed to delete temporary log file: $e');
//       }
//     } catch (e, stackTrace) {
//       _logger.e('Failed to share error logs', error: e, stackTrace: stackTrace);
//       rethrow;
//     }
//   }
//
//   /// Opens Telegram with a pre-filled message to the support account
//   static Future<bool> contactSupportOnTelegram() async {
//     const String supportUsername = 'solivagant22D_a_V';
//     const String message =
//         'Hello, I need help with an issue in the Mamito app.';
//     final url =
//         'https://t.me/$supportUsername?text=${Uri.encodeComponent(message)}';
//
//     if (await canLaunchUrl(Uri.parse(url))) {
//       return await launchUrl(
//         Uri.parse(url),
//         mode: LaunchMode.externalApplication,
//       );
//     } else {
//       _logger.e('Could not launch Telegram');
//       return false;
//     }
//   }
//
//   /// Shows a dialog with options to report an error
//   ///
//   /// [context] Optional BuildContext. If not provided, Get.context will be used
//   /// [title] Optional title for the dialog
//   /// [message] Optional message to display in the dialog
//   /// [showContactOption] Whether to show the contact support option
//   static Future<void> showErrorReportDialog({
//     BuildContext? context,
//     String? title,
//     String? message,
//     bool showContactOption = true,
//   }) async {
//     await ErrorReportDialog.show(
//       context: context,
//       title: title,
//       message: message,
//       showContactOption: showContactOption,
//     );
//   }
// }
