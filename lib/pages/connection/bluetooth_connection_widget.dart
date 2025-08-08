import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/services/obd2_bluetooth_service.dart';

class BluetoothConnectionWidget extends StatefulWidget {
  const BluetoothConnectionWidget({super.key});

  @override
  State<BluetoothConnectionWidget> createState() => _BluetoothConnectionWidgetState();
}

class _BluetoothConnectionWidgetState extends State<BluetoothConnectionWidget> 
    with TickerProviderStateMixin {
  
  // OBD2 Bluetooth Service - shared singleton instance
  late OBD2BluetoothService _obd2Service;
  late AnimationController _pulseController;
  
  // Connection loading states
  bool _scanningDevices = false;
  bool _connectingToDevice = false;

  @override
  void initState() {
    super.initState();
    print('BluetoothConnectionWidget initState called');
    
    // Initialize animation controller for connection pulse
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Use shared OBD2 Bluetooth Service singleton
    _obd2Service = OBD2BluetoothService();
    
    // Listen for connection state changes
    _obd2Service.addListener(_onConnectionStateChanged);
    
    // Start pulse animation when connected
    if (_obd2Service.isConnected) {
      _pulseController.repeat();
    }
  }
  
  void _onConnectionStateChanged() {
    if (mounted) {
      setState(() {
        // Trigger UI update when connection state changes
        if (_obd2Service.isConnected) {
          _pulseController.repeat();
        } else {
          _pulseController.stop();
        }
      });
    }
  }

  @override
  void dispose() {
    _obd2Service.removeListener(_onConnectionStateChanged);
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _scanForDevices() async {
    try {
      setState(() {
        _scanningDevices = true;
      });
      
      final success = await _obd2Service.scanForDevices();
      if (!success && mounted) {
        _showSnackBar('Failed to scan for devices. Check permissions.', Colors.red);
      } else if (mounted) {
        _showSnackBar('Scanning completed', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Scan error: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _scanningDevices = false;
        });
      }
    }
  }

  Future<void> _connectToDevice() async {
    if (_obd2Service.selectedDevice == null) {
      _showSnackBar('Please select a device first', Colors.orange);
      return;
    }
    
    try {
      setState(() {
        _connectingToDevice = true;
      });
      
      final success = await _obd2Service.connectToSelectedDevice();
      if (success && mounted) {
        _showSnackBar('Connected to ${_obd2Service.selectedDevice!.platformName}', Colors.green);
      } else if (mounted) {
        _showSnackBar('Failed to connect', Colors.red);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Connection error: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _connectingToDevice = false;
        });
      }
    }
  }

  Future<void> _disconnectFromDevice() async {
    try {
      await _obd2Service.disconnectFromOBD2();
      if (mounted) {
        _showSnackBar('Disconnected from OBD2 device', Colors.orange);
        setState(() {
          // Trigger UI update when disconnected
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Disconnect error: $e', Colors.red);
      }
    }
  }

  Future<void> _checkPermissions() async {
    final granted = await _obd2Service.requestPermissionsAgain();
    if (mounted) {
      if (granted) {
        _showSnackBar('✅ All permissions granted! You can now scan for devices.', Colors.green);
      } else {
        _showSnackBar('❌ Permissions required for Bluetooth scanning', Colors.orange);
      }
    }
  }

  Future<void> _forceBluetoothPermission() async {
    final success = await _obd2Service.forceBluetoothPermissionRequest();
    if (mounted) {
      if (success) {
        _showSnackBar('📶 Bluetooth permission granted! You can now scan for devices.', Colors.green);
      } else {
        _showSnackBar('❌ Bluetooth permission denied. Please enable in Settings > Privacy & Security > Bluetooth.', Colors.orange);
      }
    }
  }

  Future<void> _forceLocationPermission() async {
    final success = await _obd2Service.forceLocationPermissionRequest();
    if (mounted) {
      if (success) {
        _showSnackBar('📍 Location permission granted! You can now scan for devices.', Colors.green);
      } else {
        _showSnackBar('❌ Location permission denied. Please enable in Settings > Privacy > Location Services.', Colors.orange);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _obd2Service,
      child: Consumer<OBD2BluetoothService>(
        builder: (context, obd2Service, child) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            appBar: AppBar(
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              elevation: 0,
              title: Text(
                'Connect Bluetooth Device',
                style: FlutterFlowTheme.of(context).titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Connection Status Card
                    Card(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Status Icon with Animation
                            Container(
                              width: 80,
                              height: 80,
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: obd2Service.isConnected 
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                      boxShadow: obd2Service.isConnected ? [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.3 * _pulseController.value),
                                          blurRadius: 20 * _pulseController.value,
                                          spreadRadius: 10 * _pulseController.value,
                                        ),
                                      ] : null,
                                    ),
                                    child: Icon(
                                      obd2Service.isConnected 
                                          ? Icons.bluetooth_connected 
                                          : Icons.bluetooth_disabled,
                                      size: 40,
                                      color: obd2Service.isConnected ? Colors.green : Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              obd2Service.isConnected ? 'Connected' : 'Disconnected',
                              style: FlutterFlowTheme.of(context).titleLarge.copyWith(
                                color: obd2Service.isConnected ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              obd2Service.isConnected
                                  ? 'Connected to ${obd2Service.selectedDevice?.platformName ?? 'OBD2 Device'}'
                                  : 'No OBD2 device connected',
                              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Connection Controls
                    if (obd2Service.isConnected) ...[
                      // Disconnect button when connected
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _disconnectFromDevice(),
                          icon: const Icon(Icons.bluetooth_disabled, size: 20),
                          label: const Text('Disconnect Device'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Scan and Connect buttons when disconnected
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _scanningDevices ? null : () => _scanForDevices(),
                          icon: _scanningDevices 
                              ? const SizedBox(
                                  width: 20, 
                                  height: 20, 
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                                )
                              : const Icon(Icons.search, size: 20),
                          label: Text(_scanningDevices ? 'Scanning...' : 'Scan for Devices'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FlutterFlowTheme.of(context).primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _connectingToDevice || obd2Service.selectedDevice == null ? null : () => _connectToDevice(),
                          icon: _connectingToDevice 
                              ? const SizedBox(
                                  width: 20, 
                                  height: 20, 
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                                )
                              : const Icon(Icons.bluetooth_connected, size: 20),
                          label: Text(_connectingToDevice ? 'Connecting...' : 'Connect Device'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: obd2Service.selectedDevice != null ? Colors.green : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Available Devices
                    if (obd2Service.availableDevices.isNotEmpty) ...[
                      Text(
                        'Available Devices',
                        style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...obd2Service.availableDevices.map((device) {
                        final isSelected = obd2Service.selectedDevice?.remoteId == device.remoteId;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isSelected 
                              ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
                              : FlutterFlowTheme.of(context).secondaryBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected 
                                  ? FlutterFlowTheme.of(context).primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.bluetooth,
                              color: isSelected 
                                  ? FlutterFlowTheme.of(context).primary
                                  : FlutterFlowTheme.of(context).secondaryText,
                            ),
                            title: Text(
                              device.platformName.isNotEmpty ? device.platformName : 'Unknown Device',
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected 
                                    ? FlutterFlowTheme.of(context).primary
                                    : FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                            subtitle: Text(
                              device.remoteId.toString(),
                              style: TextStyle(
                                color: isSelected 
                                    ? FlutterFlowTheme.of(context).primary.withOpacity(0.7)
                                    : FlutterFlowTheme.of(context).secondaryText,
                              ),
                            ),
                            trailing: isSelected 
                                ? Icon(
                                    Icons.check_circle,
                                    color: FlutterFlowTheme.of(context).primary,
                                  )
                                : null,
                            onTap: () {
                              obd2Service.selectDevice(device);
                              _showSnackBar('Selected ${device.platformName}', Colors.blue);
                            },
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 24),
                    ],
                    
                    // Permissions Section
                    Card(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Permissions',
                              style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'If scanning fails, you may need to grant permissions:',
                              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _forceBluetoothPermission(),
                                    icon: const Icon(Icons.bluetooth, size: 18),
                                    label: const Text('Bluetooth'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _forceLocationPermission(),
                                    icon: const Icon(Icons.location_on, size: 18),
                                    label: const Text('Location'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _checkPermissions(),
                                icon: const Icon(Icons.security, size: 18),
                                label: const Text('Check All Permissions'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Instructions
                    Card(
                      color: FlutterFlowTheme.of(context).secondaryBackground.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Setup Instructions',
                                  style: FlutterFlowTheme.of(context).titleSmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInstructionStep('1.', 'Turn on your vehicle\'s ignition'),
                                _buildInstructionStep('2.', 'Plug OBD2 scanner into the diagnostic port'),
                                _buildInstructionStep('3.', 'Tap "Scan for Devices" to find your scanner'),
                                _buildInstructionStep('4.', 'Select your device from the list'),
                                _buildInstructionStep('5.', 'Tap "Connect Device" to establish connection'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildInstructionStep(String number, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: FlutterFlowTheme.of(context).primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}