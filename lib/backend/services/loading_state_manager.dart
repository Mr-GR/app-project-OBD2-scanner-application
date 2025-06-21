import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Centralized loading state management service
class LoadingStateManager extends ChangeNotifier {
  static final LoadingStateManager _instance = LoadingStateManager._internal();
  factory LoadingStateManager() => _instance;
  LoadingStateManager._internal();

  final Map<String, bool> _loadingStates = {};
  final Map<String, String> _loadingMessages = {};

  /// Check if a specific operation is loading
  bool isLoading(String operation) {
    return _loadingStates[operation] ?? false;
  }

  /// Get loading message for a specific operation
  String? getLoadingMessage(String operation) {
    return _loadingMessages[operation];
  }

  /// Set loading state for an operation
  void setLoading(String operation, {bool loading = true, String? message}) {
    _loadingStates[operation] = loading;
    if (message != null) {
      _loadingMessages[operation] = message;
    } else if (!loading) {
      _loadingMessages.remove(operation);
    }
    notifyListeners();
  }

  /// Start loading with optional message
  void startLoading(String operation, {String? message}) {
    setLoading(operation, loading: true, message: message);
  }

  /// Stop loading
  void stopLoading(String operation) {
    setLoading(operation, loading: false);
  }

  /// Check if any operation is currently loading
  bool get isAnyLoading => _loadingStates.values.any((loading) => loading);

  /// Get all currently loading operations
  List<String> get loadingOperations => 
      _loadingStates.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

  /// Clear all loading states
  void clearAll() {
    _loadingStates.clear();
    _loadingMessages.clear();
    notifyListeners();
  }

  /// Clear loading state for specific operation
  void clear(String operation) {
    _loadingStates.remove(operation);
    _loadingMessages.remove(operation);
    notifyListeners();
  }
}

/// Mixin for widgets that need loading state management
mixin LoadingStateMixin<T extends StatefulWidget> on State<T> {
  final LoadingStateManager _loadingManager = LoadingStateManager();

  bool isLoading(String operation) => _loadingManager.isLoading(operation);
  String? getLoadingMessage(String operation) => _loadingManager.getLoadingMessage(operation);
  void startLoading(String operation, {String? message}) => _loadingManager.startLoading(operation, message: message);
  void stopLoading(String operation) => _loadingManager.stopLoading(operation);

  @override
  void initState() {
    super.initState();
    _loadingManager.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _loadingManager.removeListener(() {
      if (mounted) setState(() {});
    });
    super.dispose();
  }
}

/// Widget that shows loading state for a specific operation
class LoadingStateWidget extends StatelessWidget {
  final String operation;
  final Widget child;
  final Widget? loadingWidget;
  final String? defaultMessage;

  const LoadingStateWidget({
    super.key,
    required this.operation,
    required this.child,
    this.loadingWidget,
    this.defaultMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadingStateManager>(
      builder: (context, loadingManager, _) {
        final isLoading = loadingManager.isLoading(operation);
        final message = loadingManager.getLoadingMessage(operation) ?? defaultMessage;

        if (isLoading) {
          return loadingWidget ?? 
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              );
        }

        return child;
      },
    );
  }
} 