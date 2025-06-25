import 'package:flutter/material.dart';
import '../flutter_flow/flutter_flow_theme.dart';

/// Widget that shows a loading overlay when any operation is loading
class LoadingOverlayWidget extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const LoadingOverlayWidget({
    Key? key,
    required this.child,
    this.isLoading = false,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget that shows loading state for a specific operation
class OperationLoadingWidget extends StatelessWidget {
  final String operation;
  final bool isLoading;
  final Widget child;

  const OperationLoadingWidget({
    Key? key,
    required this.operation,
    required this.isLoading,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading $operation...',
                    style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
} 