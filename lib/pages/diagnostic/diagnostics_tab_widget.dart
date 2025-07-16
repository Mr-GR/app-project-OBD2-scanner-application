import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:o_b_d2_scanner_frontend/config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/services/obd2_bluetooth_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DiagnosticsTabWidget extends StatefulWidget {
  const DiagnosticsTabWidget({super.key});

  @override
  State<DiagnosticsTabWidget> createState() => _DiagnosticsTabWidgetState();
}

class _DiagnosticsTabWidgetState extends State<DiagnosticsTabWidget> {
  final PageController _liveDataController = PageController(viewportFraction: 0.8);
  
  // OBD2 Bluetooth Service - shared singleton instance
  late OBD2BluetoothService _obd2Service;
  
  // Trouble codes
  List<Map<String, dynamic>> _activeCodes = [];
  List<Map<String, dynamic>> _pendingCodes = [];
  bool _codesLoading = false;
  String? _codesError;
  
  // AI Vehicle Analysis
  String? _aiAnalysis;
  bool _aiAnalysisLoading = false;
  
  // Connection loading states
  bool _scanningDevices = false;
  bool _connectingToDevice = false;

  @override
  void initState() {
    super.initState();
    print('DiagnosticsTabWidget initState called'); // Debug
    
    // Use shared OBD2 Bluetooth Service singleton
    _obd2Service = OBD2BluetoothService();
    
    // Listen for connection state changes
    _obd2Service.addListener(_onConnectionStateChanged);
    
    // Load data from OBD2 scanner
    _loadRealTroubleCodes();
    // AI analysis will be triggered manually by user clicking Analyze button
  }
  
  void _onConnectionStateChanged() {
    if (mounted) {
      setState(() {
        // Trigger UI update when connection state changes
      });
    }
  }
  
  Future<void> _tryAutoConnect() async {
    try {
      // Try to connect to OBD2 scanner automatically
      final connected = await _obd2Service.connectToOBD2Scanner();
      if (connected) {
        print('✅ Diagnostics tab auto-connected to OBD2 scanner');
        setState(() {
          // Trigger UI update when connected
        });
      } else {
        print('❌ Could not auto-connect to OBD2 scanner');
      }
    } catch (e) {
      print('Auto-connect error: $e');
    }
  }


  @override
  void dispose() {
    _obd2Service.removeListener(_onConnectionStateChanged);
    super.dispose();
  }

