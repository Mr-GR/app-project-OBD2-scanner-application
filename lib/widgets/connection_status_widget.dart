import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../backend/providers/app_state_provider.dart';
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
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: FlutterFlowTheme.of(context).alternate,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.wifi_tethering,
                    size: 16,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Connection Status',
                    style: FlutterFlowTheme.of(context).titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  if (onRetry != null)
                    IconButton(
                      onPressed: onRetry,
                      icon: Icon(
                        Icons.refresh,
                        size: 16,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Connection Status Items
              _buildStatusItem(
                context,
                'OBD2 Device',
                appState.isConnectedToOBD2,
                Icons.bluetooth,
                'Connected to ELM327 device',
                'No OBD2 device connected',
              ),
              
              _buildStatusItem(
                context,
                'Internet',
                appState.isConnectedToInternet,
                Icons.wifi,
                'Internet connection available',
                'No internet connection',
              ),
              
              _buildStatusItem(
                context,
                'API Keys',
                appState.hasValidApiKeys,
                Icons.key,
                'API keys configured',
                'API keys not configured',
              ),
              
              _buildStatusItem(
                context,
                'Authentication',
                appState.isAuthenticated,
                Icons.person,
                'User authenticated',
                'User not authenticated',
              ),
              
              if (showDetails) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                
                // Mode Information
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: appState.isProductionMode
                            ? FlutterFlowTheme.of(context).success.withValues(alpha: 0.1)
                            : FlutterFlowTheme.of(context).warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        appState.isProductionMode ? 'PRODUCTION' : 'DEVELOPMENT',
                        style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                          color: appState.isProductionMode
                              ? FlutterFlowTheme.of(context).success
                              : FlutterFlowTheme.of(context).warning,
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (appState.useMockData)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'MOCK DATA',
                          style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                            color: FlutterFlowTheme.of(context).warning,
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                          ),
                        ),
                      ),
                  ],
                ),
                
                // Capabilities
                const SizedBox(height: 6),
                Text(
                  'Capabilities:',
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                _buildCapabilityItem(
                  context,
                  'Vehicle Scans',
                  appState.canPerformScans,
                ),
                _buildCapabilityItem(
                  context,
                  'AI Assistant',
                  appState.canUseAI,
                ),
                _buildCapabilityItem(
                  context,
                  'Vehicle Data',
                  appState.canFetchVehicleData,
                ),
                
                // Error Display
                if (appState.lastError.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 14,
                          color: FlutterFlowTheme.of(context).error,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            appState.lastError,
                            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                              color: FlutterFlowTheme.of(context).error,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    bool isConnected,
    IconData icon,
    String connectedMessage,
    String disconnectedMessage,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: isConnected
                ? FlutterFlowTheme.of(context).success
                : FlutterFlowTheme.of(context).secondaryText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected
                  ? FlutterFlowTheme.of(context).success
                  : FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
          if (showDetails) ...[
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Text(
                isConnected ? connectedMessage : disconnectedMessage,
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 10,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCapabilityItem(
    BuildContext context,
    String capability,
    bool isAvailable,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            size: 12,
            color: isAvailable
                ? FlutterFlowTheme.of(context).success
                : FlutterFlowTheme.of(context).secondaryText,
          ),
          const SizedBox(width: 6),
          Text(
            capability,
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
              color: isAvailable
                  ? FlutterFlowTheme.of(context).primaryText
                  : FlutterFlowTheme.of(context).secondaryText,
              fontSize: 10,
            ),
          ),
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
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final allConnected = appState.isConnectedToOBD2 &&
                           appState.isConnectedToInternet &&
                           appState.hasValidApiKeys;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: allConnected
                ? FlutterFlowTheme.of(context).success.withValues(alpha: 0.1)
                : FlutterFlowTheme.of(context).warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: allConnected
                  ? FlutterFlowTheme.of(context).success.withValues(alpha: 0.3)
                  : FlutterFlowTheme.of(context).warning.withValues(alpha: 0.3),
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
                  color: allConnected
                      ? FlutterFlowTheme.of(context).success
                      : FlutterFlowTheme.of(context).warning,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                allConnected ? 'Connected' : 'Limited',
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: allConnected
                      ? FlutterFlowTheme.of(context).success
                      : FlutterFlowTheme.of(context).warning,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 