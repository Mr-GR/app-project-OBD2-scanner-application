import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../flutter_flow/flutter_flow_theme.dart';

class EnhancedErrorHandler {
  static void showUserFriendlyError(
    BuildContext context,
    String error, {
    String? title,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title ?? 'Error',
        message: error,
        onRetry: onRetry,
        onDismiss: onDismiss,
      ),
    );
  }

  static void showToast(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => ToastWidget(
        message: message,
        type: type,
        duration: duration,
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  static Future<bool> retryOperation(
    Future<bool> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final result = await operation();
        if (result) return true;
      } catch (e) {
        if (i == maxRetries - 1) rethrow;
      }
      
      if (i < maxRetries - 1) {
        await Future.delayed(delay * (i + 1));
      }
    }
    return false;
  }

  static String getErrorMessage(dynamic error) {
    if (error is String) return error;
    
    if (error.toString().contains('network')) {
      return 'Network connection error. Please check your internet connection.';
    }
    
    if (error.toString().contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    if (error.toString().contains('unauthorized')) {
      return 'Authentication error. Please log in again.';
    }
    
    if (error.toString().contains('not found')) {
      return 'The requested resource was not found.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }
}

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: FlutterFlowTheme.of(context).error,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        if (onDismiss != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            child: const Text('Dismiss'),
          ),
        if (onRetry != null)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry?.call();
            },
            child: const Text('Retry'),
          ),
      ],
    );
  }
}

class ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;

  const ToastWidget({
    super.key,
    required this.message,
    required this.type,
    required this.duration,
  });

  @override
  State<ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<ToastWidget> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                _getIcon(),
                color: _getIconColor(),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: TextStyle(
                    color: _getTextColor(),
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // Remove toast
                },
                icon: const Icon(Icons.close, size: 16),
                color: _getIconColor(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case ToastType.success:
        return Colors.green[50]!;
      case ToastType.error:
        return Colors.red[50]!;
      case ToastType.warning:
        return Colors.orange[50]!;
      case ToastType.info:
        return Colors.blue[50]!;
    }
  }

  Color _getIconColor() {
    switch (widget.type) {
      case ToastType.success:
        return Colors.green[700]!;
      case ToastType.error:
        return Colors.red[700]!;
      case ToastType.warning:
        return Colors.orange[700]!;
      case ToastType.info:
        return Colors.blue[700]!;
    }
  }

  Color _getTextColor() {
    switch (widget.type) {
      case ToastType.success:
        return Colors.green[900]!;
      case ToastType.error:
        return Colors.red[900]!;
      case ToastType.warning:
        return Colors.orange[900]!;
      case ToastType.info:
        return Colors.blue[900]!;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
    }
  }
}

enum ToastType {
  success,
  error,
  warning,
  info,
}

class OfflineIndicator extends StatelessWidget {
  final bool isOnline;
  final VoidCallback? onRetry;

  const OfflineIndicator({
    super.key,
    required this.isOnline,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isOnline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.orange[100],
      child: Row(
        children: [
          Icon(
            Icons.wifi_off,
            color: Colors.orange[700],
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You are currently offline',
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 12,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
} 