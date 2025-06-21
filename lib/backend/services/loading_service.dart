import 'package:flutter/material.dart';

/// Enum for different loading states
enum LoadingState {
  idle,
  loading,
  success,
  error,
}

/// Centralized loading state management service
class LoadingService extends ChangeNotifier {
  LoadingState _state = LoadingState.idle;
  String? _error;
  String? _loadingMessage;
  double _progress = 0.0;

  // Getters
  LoadingState get state => _state;
  String? get error => _error;
  String? get loadingMessage => _loadingMessage;
  double get progress => _progress;
  bool get isLoading => _state == LoadingState.loading;
  bool get isSuccess => _state == LoadingState.success;
  bool get isError => _state == LoadingState.error;
  bool get isIdle => _state == LoadingState.idle;

  /// Start loading with optional message
  void startLoading([String? message]) {
    _state = LoadingState.loading;
    _loadingMessage = message;
    _error = null;
    _progress = 0.0;
    notifyListeners();
  }

  /// Update loading progress
  void updateProgress(double progress, [String? message]) {
    if (_state == LoadingState.loading) {
      _progress = progress.clamp(0.0, 1.0);
      if (message != null) {
        _loadingMessage = message;
      }
      notifyListeners();
    }
  }

  /// Complete loading successfully
  void completeSuccess([String? message]) {
    _state = LoadingState.success;
    _loadingMessage = message;
    _error = null;
    _progress = 1.0;
    notifyListeners();
  }

  /// Complete loading with error
  void completeError(String error, [String? context]) {
    _state = LoadingState.error;
    _error = error;
    _loadingMessage = context;
    notifyListeners();
  }

  /// Reset to idle state
  void reset() {
    _state = LoadingState.idle;
    _error = null;
    _loadingMessage = null;
    _progress = 0.0;
    notifyListeners();
  }

  /// Clear error and return to idle
  void clearError() {
    _state = LoadingState.idle;
    _error = null;
    notifyListeners();
  }

  /// Execute async operation with loading state management
  Future<T?> executeWithLoading<T>(
    Future<T> Function() operation, {
    String? loadingMessage,
    String? successMessage,
    String? errorContext,
  }) async {
    try {
      startLoading(loadingMessage);
      final result = await operation();
      completeSuccess(successMessage);
      return result;
    } catch (e) {
      completeError(e.toString(), errorContext);
      return null;
    }
  }

  /// Execute async operation with progress updates
  Future<T?> executeWithProgress<T>(
    Future<T> Function(Function(double, String?) progressCallback) operation, {
    String? loadingMessage,
    String? successMessage,
    String? errorContext,
  }) async {
    try {
      startLoading(loadingMessage);
      final result = await operation(updateProgress);
      completeSuccess(successMessage);
      return result;
    } catch (e) {
      completeError(e.toString(), errorContext);
      return null;
    }
  }
}

/// Mixin for widgets that need loading state management
mixin LoadingMixin<T extends StatefulWidget> on State<T> {
  final LoadingService _loadingService = LoadingService();

  LoadingService get loadingService => _loadingService;

  @override
  void dispose() {
    _loadingService.dispose();
    super.dispose();
  }

  /// Execute operation with loading state
  Future<T?> executeWithLoading<T>(
    Future<T> Function() operation, {
    String? loadingMessage,
    String? successMessage,
    String? errorContext,
  }) async {
    return _loadingService.executeWithLoading(
      operation,
      loadingMessage: loadingMessage,
      successMessage: successMessage,
      errorContext: errorContext,
    );
  }

  /// Execute operation with progress updates
  Future<T?> executeWithProgress<T>(
    Future<T> Function(Function(double, String?) progressCallback) operation, {
    String? loadingMessage,
    String? successMessage,
    String? errorContext,
  }) async {
    return _loadingService.executeWithProgress(
      operation,
      loadingMessage: loadingMessage,
      successMessage: successMessage,
      errorContext: errorContext,
    );
  }
}

/// Widget that shows loading state
class LoadingWidget extends StatelessWidget {
  final LoadingService loadingService;
  final Widget Function()? successBuilder;
  final Widget Function(String error)? errorBuilder;
  final Widget Function(String? message, double progress)? loadingBuilder;
  final Widget? idleBuilder;

  const LoadingWidget({
    Key? key,
    required this.loadingService,
    this.successBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.idleBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: loadingService,
      builder: (context, child) {
        switch (loadingService.state) {
          case LoadingState.idle:
            return idleBuilder ?? const SizedBox.shrink();
          case LoadingState.loading:
            return loadingBuilder?.call(loadingService.loadingMessage, loadingService.progress) ??
                _buildDefaultLoadingWidget(context);
          case LoadingState.success:
            return successBuilder?.call() ?? const SizedBox.shrink();
          case LoadingState.error:
            return errorBuilder?.call(loadingService.error ?? 'Unknown error') ??
                _buildDefaultErrorWidget(context);
        }
      },
    );
  }

  Widget _buildDefaultLoadingWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            value: loadingService.progress > 0 ? loadingService.progress : null,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          if (loadingService.loadingMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              loadingService.loadingMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultErrorWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            loadingService.error ?? 'Unknown error occurred',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: loadingService.clearError,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loading widget
class SkeletonWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonWidget({
    Key? key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const SizedBox.shrink(),
    );
  }
}

/// Skeleton list widget
class SkeletonListWidget extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets padding;

  const SkeletonListWidget({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: SkeletonWidget(height: itemHeight),
        );
      },
    );
  }
} 