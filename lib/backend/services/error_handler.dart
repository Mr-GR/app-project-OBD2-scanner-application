import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralized error handling service for the OBD2 Scanner app
class ErrorHandler {
  static const String _tag = 'ErrorHandler';

  /// Handle and display user-friendly error messages
  static void handleError(
    BuildContext context,
    dynamic error, {
    String? errorContext,
    bool showSnackBar = true,
    VoidCallback? onRetry,
  }) {
    final errorMessage = _getUserFriendlyMessage(error);
    final errorDetails = _getErrorDetails(error);

    // Log the error
    _logError(error, errorContext, errorDetails);

    // Show user-friendly message
    if (showSnackBar) {
      _showErrorSnackBar(context, errorMessage, onRetry: onRetry);
    }
  }

  /// Get user-friendly error message
  static String _getUserFriendlyMessage(dynamic error) {
    if (error is String) {
      return error;
    }

    if (error.toString().contains('network')) {
      return 'Network connection error. Please check your internet connection.';
    }

    if (error.toString().contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (error.toString().contains('unauthorized') || error.toString().contains('401')) {
      return 'Authentication error. Please sign in again.';
    }

    if (error.toString().contains('not found') || error.toString().contains('404')) {
      return 'The requested resource was not found.';
    }

    if (error.toString().contains('server') || error.toString().contains('500')) {
      return 'Server error. Please try again later.';
    }

    if (error.toString().contains('bluetooth')) {
      return 'Bluetooth connection error. Please check your device connection.';
    }

    if (error.toString().contains('permission')) {
      return 'Permission denied. Please grant the required permissions.';
    }

    // Default error message
    return 'An unexpected error occurred. Please try again.';
  }

  /// Get detailed error information for logging
  static Map<String, dynamic> _getErrorDetails(dynamic error) {
    return {
      'error': error.toString(),
      'type': error.runtimeType.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      'stackTrace': error is Error ? error.stackTrace?.toString() : null,
    };
  }

  /// Log error for debugging
  static void _logError(dynamic error, String? errorContext, Map<String, dynamic> details) {
    print('[$_tag] Error in $errorContext: ${details['error']}');
    print('[$_tag] Error type: ${details['type']}');
    print('[$_tag] Timestamp: ${details['timestamp']}');
    
    if (details['stackTrace'] != null) {
      print('[$_tag] Stack trace: ${details['stackTrace']}');
    }
  }

  /// Show error snackbar with optional retry button
  static void _showErrorSnackBar(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) {
    if (!context.mounted) return;

    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red[600],
      duration: const Duration(seconds: 4),
      action: onRetry != null
          ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Show error dialog with more details
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String? details,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              if (details != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    details,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (onDismiss != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDismiss();
                },
                child: const Text('Dismiss'),
              ),
            if (onRetry != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('Retry'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Handle API errors specifically
  static void handleApiError(
    BuildContext context,
    dynamic error, {
    String? endpoint,
    VoidCallback? onRetry,
  }) {
    final contextInfo = endpoint != null ? 'API call to $endpoint' : 'API call';
    handleError(context, error, errorContext: contextInfo, onRetry: onRetry);
  }

  /// Handle network errors specifically
  static void handleNetworkError(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    handleError(
      context,
      'Network connection error',
      errorContext: 'Network operation',
      onRetry: onRetry,
    );
  }

  /// Handle Bluetooth errors specifically
  static void handleBluetoothError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
  }) {
    handleError(
      context,
      error,
      errorContext: 'Bluetooth operation',
      onRetry: onRetry,
    );
  }

  /// Copy error details to clipboard
  static void copyErrorToClipboard(dynamic error) {
    final errorText = '''
Error Details:
${error.toString()}

Timestamp: ${DateTime.now().toIso8601String()}
Type: ${error.runtimeType.toString()}
''';

    Clipboard.setData(ClipboardData(text: errorText));
  }
}

/// Custom exception classes for better error handling
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class BluetoothException extends AppException {
  BluetoothException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class ApiException extends AppException {
  final int? statusCode;

  ApiException(String message, {this.statusCode, String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
} 