  Future<void> _loadRealTroubleCodes() async {
    setState(() {
      _codesLoading = true;
      _codesError = null;
    });

    try {
      // Check if connected, if not show error
      if (!_obd2Service.isConnected) {
        print('📱 OBD2 not connected, please connect via Connection tab');
        setState(() {
          _codesError = 'Not connected to OBD2 scanner. Please connect via Connection tab.';
          _codesLoading = false;
        });
        return;
      }
      
      print('🔍 Reading DTC codes from OBD2 scanner...');
      
      // Get real DTC codes from OBD2 scanner
      final dtcCodes = await _obd2Service.readDTCodes();
      
      print('📋 DTC codes received: $dtcCodes');
      
      if (mounted) {
        setState(() {
          if (dtcCodes.isEmpty) {
            _activeCodes = [];
            _pendingCodes = [];
            _codesError = null; // No error, just no codes
          } else {
            // Convert string codes to the expected format
            _activeCodes = dtcCodes.map((code) => {
              'code': code,
              'description': _obd2Service.getDTCDescription(code),
            }).toList();
            _pendingCodes = []; // For now, assume all codes are active
          }
          _codesLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading real trouble codes: $e');
      setState(() {
        _codesError = 'Failed to read DTC codes: $e';
        _codesLoading = false;
      });
    }
  }




  Future<void> _clearTroubleCodes() async {
    if (!_obd2Service.isConnected) {
      _showSnackBar('OBD2 scanner not connected', Colors.red);
      return;
    }
    
    try {
      // Send clear DTC command directly to OBD2 scanner
      final response = await _obd2Service.sendOBD2Command('04');
      if (response.contains('ERROR')) {
        _showSnackBar('Failed to clear codes: $response', Colors.red);
      } else {
        _showSnackBar('Trouble codes cleared successfully', Colors.green);
        // Wait a moment then reload codes
        await Future.delayed(const Duration(seconds: 2));
        _loadRealTroubleCodes();
      }
    } catch (e) {
      _showSnackBar('Error clearing codes: $e', Colors.red);
    }
  }

  Future<void> _generateAIAnalysis() async {
    setState(() {
      _aiAnalysisLoading = true;
    });

    try {
      // Gather data for AI analysis
      final Map<String, dynamic> analysisData = {
        'live_data': _obd2Service.liveData,
        'trouble_codes': _activeCodes,
        'connection_status': _obd2Service.isConnected,
        'device_name': _obd2Service.selectedDevice?.platformName ?? 'Unknown',
      };
      
      // Send data to AI analysis endpoint
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/chat/analyze-vehicle'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': 'Analyze my vehicle diagnostics data. Please provide text-only response without emojis or special characters.',
          'vehicle_data': analysisData,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _aiAnalysis = data['response'] ?? 'No analysis available';
            _aiAnalysisLoading = false;
          });
        }
      } else {
        setState(() {
          _aiAnalysis = 'AI analysis temporarily unavailable';
          _aiAnalysisLoading = false;
        });
      }
    } catch (e) {
      print('Error generating AI analysis: $e');
      if (mounted) {
        setState(() {
          _aiAnalysis = 'Unable to generate AI analysis. Please check connection.';
          _aiAnalysisLoading = false;
        });
      }
    }
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
        // Reload data after connection
        _loadRealTroubleCodes();
      } else if (mounted) {
        _showSnackBar('Failed to connect to device', Colors.red);
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
        _showSnackBar('🔵 Bluetooth permission requested! Check device settings if needed.', Colors.blue);
      } else {
        _showSnackBar('❌ Failed to request Bluetooth permission.', Colors.red);
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
        _showSnackBar('Error disconnecting: $e', Colors.red);
      }
    }
  }

  Future<void> _requestLiveDataSequential() async {
    print('🔍 Live Data button clicked - Connection status: ${_obd2Service.isConnected}');
    print('📊 Current live data: ${_obd2Service.liveData}');
    
    _showSnackBar('Requesting RPM data...', Colors.blue);
    
    // Use single request approach like connection tab (which works)
    // Start with RPM only to test - user can click multiple times for different data
    _obd2Service.requestData('rpm');
  }

  String _calculateFuelRange(dynamic fuelLevel) {
    if (fuelLevel == null) return '--';
    
    try {
      final fuelPercent = int.parse(fuelLevel.toString());
      // Estimate based on average car: 50L tank, 8L/100km fuel efficiency
      // Range = (tank_size * fuel_percent / 100) / (consumption_per_100km / 100)
      const double tankSize = 50.0; // liters
      const double fuelConsumption = 8.0; // L/100km
      
      final double remainingFuel = tankSize * (fuelPercent / 100.0);
      final double estimatedRange = (remainingFuel / fuelConsumption) * 100.0;
      
      return estimatedRange.round().toString();
    } catch (e) {
      return '--';
    }
  }

  Future<void> _exportReport() async {
    try {
      final pdf = await _generatePDF();
      
      // Use the printing package to handle PDF sharing/saving on iOS
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'OBD2_Diagnostic_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      
      _showSnackBar('Diagnostic report exported successfully', Colors.green);
    } catch (e) {
      print('Error exporting report: $e');
      _showSnackBar('Error exporting report: $e', Colors.red);
    }
  }

  Future<pw.Document> _generatePDF() async {
    final pdf = pw.Document();
    final timestamp = DateTime.now();
    final formattedDate = '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Column(
                children: [
                  pw.Text(
                    'OBD2 DIAGNOSTIC REPORT',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Generated: $formattedDate',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Scanner Status Section
            _buildPDFSection('SCANNER STATUS', [
              'Device: ${_obd2Service.selectedDevice?.platformName ?? 'Unknown'}',
              'Connection Status: ${_obd2Service.isConnected ? 'Connected' : 'Disconnected'}',
            ]),
            pw.SizedBox(height: 16),

            // Live Data Section
            if (_obd2Service.liveData.isNotEmpty) ...[
              _buildPDFSection('LIVE DATA', [
                if (_obd2Service.liveData['rpm'] != null) 'Engine RPM: ${_obd2Service.liveData['rpm']} rpm',
                if (_obd2Service.liveData['speed'] != null) 'Vehicle Speed: ${_obd2Service.liveData['speed']} mph',
                if (_obd2Service.liveData['engine_temp'] != null) 'Engine Temperature: ${_obd2Service.liveData['engine_temp']}°C',
                if (_obd2Service.liveData['fuel_level'] != null) 'Fuel Level: ${_obd2Service.liveData['fuel_level']}%',
              ]),
              pw.SizedBox(height: 16),
            ],

            // Trouble Codes Section
            _buildPDFSection('DIAGNOSTIC TROUBLE CODES', [
              'Active Codes Found: ${_activeCodes.length}',
              'Pending Codes Found: ${_pendingCodes.length}',
            ]),
            pw.SizedBox(height: 8),

            // Active Codes
            if (_activeCodes.isNotEmpty) ...[
              pw.Text('ACTIVE CODES:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
              pw.SizedBox(height: 4),
              ..._activeCodes.map((code) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 16, bottom: 4),
                child: pw.Text('• ${code['code']}: ${code['description']}'),
              )).toList(),
              pw.SizedBox(height: 12),
            ],

            // Pending Codes
            if (_pendingCodes.isNotEmpty) ...[
              pw.Text('PENDING CODES:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.orange800)),
              pw.SizedBox(height: 4),
              ..._pendingCodes.map((code) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 16, bottom: 4),
                child: pw.Text('• ${code['code']}: ${code['description']}'),
              )).toList(),
              pw.SizedBox(height: 16),
            ],

            // AI Analysis Section
            if (_aiAnalysis != null) ...[
              _buildPDFSection('AI VEHICLE ANALYSIS', []),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  _aiAnalysis!,
                  style: pw.TextStyle(fontSize: 11, lineSpacing: 1.2),
                ),
              ),
              pw.SizedBox(height: 24),
            ],

            // Legal Disclaimer
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'IMPORTANT LEGAL DISCLAIMER',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'This diagnostic report is provided for informational purposes only and should not be considered as professional automotive advice. '
                    'The information contained in this report is based on data retrieved from the vehicle\'s OBD2 system and may not reflect the complete '
                    'condition of your vehicle. Always consult with a qualified automotive technician before making any repairs or modifications to your vehicle. '
                    'The creators of this report are not responsible for any damages, injuries, or losses that may result from the use of this information. '
                    'Vehicle diagnostic codes can have multiple causes and proper diagnosis requires professional equipment and expertise. '
                    'This report does not guarantee the accuracy or completeness of the diagnostic information provided.',
                    style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildPDFSection(String title, List<String> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 6),
        ...items.map((item) => pw.Padding(
          padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
          child: pw.Text('• $item', style: pw.TextStyle(fontSize: 11)),
        )).toList(),
      ],
    );
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('DiagnosticsTabWidget build - isConnected: ${_obd2Service.isConnected}, activeCodes: ${_activeCodes.length}, aiAnalysis: ${_aiAnalysis != null}'); // Debug
    return ChangeNotifierProvider.value(
      value: _obd2Service,
      child: Consumer<OBD2BluetoothService>(
        builder: (context, obd2Service, child) {
          return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Diagnostics',
          style: FlutterFlowTheme.of(context).titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadRealTroubleCodes();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadRealTroubleCodes();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildScannerStatusCard(),
                const SizedBox(height: 24),
                _buildAIAnalysisSection(),
                const SizedBox(height: 24),
                _buildTroubleCodesSection(),
                const SizedBox(height: 24),
                _buildLiveDataCarousel(),
              ],
            ),
          ),
        ),
      ),
    );
        }
      ),
    );
  }

  Widget _buildScannerStatusCard() {
    return Consumer<OBD2BluetoothService>(
      builder: (context, obd2Service, child) {
        return Card(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      obd2Service.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                      color: obd2Service.isConnected ? Colors.green : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Scanner Status', style: FlutterFlowTheme.of(context).titleMedium),
                          Text(
                            obd2Service.isConnected 
                                ? 'Connected to ${obd2Service.selectedDevice?.platformName ?? 'OBD2 Device'}' 
                                : 'Disconnected - Use scanner controls below',
                            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                              color: obd2Service.isConnected ? Colors.green : Colors.grey,
                            ),
                          ),
                          if (obd2Service.isConnected && obd2Service.liveData.containsKey('scanner_error')) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                obd2Service.liveData['scanner_error'],
                                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                ),
                  ],
                ),
                if (obd2Service.isConnected) ...[
                  const SizedBox(height: 16),
                  // Disconnect button when connected
                  ElevatedButton.icon(
                    onPressed: () => _disconnectFromDevice(),
                    icon: const Icon(Icons.bluetooth_disabled, size: 18),
                    label: const Text('Disconnect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ] else if (!obd2Service.isConnected) ...[
                  const SizedBox(height: 16),
                  // Quick connection section
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _scanningDevices ? null : () => _scanForDevices(),
                          icon: _scanningDevices 
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.search, size: 18),
                          label: Text(_scanningDevices ? 'Scanning...' : 'Scan for Devices'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FlutterFlowTheme.of(context).primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _connectingToDevice || obd2Service.selectedDevice == null ? null : () => _connectToDevice(),
                          icon: _connectingToDevice 
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.bluetooth_connected, size: 18),
                          label: Text(_connectingToDevice ? 'Connecting...' : 'Connect'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Device selection list
                  if (obd2Service.availableDevices.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Available Devices (${obd2Service.availableDevices.length})',
                      style: FlutterFlowTheme.of(context).titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.25, // Max 25% of screen height
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: obd2Service.availableDevices.map((device) {
                            final isSelected = obd2Service.selectedDevice?.remoteId == device.remoteId;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 4),
                              color: isSelected 
                                  ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1)
                                  : null,
                              child: ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                leading: Icon(
                                  Icons.bluetooth,
                                  color: isSelected 
                                      ? FlutterFlowTheme.of(context).primary
                                      : Colors.grey,
                                  size: 20,
                                ),
                                title: Text(
                                  device.platformName.isNotEmpty 
                                      ? device.platformName 
                                      : 'Unknown Device',
                                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  device.remoteId.toString(),
                                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(fontSize: 10),
                                ),
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check_circle,
                                        color: FlutterFlowTheme.of(context).primary,
                                        size: 18,
                                      )
                                    : null,
                                onTap: () => obd2Service.selectDevice(device),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    Text(
                      'Tap "Scan for Devices" to find your OBD2 scanner, then select and connect.',
                      style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                        color: Colors.orange,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Permission buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _checkPermissions(),
                            icon: const Icon(Icons.security, size: 16),
                            label: const Text('Check Permissions', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _forceBluetoothPermission(),
                            icon: const Icon(Icons.bluetooth, size: 16),
                            label: const Text('Force Bluetooth', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _forceLocationPermission(),
                            icon: const Icon(Icons.location_on, size: 16),
                            label: const Text('Force Location', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiveDataCarousel() {
    return Consumer<OBD2BluetoothService>(
      builder: (context, obd2Service, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('Live Data', style: FlutterFlowTheme.of(context).titleMedium),
            ),
            const SizedBox(height: 12),
            if (!obd2Service.isConnected)
              Card(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.car_repair, size: 48, color: FlutterFlowTheme.of(context).secondaryText),
                      const SizedBox(height: 16),
                      Text('Connect to view live data', style: FlutterFlowTheme.of(context).titleMedium),
                    ],
                  ),
                ),
              )
            else if (obd2Service.liveData.containsKey('scanner_error'))
              Card(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.warning, size: 48, color: Colors.orange),
                      const SizedBox(height: 16),
                      Text(
                        'Scanner Connection Issue',
                        style: FlutterFlowTheme.of(context).titleMedium.copyWith(color: Colors.orange),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        obd2Service.liveData['scanner_error'],
                        style: FlutterFlowTheme.of(context).bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Troubleshooting Steps:',
                        style: FlutterFlowTheme.of(context).bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• Turn ignition ON or start engine', style: FlutterFlowTheme.of(context).bodySmall),
                          Text('• Check OBD2 port connection', style: FlutterFlowTheme.of(context).bodySmall),
                          Text('• Wait 30 seconds after connection', style: FlutterFlowTheme.of(context).bodySmall),
                          Text('• Try reconnecting scanner', style: FlutterFlowTheme.of(context).bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: [
                  _LiveDataRequestCard(
                    icon: Icons.speed,
                    color: Colors.blue,
                    title: 'RPM',
                    value: '${obd2Service.liveData['rpm'] ?? '--'}',
                    unit: 'rpm',
                    dataType: 'rpm',
                    service: obd2Service,
                    onRequest: () {
                      _showSnackBar('Requesting RPM data...', Colors.blue);
                      obd2Service.requestData('rpm');
                    },
                  ),
                  _LiveDataRequestCard(
                    icon: Icons.directions_car,
                    color: Colors.purple,
                    title: 'Speed',
                    value: '${obd2Service.liveData['speed'] ?? '--'}',
                    unit: 'km/h',
                    dataType: 'speed',
                    service: obd2Service,
                    onRequest: () {
                      _showSnackBar('Requesting speed data...', Colors.purple);
                      obd2Service.requestData('speed');
                    },
                  ),
                  _LiveDataRequestCard(
                    icon: Icons.thermostat,
                    color: Colors.red,
                    title: 'Engine Temp',
                    value: '${obd2Service.liveData['engine_temp'] ?? '--'}',
                    unit: '°C',
                    dataType: 'engine_temp',
                    service: obd2Service,
                    onRequest: () {
                      _showSnackBar('Requesting engine temperature...', Colors.red);
                      obd2Service.requestData('engine_temp');
                    },
                  ),
                  _LiveDataRequestCard(
                    icon: Icons.local_gas_station,
                    color: Colors.green,
                    title: 'Fuel Level',
                    value: '${obd2Service.liveData['fuel_level'] ?? '--'}',
                    unit: '%',
                    dataType: 'fuel_level',
                    service: obd2Service,
                    onRequest: () {
                      _showSnackBar('Requesting fuel level...', Colors.green);
                      obd2Service.requestData('fuel_level');
                    },
                  ),
                  _LiveDataRequestCard(
                    icon: Icons.linear_scale,
                    color: Colors.orange,
                    title: 'Throttle',
                    value: '${obd2Service.liveData['throttle_position'] ?? '--'}',
                    unit: '%',
                    dataType: 'throttle_position',
                    service: obd2Service,
                    onRequest: () {
                      _showSnackBar('Requesting throttle position...', Colors.orange);
                      obd2Service.requestData('throttle_position');
                    },
                  ),
                  _VINRequestCard(
                    vin: '${obd2Service.liveData['vin'] ?? 'Not available'}',
                    service: obd2Service,
                    onRequest: () {
                      _showSnackBar('Requesting VIN...', Colors.indigo);
                      obd2Service.requestData('vin');
                    },
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildTroubleCodesSection() {
    return Card(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Trouble Codes', style: FlutterFlowTheme.of(context).titleMedium),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _codesLoading ? null : _loadRealTroubleCodes,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Scan'),
                    ),
                    if (_activeCodes.isNotEmpty || _pendingCodes.isNotEmpty)
                      TextButton.icon(
                        onPressed: _clearTroubleCodes,
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Clear'),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_codesLoading)
              const Center(child: CircularProgressIndicator())
            else if (_codesError != null)
              Text(_codesError!, style: const TextStyle(color: Colors.red))
            else if (_activeCodes.isEmpty && _pendingCodes.isEmpty)
              Column(
                children: [
                  Icon(Icons.check_circle, size: 48, color: Colors.green),
                  const SizedBox(height: 8),
                  Text('No trouble codes found', style: FlutterFlowTheme.of(context).bodyMedium),
                ],
              )
            else
              Column(
                children: [
                  if (_activeCodes.isNotEmpty) ...[
                    _buildCodesList('Active Codes', _activeCodes, Colors.red),
                    const SizedBox(height: 16),
                  ],
                  if (_pendingCodes.isNotEmpty)
                    _buildCodesList('Pending Codes', _pendingCodes, Colors.orange),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodesList(String title, List<Map<String, dynamic>> codes, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: FlutterFlowTheme.of(context).titleSmall.copyWith(color: color)),
        const SizedBox(height: 8),
        ...codes.map((code) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(code['code'] ?? '', style: FlutterFlowTheme.of(context).titleSmall),
                    Text(code['description'] ?? '', style: FlutterFlowTheme.of(context).bodySmall),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildAIAnalysisSection() {
    return Card(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: FlutterFlowTheme.of(context).primary, size: 24),
                const SizedBox(width: 8),
                Text('AI Vehicle Analysis', style: FlutterFlowTheme.of(context).titleMedium),
                const Spacer(),
                TextButton.icon(
                  onPressed: _aiAnalysisLoading ? null : _generateAIAnalysis,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Analyze'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_aiAnalysisLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('AI is analyzing your vehicle data...'),
                  ],
                ),
              )
            else if (_aiAnalysis == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.psychology, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text('Tap "Analyze" to get AI insights about your vehicle', 
                         style: FlutterFlowTheme.of(context).bodyMedium),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: FlutterFlowTheme.of(context).primary, size: 20),
                        const SizedBox(width: 8),
                        Text('AI Insights', style: FlutterFlowTheme.of(context).titleSmall),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _aiAnalysis!,
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }


}

class _LiveDataRequestCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String unit;
  final String dataType;
  final OBD2BluetoothService service;
  final VoidCallback onRequest;

  const _LiveDataRequestCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.unit,
    required this.dataType,
    required this.service,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top section with icon and title
            Column(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 8),
                Text(
                  title, 
                  style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            
            // Middle section with value
            Column(
              children: [
                Text(
                  value,
                  style: FlutterFlowTheme.of(context).headlineSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  unit, 
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            
            // Bottom section with request button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: service.isConnected ? onRequest : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Request',
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VINRequestCard extends StatelessWidget {
  final String vin;
  final OBD2BluetoothService service;
  final VoidCallback onRequest;

  const _VINRequestCard({
    required this.vin,
    required this.service,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top section with icon and title
            Column(
              children: [
                Icon(Icons.confirmation_number, color: Colors.indigo, size: 28),
                const SizedBox(height: 8),
                Text(
                  'VIN', 
                  style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            
            // Middle section with VIN value
            Expanded(
              child: Center(
                child: Text(
                  vin,
                  style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            
            // Bottom section with request button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: service.isConnected ? onRequest : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Request',
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 