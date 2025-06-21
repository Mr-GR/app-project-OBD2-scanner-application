import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../backend/providers/app_state_provider.dart';
import '../../widgets/connection_status_widget.dart';
import '../../flutter_flow/flutter_flow_theme.dart';

class ConnectionSettingsWidget extends StatefulWidget {
  const ConnectionSettingsWidget({Key? key}) : super(key: key);

  @override
  State<ConnectionSettingsWidget> createState() => _ConnectionSettingsWidgetState();
}

class _ConnectionSettingsWidgetState extends State<ConnectionSettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        automaticallyImplyLeading: true,
        title: Text(
          'Connection Settings',
          style: FlutterFlowTheme.of(context).titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection Status
              ConnectionStatusWidget(
                showDetails: true,
                onRetry: _retryConnections,
              ),
              
              const SizedBox(height: 24),
              
              // OBD2 Device Section
              _buildSectionHeader('OBD2 Device', Icons.bluetooth),
              const SizedBox(height: 12),
              _buildOBD2DeviceSection(),
              
              const SizedBox(height: 24),
              
              // API Configuration Section
              _buildSectionHeader('API Configuration', Icons.key),
              const SizedBox(height: 12),
              _buildAPIConfigurationSection(),
              
              const SizedBox(height: 24),
              
              // Development Settings Section
              _buildSectionHeader('Development Settings', Icons.developer_mode),
              const SizedBox(height: 12),
              _buildDevelopmentSettingsSection(),
              
              const SizedBox(height: 24),
              
              // App Information Section
              _buildSectionHeader('App Information', Icons.info),
              const SizedBox(height: 12),
              _buildAppInformationSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: FlutterFlowTheme.of(context).primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: FlutterFlowTheme.of(context).titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildOBD2DeviceSection() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      appState.isConnectedToOBD2 ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                      color: appState.isConnectedToOBD2 
                          ? FlutterFlowTheme.of(context).success
                          : FlutterFlowTheme.of(context).secondaryText,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.isConnectedToOBD2 ? 'Connected' : 'Not Connected',
                            style: FlutterFlowTheme.of(context).titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            appState.isConnectedToOBD2 
                                ? 'ELM327 device is connected and ready'
                                : 'No OBD2 device detected',
                            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: appState.isConnectedToOBD2 ? _disconnectOBD2 : _connectOBD2,
                        icon: Icon(
                          appState.isConnectedToOBD2 ? Icons.bluetooth_disabled : Icons.bluetooth_searching,
                          size: 16,
                        ),
                        label: Text(
                          appState.isConnectedToOBD2 ? 'Disconnect' : 'Connect Device',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appState.isConnectedToOBD2 
                              ? FlutterFlowTheme.of(context).error
                              : FlutterFlowTheme.of(context).primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _scanForDevices,
                      icon: const Icon(Icons.search, size: 16),
                      label: const Text('Scan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
                        foregroundColor: FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAPIConfigurationSection() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      appState.hasValidApiKeys ? Icons.key : Icons.key_off,
                      color: appState.hasValidApiKeys 
                          ? FlutterFlowTheme.of(context).success
                          : FlutterFlowTheme.of(context).warning,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.hasValidApiKeys ? 'Configured' : 'Not Configured',
                            style: FlutterFlowTheme.of(context).titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            appState.hasValidApiKeys 
                                ? 'API keys are properly configured'
                                : 'API keys need to be configured for full functionality',
                            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _configureAPIKeys,
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('Configure API Keys'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (!appState.hasValidApiKeys) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: FlutterFlowTheme.of(context).warning,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Limited Functionality',
                              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: FlutterFlowTheme.of(context).warning,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Without API keys, AI features and vehicle data lookup will not work. Mock data will be used instead.',
                          style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDevelopmentSettingsSection() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mock Data Settings',
                  style: FlutterFlowTheme.of(context).titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Mock Data Toggle
                SwitchListTile(
                  title: const Text('Use Mock Data'),
                  subtitle: const Text('Enable mock data for development'),
                  value: appState.useMockData,
                  onChanged: (value) {
                    appState.toggleMockData(value);
                  },
                  secondary: Icon(
                    Icons.developer_mode,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                ),
                
                // Mock OBD2 Responses
                SwitchListTile(
                  title: const Text('Mock OBD2 Responses'),
                  subtitle: const Text('Simulate OBD2 device responses'),
                  value: appState.enableMockOBD2Responses,
                  onChanged: (value) {
                    appState.toggleMockOBD2Responses(value);
                  },
                  secondary: Icon(
                    Icons.bluetooth,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                ),
                
                // Mock NHTSA Responses
                SwitchListTile(
                  title: const Text('Mock NHTSA Responses'),
                  subtitle: const Text('Simulate vehicle data responses'),
                  value: appState.enableMockNHTSAResponses,
                  onChanged: (value) {
                    appState.toggleMockNHTSAResponses(value);
                  },
                  secondary: Icon(
                    Icons.directions_car,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                ),
                
                // Mock GPT Responses
                SwitchListTile(
                  title: const Text('Mock GPT Responses'),
                  subtitle: const Text('Simulate AI assistant responses'),
                  value: appState.enableMockGPTResponses,
                  onChanged: (value) {
                    appState.toggleMockGPTResponses(value);
                  },
                  secondary: Icon(
                    Icons.psychology,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                ),
                
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _resetToDefaults,
                  icon: const Icon(Icons.restore, size: 16),
                  label: const Text('Reset to Defaults'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
                    foregroundColor: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppInformationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('App Version', '1.0.0'),
            _buildInfoRow('Build Number', '1'),
            _buildInfoRow('Flutter Version', '3.16.0'),
            _buildInfoRow('Dart Version', '3.2.0'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showAppLogs,
              icon: const Icon(Icons.bug_report, size: 16),
              label: const Text('View App Logs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
                foregroundColor: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // Action Methods
  void _retryConnections() {
    final appState = context.read<AppStateProvider>();
    appState.initialize();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Retrying connections...')),
    );
  }

  void _connectOBD2() {
    // TODO: Implement OBD2 connection logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connecting to OBD2 device...')),
    );
  }

  void _disconnectOBD2() {
    // TODO: Implement OBD2 disconnection logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Disconnecting from OBD2 device...')),
    );
  }

  void _scanForDevices() {
    // TODO: Implement device scanning logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scanning for OBD2 devices...')),
    );
  }

  void _configureAPIKeys() {
    // TODO: Navigate to API configuration screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to API configuration...')),
    );
  }

  void _resetToDefaults() {
    final appState = context.read<AppStateProvider>();
    appState.reset();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings reset to defaults')),
    );
  }

  void _showAppLogs() {
    // TODO: Show app logs dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Show app logs...')),
    );
  }
} 