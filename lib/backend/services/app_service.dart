import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'error_handler.dart';
import 'loading_state_manager.dart';
import 'cache_service.dart';

/// Main app service that integrates error handling, loading states, and caching
class AppService extends ChangeNotifier {
  static final AppService _instance = AppService._internal();
  factory AppService() => _instance;
  AppService._internal();

  final LoadingStateManager _loadingManager = LoadingStateManager();
  final CacheService _cacheService = CacheService();

  /// Initialize all services
  Future<void> initialize() async {
    try {
      await _cacheService.initialize();
      notifyListeners();
    } catch (e) {
      print('Error initializing AppService: $e');
    }
  }

  /// Execute operation with loading state and error handling
  Future<T?> executeWithLoading<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String operationName = 'operation',
    String? loadingMessage,
    bool showErrorSnackBar = true,
    VoidCallback? onRetry,
    Duration? cacheExpiration,
    String? cacheKey,
  }) async {
    try {
      // Start loading
      _loadingManager.startLoading(operationName, message: loadingMessage);

      // Check cache first if cacheKey is provided
      if (cacheKey != null) {
        final cachedResult = await _cacheService.getAsync<T>(cacheKey);
        if (cachedResult != null) {
          _loadingManager.stopLoading(operationName);
          return cachedResult;
        }
      }

      // Execute operation
      final result = await operation();

      // Cache result if cacheKey is provided
      if (cacheKey != null && result != null) {
        await _cacheService.set(
          cacheKey,
          result,
          expiration: cacheExpiration,
        );
      }

      _loadingManager.stopLoading(operationName);
      return result;

    } catch (error) {
      _loadingManager.stopLoading(operationName);
      
      if (showErrorSnackBar) {
        ErrorHandler.handleError(
          context,
          error,
          errorContext: operationName,
          onRetry: onRetry,
        );
      }
      
      return null;
    }
  }

  /// Execute operation with retry logic
  Future<T?> executeWithRetry<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String operationName = 'operation',
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    String? loadingMessage,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      attempts++;
      
      try {
        return await executeWithLoading(
          context,
          operation,
          operationName: '$operationName (attempt $attempts)',
          loadingMessage: loadingMessage,
          showErrorSnackBar: attempts == maxRetries,
        );
      } catch (error) {
        if (attempts == maxRetries) {
          ErrorHandler.handleError(
            context,
            error,
            errorContext: '$operationName (final attempt)',
          );
          return null;
        }
        
        // Wait before retry
        await Future.delayed(retryDelay * attempts);
      }
    }
    
    return null;
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    await _cacheService.clear();
    notifyListeners();
  }

  /// Get cache statistics
  Future<CacheStats> getCacheStats() async {
    return await _cacheService.getStats();
  }

  /// Check if any operation is loading
  bool get isAnyLoading => _loadingManager.isAnyLoading;

  /// Get loading state for specific operation
  bool isLoading(String operation) => _loadingManager.isLoading(operation);

  /// Get loading message for specific operation
  String? getLoadingMessage(String operation) => _loadingManager.getLoadingMessage(operation);

  /// Start loading for an operation
  void startLoading(String operation, {String? message}) {
    _loadingManager.startLoading(operation, message: message);
  }

  /// Stop loading for an operation
  void stopLoading(String operation) {
    _loadingManager.stopLoading(operation);
  }

  /// Handle error with context
  void handleError(
    BuildContext context,
    dynamic error, {
    String? errorContext,
    bool showSnackBar = true,
    VoidCallback? onRetry,
  }) {
    ErrorHandler.handleError(
      context,
      error,
      errorContext: errorContext,
      showSnackBar: showSnackBar,
      onRetry: onRetry,
    );
  }

  /// Cache data
  Future<void> cacheData<T>(
    String key,
    T data, {
    Duration? expiration,
    bool persistToDisk = true,
  }) async {
    await _cacheService.set(
      key,
      data,
      expiration: expiration,
      persistToDisk: persistToDisk,
    );
  }

  /// Get cached data
  T? getCachedData<T>(String key) {
    return _cacheService.get<T>(key);
  }

  /// Get cached data asynchronously
  Future<T?> getCachedDataAsync<T>(String key) async {
    return await _cacheService.getAsync<T>(key);
  }

  /// Check if data is cached
  Future<bool> hasCachedData(String key) async {
    return await _cacheService.has(key);
  }

  /// Remove cached data
  Future<void> removeCachedData(String key) async {
    await _cacheService.remove(key);
  }

  /// Generate cache key
  static String generateCacheKey(String base, Map<String, dynamic> params) {
    return CacheService.generateKey(base, params);
  }
}

/// Provider for AppService
class AppServiceProvider extends ChangeNotifierProvider<AppService> {
  AppServiceProvider({super.key, required super.child})
      : super(create: (_) => AppService());
}

/// Mixin for widgets that need app service functionality
mixin AppServiceMixin<T extends StatefulWidget> on State<T> {
  AppService get appService => AppService();

  bool isLoading(String operation) => appService.isLoading(operation);
  String? getLoadingMessage(String operation) => appService.getLoadingMessage(operation);
  void startLoading(String operation, {String? message}) => appService.startLoading(operation, message: message);
  void stopLoading(String operation) => appService.stopLoading(operation);

  Future<T?> executeWithLoading<T>(
    Future<T> Function() operation, {
    String operationName = 'operation',
    String? loadingMessage,
    bool showErrorSnackBar = true,
    VoidCallback? onRetry,
    Duration? cacheExpiration,
    String? cacheKey,
  }) async {
    return await appService.executeWithLoading(
      context,
      operation,
      operationName: operationName,
      loadingMessage: loadingMessage,
      showErrorSnackBar: showErrorSnackBar,
      onRetry: onRetry,
      cacheExpiration: cacheExpiration,
      cacheKey: cacheKey,
    );
  }

  Future<T?> executeWithRetry<T>(
    Future<T> Function() operation, {
    String operationName = 'operation',
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    String? loadingMessage,
  }) async {
    return await appService.executeWithRetry(
      context,
      operation,
      operationName: operationName,
      maxRetries: maxRetries,
      retryDelay: retryDelay,
      loadingMessage: loadingMessage,
    );
  }

  void handleError(
    dynamic error, {
    String? errorContext,
    bool showSnackBar = true,
    VoidCallback? onRetry,
  }) {
    appService.handleError(
      context,
      error,
      errorContext: errorContext,
      showSnackBar: showSnackBar,
      onRetry: onRetry,
    );
  }
} 