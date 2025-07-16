import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/obd2_bluetooth_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  late OBD2BluetoothService _obd2Service;

  @override
  void initState() {
    super.initState();
    // Use shared OBD2 Bluetooth Service singleton
    _obd2Service = OBD2BluetoothService();
  }

  @override
  void dispose() {
    // Don't dispose the shared service - it's used by other tabs
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _obd2Service,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          title: Text(
            'OBD2 Connection',
            style: FlutterFlowTheme.of(context).headlineMedium.copyWith(
              fontFamily: 'Outfit',
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<OBD2BluetoothService>(
          builder: (context, service, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Connection Status Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connection Status',
                            style: FlutterFlowTheme.of(context).headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                service.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                                color: service.isConnected ? Colors.green : Colors.red,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                service.connectionStatus,
                                style: FlutterFlowTheme.of(context).bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Search for Devices Button
                  if (!service.isConnected) ...[
                    ElevatedButton(
                      onPressed: service.isScanning
                          ? null
                          : () => _scanForDevices(service),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).secondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        service.isScanning ? 'Scanning...' : 'Search for OBD2 Devices',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Permission Check Button
                    TextButton(
                      onPressed: () => _checkPermissions(service),
                      child: Text(
                        'Check Permissions',
                        style: TextStyle(
                          color: FlutterFlowTheme.of(context).primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    
                    // Force Bluetooth Permission Button
                    TextButton(
                      onPressed: () => _forceBluetoothPermission(service),
                      child: Text(
                        'Force Bluetooth Permission',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    
                    // Force Location Permission Button
                    TextButton(
                      onPressed: () => _forceLocationPermission(service),
                      child: Text(
                        'Force Location Permission',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    
                    // Nuclear Reset Instructions Button
                    TextButton(
                      onPressed: () => _showResetInstructions(),
                      child: Text(
                        'Reset All Permissions (Nuclear Option)',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                  
                  // Available Devices List
                  if (service.availableDevices.isNotEmpty && !service.isConnected) ...[
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available OBD2 Devices (${service.availableDevices.length})',
                              style: FlutterFlowTheme.of(context).headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            // Scrollable device list with max height
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height * 0.3, // Max 30% of screen height
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: service.availableDevices.map((device) {
                                    final isSelected = service.selectedDevice?.remoteId == device.remoteId;
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      color: isSelected 
                                          ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1)
                                          : null,
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.bluetooth,
                                          color: isSelected 
                                              ? FlutterFlowTheme.of(context).primary
                                              : Colors.grey,
                                        ),
                                        title: Text(
                                          device.platformName.isNotEmpty 
                                              ? device.platformName 
                                              : 'Unknown Device',
                                          style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                        subtitle: Text(
                                          device.remoteId.toString(),
                                          style: FlutterFlowTheme.of(context).bodySmall,
                                        ),
                                        trailing: isSelected
                                            ? Icon(
                                                Icons.check_circle,
                                                color: FlutterFlowTheme.of(context).primary,
                                              )
                                            : null,
                                        onTap: () => service.selectDevice(device),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                  
                  // Connect/Disconnect Button
                  ElevatedButton(
                    onPressed: service.isConnected
                        ? () => _disconnect(service)
                        : (service.selectedDevice != null
                            ? () => _connect(service)
                            : null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: service.isConnected
                          ? Colors.red
                          : FlutterFlowTheme.of(context).primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      service.isConnected 
                          ? 'Disconnect' 
                          : (service.selectedDevice != null 
                              ? 'Connect to ${service.selectedDevice!.platformName}'
                              : 'Select a device to connect'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Live Data Section
                  if (service.isConnected) ...[
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Data',
                              style: FlutterFlowTheme.of(context).headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            if (service.liveData.isEmpty)
                              const Text('No data available yet...')
                            else
                              ...service.liveData.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          _formatDataLabel(entry.key),
                                          style: FlutterFlowTheme.of(context).bodyMedium,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          '${entry.value}${_getUnit(entry.key)}',
                                          style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.end,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Test Data Buttons
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Test Data Request',
                              style: FlutterFlowTheme.of(context).headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildTestButton('RPM', 'rpm', service),
                                _buildTestButton('Speed', 'speed', service),
                                _buildTestButton('Engine Temp', 'engine_temp', service),
                                _buildTestButton('Fuel Level', 'fuel_level', service),
                                _buildTestButton('Throttle', 'throttle_position', service),
                                _buildTestButton('VIN', 'vin', service),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTestButton(String label, String dataType, OBD2BluetoothService service) {
    return ElevatedButton(
      onPressed: () => service.requestData(dataType),
      style: ElevatedButton.styleFrom(
        backgroundColor: FlutterFlowTheme.of(context).secondary,
        foregroundColor: Colors.white,
      ),
      child: Text(label),
    );
  }

  String _formatDataLabel(String key) {
    switch (key) {
      case 'rpm':
        return 'RPM';
      case 'speed':
        return 'Speed';
      case 'engine_temp':
        return 'Engine Temp';
      case 'fuel_level':
        return 'Fuel Level';
      case 'throttle_position':
        return 'Throttle Position';
      case 'intake_air_temp':
        return 'Intake Air Temp';
      case 'coolant_temp':
        return 'Coolant Temp';
      case 'fuel_pressure':
        return 'Fuel Pressure';
      case 'vin':
        return 'VIN';
      default:
        return key;
    }
  }

  String _getUnit(String key) {
    switch (key) {
      case 'rpm':
        return ' RPM';
      case 'speed':
        return ' km/h';
      case 'engine_temp':
      case 'intake_air_temp':
      case 'coolant_temp':
        return '°C';
      case 'fuel_level':
      case 'throttle_position':
        return '%';
      case 'fuel_pressure':
        return ' kPa';
      case 'vin':
        return '';
      default:
        return '';
    }
  }

  Future<void> _checkPermissions(OBD2BluetoothService service) async {
    final granted = await service.requestPermissionsAgain();
    if (mounted) {
      if (granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ All permissions granted! You can now scan for devices.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showPermissionDialog(service);
      }
    }
  }

  Future<void> _forceBluetoothPermission(OBD2BluetoothService service) async {
    final success = await service.forceBluetoothPermissionRequest();
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔵 Bluetooth permission requested! Check device settings if dialog appeared.'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to request Bluetooth permission.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _forceLocationPermission(OBD2BluetoothService service) async {
    final success = await service.forceLocationPermissionRequest();
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📍 Location permission granted! You can now scan for devices.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Location permission denied. Please enable in Settings > Privacy > Location Services.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showResetInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuclear Reset - Fresh Start'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'If permissions are stuck, do this for a fresh start:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                '1. DELETE THIS APP',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              Text('   • Long press the app icon → Delete App'),
              SizedBox(height: 8),
              Text(
                '2. RESET ALL PRIVACY SETTINGS',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              Text('   • Settings → General → Transfer or Reset iPhone'),
              Text('   • Reset → Reset Location & Privacy'),
              Text('   • Enter passcode → Reset Settings'),
              SizedBox(height: 8),
              Text(
                '3. REINSTALL APP',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              Text('   • Run: flutter run'),
              Text('   • Fresh permission dialogs will appear'),
              SizedBox(height: 16),
              Text(
                'This will reset ALL app permissions on your device but guarantees fresh permission dialogs.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanForDevices(OBD2BluetoothService service) async {
    final success = await service.scanForDevices();
    if (!success && mounted) {
      if (service.connectionStatus.contains('Permissions not granted')) {
        _showPermissionDialog(service);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan failed: ${service.connectionStatus}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _connect(OBD2BluetoothService service) async {
    final success = await service.connectToSelectedDevice();
    if (!success && mounted) {
      if (service.connectionStatus.contains('Permissions not granted')) {
        _showPermissionDialog(service);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: ${service.connectionStatus}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showManualInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Setup Instructions'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To manually enable permissions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Android:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('1. Go to Settings > Apps'),
              Text('2. Find "OBD2-Scanner-Frontend"'),
              Text('3. Tap "Permissions"'),
              Text('4. Enable "Location" and "Nearby devices"'),
              SizedBox(height: 16),
              Text(
                'iOS:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('1. Go to Settings > Privacy & Security'),
              Text('2. Tap "Bluetooth"'),
              Text('3. Find "OBD2-Scanner-Frontend"'),
              Text('4. Enable the toggle'),
              Text('5. Also enable "Location Services"'),
              SizedBox(height: 16),
              Text(
                'Then return to this app and try scanning again.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog(OBD2BluetoothService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This app needs the following permissions to connect to OBD2 devices:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Bluetooth - to connect to OBD2 scanner'),
            Text('• Location - required for Bluetooth scanning'),
            SizedBox(height: 16),
            Text(
              'Please grant these permissions to continue.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final granted = await service.requestPermissionsAgain();
              if (granted && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Permissions granted! You can now scan for devices.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showManualInstructions();
            },
            child: const Text('Instructions'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              service.openSettings();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enable Bluetooth and Location permissions, then return to the app.'),
                    duration: Duration(seconds: 4),
                  ),
                );
              }
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _disconnect(OBD2BluetoothService service) async {
    await service.disconnectFromOBD2();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disconnected from OBD2 device'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}