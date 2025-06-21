# Backend Services Documentation

This directory contains centralized services for the OBD2 Scanner app that provide error handling, loading state management, and caching functionality.

## Services Overview

### 1. ErrorHandler (`error_handler.dart`)
Centralized error handling service that provides user-friendly error messages and logging.

**Features:**
- User-friendly error messages
- Error logging with context
- Retry functionality
- Custom exception classes
- API, network, and Bluetooth error handling

**Usage:**
```dart
// Basic error handling
ErrorHandler.handleError(context, error, errorContext: 'API call');

// With retry functionality
ErrorHandler.handleError(
  context, 
  error, 
  errorContext: 'Network operation',
  onRetry: () => retryOperation(),
);

// Show error dialog with details
ErrorHandler.showErrorDialog(
  context,
  'Error Title',
  'User-friendly message',
  details: 'Technical details for debugging',
  onRetry: () => retryOperation(),
);
```

### 2. LoadingStateManager (`loading_state_manager.dart`)
Manages loading states across the app with operation-specific loading indicators.

**Features:**
- Operation-specific loading states
- Loading messages
- Global loading state tracking
- Mixin for easy integration

**Usage:**
```dart
// In a StatefulWidget with LoadingStateMixin
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with LoadingStateMixin {
  Future<void> performOperation() async {
    startLoading('my_operation', message: 'Processing...');
    
    try {
      await someAsyncOperation();
    } finally {
      stopLoading('my_operation');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return OperationLoadingWidget(
      operation: 'my_operation',
      child: MyContent(),
    );
  }
}
```

### 3. CacheService (`cache_service.dart`)
Provides in-memory and disk-based caching with expiration.

**Features:**
- In-memory and disk caching
- Automatic expiration
- Cache key generation
- Cache statistics
- Memory limit management

**Usage:**
```dart
final cacheService = CacheService();

// Store data
await cacheService.set(
  'vehicle_data_123',
  vehicleData,
  expiration: Duration(hours: 1),
);

// Retrieve data
final data = await cacheService.getAsync<VehicleData>('vehicle_data_123');

// Generate cache keys
final key = CacheService.generateKey('vehicle_data', {
  'vin': '123456789',
  'includeHistory': true,
});

// Get cache statistics
final stats = await cacheService.getStats();
print('Cache size: ${stats.diskSizeFormatted}');
```

### 4. AppService (`app_service.dart`)
Main service that integrates all other services and provides a unified interface.

**Features:**
- Integrated error handling, loading states, and caching
- Retry logic with exponential backoff
- Operation execution with automatic caching
- Mixin for easy widget integration

**Usage:**
```dart
// In a StatefulWidget with AppServiceMixin
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with AppServiceMixin {
  Future<void> loadVehicleData() async {
    final data = await executeWithLoading(
      () => apiService.getVehicleData(vin),
      operationName: 'load_vehicle_data',
      loadingMessage: 'Loading vehicle information...',
      cacheKey: CacheKeys.vehicleData(vin),
      cacheExpiration: Duration(hours: 1),
    );
    
    if (data != null) {
      setState(() {
        vehicleData = data;
      });
    }
  }
  
  Future<void> performWithRetry() async {
    final result = await executeWithRetry(
      () => apiService.riskyOperation(),
      operationName: 'risky_operation',
      maxRetries: 3,
      retryDelay: Duration(seconds: 2),
    );
  }
}
```

## Widgets

### LoadingOverlayWidget
Shows a loading overlay when any operation is loading.

```dart
LoadingOverlayWidget(
  child: MyAppContent(),
  defaultMessage: 'Please wait...',
)
```

### OperationLoadingWidget
Shows loading state for a specific operation.

```dart
OperationLoadingWidget(
  operation: 'scan_vehicle',
  child: ScanButton(),
  defaultMessage: 'Scanning vehicle...',
)
```

## Integration with Main App

The services are automatically initialized in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize app services
  await AppService().initialize();
  
  runApp(MyApp());
}
```

And provided through the widget tree:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AppService()),
    // ... other providers
  ],
  child: MyApp(),
)
```

## Best Practices

1. **Use descriptive operation names** for loading states
2. **Cache expensive operations** like API calls and OBD2 scans
3. **Provide user-friendly error messages** with retry options
4. **Use the mixins** for easy integration in widgets
5. **Monitor cache statistics** to optimize memory usage
6. **Handle errors gracefully** with appropriate fallbacks

## Cache Keys

Use the predefined cache keys from `CacheKeys` class:

```dart
CacheKeys.vehicleList
CacheKeys.diagnosticReport
CacheKeys.chatHistory
CacheKeys.vehicleData(vin)
CacheKeys.diagnosticData(vin)
CacheKeys.chatSession(sessionId)
```

## Error Handling Patterns

1. **API Calls**: Use `executeWithLoading` with retry logic
2. **Network Operations**: Handle connectivity issues gracefully
3. **Bluetooth Operations**: Provide clear device connection feedback
4. **User Actions**: Show immediate feedback with loading states
5. **Background Operations**: Log errors without disrupting user experience 