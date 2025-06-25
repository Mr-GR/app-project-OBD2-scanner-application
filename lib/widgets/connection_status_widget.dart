import 'package:flutter/material.dart';
import '../flutter_flow/flutter_flow_theme.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final bool showDetails;
  final VoidCallback? onRetry;

  const ConnectionStatusWidget({
    Key? key,
    this.showDetails = false,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Connection Status (UI template)', style: FlutterFlowTheme.of(context).titleMedium),
          const SizedBox(height: 16),
          Text('This is a placeholder for connection status.'),
        ],
      ),
    );
  }
}

// Compact version for use in headers or small spaces
class CompactConnectionStatusWidget extends StatelessWidget {
  const CompactConnectionStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: FlutterFlowTheme.of(context).secondaryBackground,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Limited',
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
              color: FlutterFlowTheme.of(context).secondaryText,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
} 