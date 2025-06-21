import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../backend/services/loading_state_manager.dart';

/// Widget that shows a loading overlay when any operation is loading
class LoadingOverlayWidget extends StatelessWidget {
  final Widget child;
  final Widget? loadingWidget;
  final String? defaultMessage;

  const LoadingOverlayWidget({
    super.key,
    required this.child,
    this.loadingWidget,
    this.defaultMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadingStateManager>(
      builder: (context, loadingManager, _) {
        final isLoading = loadingManager.isAnyLoading;
        final loadingOperations = loadingManager.loadingOperations;
        
        if (!isLoading) {
          return child;
        }

        return Stack(
          children: [
            child,
            Container(
              color: Colors.black54,
              child: Center(
                child: loadingWidget ?? _buildDefaultLoadingWidget(context, loadingOperations),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDefaultLoadingWidget(BuildContext context, List<String> operations) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DialogTheme.of(context).backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            defaultMessage ?? 'Loading...',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (operations.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              operations.join(', '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget that shows loading state for a specific operation
class OperationLoadingWidget extends StatelessWidget {
  final String operation;
  final Widget child;
  final Widget? loadingWidget;
  final String? defaultMessage;

  const OperationLoadingWidget({
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

        if (!isLoading) {
          return child;
        }

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
      },
    );
  }
} 