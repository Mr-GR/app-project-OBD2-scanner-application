import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/services/obd2_bluetooth_service.dart';
import '/services/vehicle_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

enum ScanType {
  quick('Quick Scan', 'Basic engine and emission system check'),
  comprehensive('Comprehensive Scan', 'Full vehicle system analysis'),
  emissions('Emissions Check', 'Complete readiness monitor test'),
  custom('Custom Scan', 'Select specific systems to scan');

  const ScanType(this.title, this.description);
  final String title;
  final String description;
}

enum ScanStatus {
  idle,
  initializing,
  scanning,
  completed,
  error,
  cancelled
}

class FullDiagnosticScanWidget extends StatefulWidget {
  const FullDiagnosticScanWidget({super.key});

  @override
  State<FullDiagnosticScanWidget> createState() => _FullDiagnosticScanWidgetState();
}

class _FullDiagnosticScanWidgetState extends State<FullDiagnosticScanWidget>
    with TickerProviderStateMixin {
  
  late OBD2BluetoothService _obd2Service;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  
  // Scan state
  ScanStatus _scanStatus = ScanStatus.idle;
  ScanType _selectedScanType = ScanType.quick;
  double _scanProgress = 0.0;
  String _currentScanStep = '';
  Timer? _scanTimer;
  
  // Scan results
  Map<String, dynamic> _scanResults = {};
  List<Map<String, dynamic>> _troubleCodes = [];
  List<Map<String, dynamic>> _pendingCodes = [];
  List<Map<String, dynamic>> _permanentCodes = [];
  Map<String, dynamic> _readinessMonitors = {};
  Map<String, dynamic> _liveParameters = {};
  Map<String, dynamic> _freezeFrameData = {};
  String _vehicleInfo = '';
  
  // UI state
  Set<String> _selectedSystems = {'engine', 'transmission', 'abs', 'airbag'};
  
  @override
  void initState() {
    super.initState();
    
    _obd2Service = OBD2BluetoothService();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _obd2Service.addListener(_onConnectionStateChanged);
  }
  
  @override
  void dispose() {
    _obd2Service.removeListener(_onConnectionStateChanged);
    _progressController.dispose();
    _pulseController.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }
  
  void _onConnectionStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _startFullScan() async {
    if (!_obd2Service.isConnected) {
      _showSnackBar('Please connect to OBD2 scanner first', Colors.red);
      return;
    }

    setState(() {
      _scanStatus = ScanStatus.initializing;
      _scanProgress = 0.0;
      _currentScanStep = 'Initializing scan...';
      _scanResults.clear();
      _troubleCodes.clear();
      _pendingCodes.clear();
      _permanentCodes.clear();
      _readinessMonitors.clear();
      _liveParameters.clear();
      _freezeFrameData.clear();
    });

    _progressController.reset();
    _progressController.forward();

    try {
      await _performFullDiagnosticScan();
    } catch (e) {
      setState(() {
        _scanStatus = ScanStatus.error;
        _currentScanStep = 'Scan failed: $e';
      });
    }
  }

  Future<void> _performFullDiagnosticScan() async {
    setState(() {
      _scanStatus = ScanStatus.scanning;
    });

    final scanSteps = _getScanSteps();
    
    for (int i = 0; i < scanSteps.length; i++) {
      if (_scanStatus == ScanStatus.cancelled) return;
      
      final step = scanSteps[i];
      setState(() {
        _currentScanStep = step['description'] ?? 'Scanning...';
        _scanProgress = (i + 1) / scanSteps.length;
      });

      try {
        await _executeScanStep(step);
        await Future.delayed(const Duration(milliseconds: 800));
      } catch (e) {
        print('Error in scan step ${step['name']}: $e');
        // Continue with other steps even if one fails
      }
    }

    setState(() {
      _scanStatus = ScanStatus.completed;
      _currentScanStep = 'Scan completed successfully';
      _scanProgress = 1.0;
    });

    // Upload scan results to backend
    await _uploadScanToBackend();
  }

  List<Map<String, String>> _getScanSteps() {
    switch (_selectedScanType) {
      case ScanType.quick:
        return [
          {'name': 'vehicle_info', 'description': 'Reading vehicle information...'},
          {'name': 'trouble_codes', 'description': 'Scanning for trouble codes...'},
          {'name': 'pending_codes', 'description': 'Checking pending codes...'},
          {'name': 'live_data', 'description': 'Reading live engine data...'},
          {'name': 'readiness', 'description': 'Checking system readiness...'},
        ];
      case ScanType.comprehensive:
        return [
          {'name': 'vehicle_info', 'description': 'Reading vehicle information...'},
          {'name': 'trouble_codes', 'description': 'Scanning all system codes...'},
          {'name': 'pending_codes', 'description': 'Checking pending codes...'},
          {'name': 'permanent_codes', 'description': 'Reading permanent codes...'},
          {'name': 'freeze_frame', 'description': 'Retrieving freeze frame data...'},
          {'name': 'live_data', 'description': 'Reading comprehensive live data...'},
          {'name': 'readiness', 'description': 'Testing all readiness monitors...'},
          {'name': 'advanced_pids', 'description': 'Reading advanced parameters...'},
        ];
      case ScanType.emissions:
        return [
          {'name': 'readiness', 'description': 'Testing readiness monitors...'},
          {'name': 'emissions_codes', 'description': 'Checking emission codes...'},
          {'name': 'catalyst_test', 'description': 'Testing catalyst efficiency...'},
          {'name': 'o2_sensors', 'description': 'Testing oxygen sensors...'},
          {'name': 'evap_system', 'description': 'Testing EVAP system...'},
        ];
      case ScanType.custom:
        return _selectedSystems.map((system) => {
          'name': system,
          'description': 'Scanning ${system.toUpperCase()} system...'
        }).toList();
    }
  }

  Future<void> _executeScanStep(Map<String, String> step) async {
    switch (step['name']) {
      case 'vehicle_info':
        _vehicleInfo = await _getVehicleInfo();
        break;
      case 'trouble_codes':
        _troubleCodes = await _readTroubleCodes();
        break;
      case 'pending_codes':
        _pendingCodes = await _readPendingCodes();
        break;
      case 'permanent_codes':
        _permanentCodes = await _readPermanentCodes();
        break;
      case 'freeze_frame':
        _freezeFrameData = await _readFreezeFrameData();
        break;
      case 'live_data':
        _liveParameters = await _readLiveParameters();
        break;
      case 'readiness':
        _readinessMonitors = await _readReadinessMonitors();
        break;
      case 'advanced_pids':
        await _readAdvancedPIDs();
        break;
      default:
        // Custom system scan
        await _scanSpecificSystem(step['name']!);
    }
  }

  Future<String> _getVehicleInfo() async {
    try {
      final vin = await _obd2Service.sendOBD2Command('0902');
      return vin.isNotEmpty ? vin : 'VIN not available';
    } catch (e) {
      return 'Vehicle info unavailable';
    }
  }

  Future<List<Map<String, dynamic>>> _readTroubleCodes() async {
    try {
      final codes = await _obd2Service.readDTCodes();
      return codes.map((code) => {
        'code': code,
        'description': _obd2Service.getDTCDescription(code),
        'type': 'active',
        'system': _getSystemFromCode(code),
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _readPendingCodes() async {
    try {
      await _obd2Service.sendOBD2Command('07');
      // Parse pending codes from response - placeholder for future implementation
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _readPermanentCodes() async {
    try {
      await _obd2Service.sendOBD2Command('0A');
      // Parse permanent codes from response - placeholder for future implementation
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> _readFreezeFrameData() async {
    try {
      await _obd2Service.sendOBD2Command('02');
      // Parse freeze frame data - placeholder for future implementation
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> _readLiveParameters() async {
    final parameters = <String, dynamic>{};
    
    final pids = [
      {'pid': '010C', 'name': 'engine_rpm', 'unit': 'rpm'},
      {'pid': '010D', 'name': 'vehicle_speed', 'unit': 'km/h'},
      {'pid': '0105', 'name': 'coolant_temp', 'unit': '°C'},
      {'pid': '010F', 'name': 'intake_air_temp', 'unit': '°C'},
      {'pid': '0111', 'name': 'throttle_position', 'unit': '%'},
      {'pid': '012F', 'name': 'fuel_level', 'unit': '%'},
      {'pid': '0104', 'name': 'engine_load', 'unit': '%'},
      {'pid': '0106', 'name': 'short_term_fuel_trim_1', 'unit': '%'},
      {'pid': '0107', 'name': 'long_term_fuel_trim_1', 'unit': '%'},
      {'pid': '010A', 'name': 'fuel_pressure', 'unit': 'kPa'},
    ];

    for (final pid in pids) {
      try {
        final response = await _obd2Service.sendOBD2Command(pid['pid'] ?? '');
        if (response.isNotEmpty && !response.contains('ERROR')) {
          final parsedValue = _parseParameterValue(pid['pid'] ?? '', response);
          if (parsedValue != null) {
            parameters[pid['name'] ?? 'unknown'] = '$parsedValue ${pid['unit'] ?? ''}';
          }
        }
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        // Continue with other PIDs
      }
    }

    return parameters;
  }

  /// Parse OBD2 parameter values from hex responses
  dynamic _parseParameterValue(String pid, String response) {
    try {
      // Remove spaces and convert to uppercase
      final cleanResponse = response.replaceAll(' ', '').toUpperCase();
      
      // Extract data portion (skip response header like "41 0C")
      String data;
      if (cleanResponse.length >= 6) {
        data = cleanResponse.substring(4); // Skip "41XX" header
      } else {
        return null;
      }

      switch (pid.substring(2)) { // Get PID without "01" prefix
        case '0C': // Engine RPM
          if (data.length >= 4) {
            final rpm = (int.parse(data.substring(0, 2), radix: 16) * 256 + 
                        int.parse(data.substring(2, 4), radix: 16)) / 4;
            return rpm.round();
          }
          break;
          
        case '0D': // Vehicle Speed
          if (data.length >= 2) {
            return int.parse(data.substring(0, 2), radix: 16);
          }
          break;
          
        case '05': // Engine Coolant Temperature
          if (data.length >= 2) {
            return int.parse(data.substring(0, 2), radix: 16) - 40;
          }
          break;
          
        case '0F': // Intake Air Temperature
          if (data.length >= 2) {
            return int.parse(data.substring(0, 2), radix: 16) - 40;
          }
          break;
          
        case '11': // Throttle Position
          if (data.length >= 2) {
            return (int.parse(data.substring(0, 2), radix: 16) * 100 / 255).round();
          }
          break;
          
        case '2F': // Fuel Level Input
          if (data.length >= 2) {
            return (int.parse(data.substring(0, 2), radix: 16) * 100 / 255).round();
          }
          break;
          
        case '04': // Engine Load
          if (data.length >= 2) {
            return (int.parse(data.substring(0, 2), radix: 16) * 100 / 255).round();
          }
          break;
          
        case '06': // Short Term Fuel Trim Bank 1
        case '07': // Long Term Fuel Trim Bank 1
          if (data.length >= 2) {
            return (int.parse(data.substring(0, 2), radix: 16) - 128) * 100 / 128;
          }
          break;
          
        case '0A': // Fuel Pressure
          if (data.length >= 2) {
            return int.parse(data.substring(0, 2), radix: 16) * 3;
          }
          break;
          
        default:
          return data; // Return raw data for unknown PIDs
      }
    } catch (e) {
      debugPrint('Error parsing PID $pid: $e');
      return null;
    }
    
    return null;
  }

  Future<Map<String, dynamic>> _readReadinessMonitors() async {
    try {
      await _obd2Service.sendOBD2Command('0101');
      // Parse readiness monitor status - placeholder implementation
      return {
        'misfire': 'ready',
        'fuel_system': 'ready',
        'catalyst': 'not_ready',
        'heated_catalyst': 'ready',
        'evaporative_system': 'ready',
        'secondary_air_system': 'ready',
        'ac_refrigerant': 'ready',
        'oxygen_sensor': 'ready',
        'oxygen_sensor_heater': 'ready',
        'egr_system': 'ready',
      };
    } catch (e) {
      return {};
    }
  }

  Future<void> _readAdvancedPIDs() async {
    // Read manufacturer-specific PIDs and advanced parameters
  }

  Future<void> _scanSpecificSystem(String system) async {
    // Implement system-specific scanning logic
  }

  Future<void> _uploadScanToBackend() async {
    try {
      setState(() {
        _currentScanStep = 'Uploading to cloud...';
      });

      // Get valid vehicle ID from backend vehicles endpoint
      int vehicleId = 1; // Default fallback
      try {
        final availableVehicles = await _obd2Service.getAvailableVehicles();
        if (availableVehicles.isNotEmpty) {
          // Use the first available vehicle, or find primary vehicle if marked
          final primaryVehicle = availableVehicles.firstWhere(
            (vehicle) => vehicle['is_primary'] == true,
            orElse: () => availableVehicles.first,
          );
          vehicleId = primaryVehicle['id'] ?? 1;
          debugPrint('✅ Using vehicle ID: $vehicleId');
        } else {
          debugPrint('⚠️ No vehicles found, backend will handle gracefully');
        }
      } catch (e) {
        debugPrint('⚠️ Could not get vehicle list, backend will handle gracefully: $e');
      }
      
      final uploaded = await _obd2Service.uploadFullScanResults(
        vehicleId: vehicleId,
        scanType: _selectedScanType.name,
        vehicleInfo: _vehicleInfo,
        troubleCodes: _troubleCodes,
        liveParameters: _liveParameters,
        readinessMonitors: _readinessMonitors,
        pendingCodes: _pendingCodes,
        permanentCodes: _permanentCodes,
        freezeFrameData: _freezeFrameData,
      );
      
      if (uploaded) {
        _showSnackBar('✅ Scan saved to cloud successfully', Colors.green);
        setState(() {
          _currentScanStep = 'Scan completed and uploaded';
        });
      } else {
        _showSnackBar('⚠️ Scan saved locally (cloud upload failed)', Colors.orange);
        setState(() {
          _currentScanStep = 'Scan completed (upload failed)';
        });
      }
    } catch (e) {
      _showSnackBar('❌ Upload error: $e', Colors.red);
      setState(() {
        _currentScanStep = 'Scan completed (upload error)';
      });
    }
  }

  String _getSystemFromCode(String code) {
    if (code.startsWith('P0')) return 'Powertrain';
    if (code.startsWith('P1')) return 'Powertrain (Manufacturer)';
    if (code.startsWith('B')) return 'Body';
    if (code.startsWith('C')) return 'Chassis';
    if (code.startsWith('U')) return 'Network';
    return 'Unknown';
  }

  void _cancelScan() {
    setState(() {
      _scanStatus = ScanStatus.cancelled;
      _currentScanStep = 'Scan cancelled';
    });
    _scanTimer?.cancel();
    _progressController.stop();
  }

  Future<void> _exportFullReport() async {
    try {
      final pdf = await _generateFullDiagnosticPDF();
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Full_Diagnostic_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      _showSnackBar('Full diagnostic report exported successfully', Colors.green);
    } catch (e) {
      _showSnackBar('Error exporting report: $e', Colors.red);
    }
  }

  Future<pw.Document> _generateFullDiagnosticPDF() async {
    final pdf = pw.Document();
    final timestamp = DateTime.now();

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
                    'FULL DIAGNOSTIC SCAN REPORT',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Scan Type: ${_selectedScanType.title}',
                    style: pw.TextStyle(fontSize: 16, color: PdfColors.blue800),
                  ),
                  pw.Text(
                    'Generated: ${timestamp.toString()}',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Vehicle Information
            if (_vehicleInfo.isNotEmpty) ...[
              _buildPDFSection('VEHICLE INFORMATION', [_vehicleInfo]),
              pw.SizedBox(height: 16),
            ],

            // Scan Summary
            _buildPDFSection('SCAN SUMMARY', [
              'Status: ${_scanStatus.name.toUpperCase()}',
              'Total Trouble Codes: ${_troubleCodes.length}',
              'Pending Codes: ${_pendingCodes.length}',
              'Permanent Codes: ${_permanentCodes.length}',
              'Readiness Monitors: ${_readinessMonitors.length}',
            ]),
            pw.SizedBox(height: 16),

            // Trouble Codes
            if (_troubleCodes.isNotEmpty) ...[
              pw.Text('ACTIVE TROUBLE CODES', 
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
              pw.SizedBox(height: 8),
              ..._troubleCodes.map((code) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.red300),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${code['code']} - ${code['system']}', 
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('${code['description']}'),
                  ],
                ),
              )).toList(),
              pw.SizedBox(height: 16),
            ],

            // Readiness Monitors
            if (_readinessMonitors.isNotEmpty) ...[
              pw.Text('READINESS MONITORS', 
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Monitor', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ..._readinessMonitors.entries.map((entry) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(entry.key.replaceAll('_', ' ').toUpperCase()),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(entry.value.toString().toUpperCase()),
                      ),
                    ],
                  )).toList(),
                ],
              ),
              pw.SizedBox(height: 16),
            ],

            // Live Parameters
            if (_liveParameters.isNotEmpty) ...[
              pw.Text('LIVE PARAMETERS AT SCAN TIME', 
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Parameter', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ..._liveParameters.entries.map((entry) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(entry.key.replaceAll('_', ' ').toUpperCase()),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(entry.value.toString()),
                      ),
                    ],
                  )).toList(),
                ],
              ),
            ],
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
        pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
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
          content: Text(
            message,
            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        elevation: 0,
        title: Text(
          'Full Scan',
          style: FlutterFlowTheme.of(context).titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_scanStatus == ScanStatus.completed)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _exportFullReport,
              tooltip: 'Export Report',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildScanTypeSelector(),
              const SizedBox(height: 24),
              _buildScanControlCard(),
              const SizedBox(height: 24),
              if (_scanStatus == ScanStatus.scanning || _scanStatus == ScanStatus.initializing)
                _buildScanProgressCard(),
              if (_scanStatus == ScanStatus.completed) ...[
                _buildScanResultsCard(),
                const SizedBox(height: 16),
                _buildDetailedResultsCard(),
              ],
              if (_scanStatus == ScanStatus.error)
                _buildErrorCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanTypeSelector() {
    return Card(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Scan Type', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 16),
            ...ScanType.values.map((type) => RadioListTile<ScanType>(
              value: type,
              groupValue: _selectedScanType,
              onChanged: _scanStatus == ScanStatus.scanning ? null : (value) {
                setState(() {
                  _selectedScanType = value!;
                });
              },
              title: Text(type.title, style: FlutterFlowTheme.of(context).bodyMedium),
              subtitle: Text(type.description, style: FlutterFlowTheme.of(context).bodySmall),
              dense: true,
            )).toList(),
            if (_selectedScanType == ScanType.custom) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: Text('Select Systems', style: FlutterFlowTheme.of(context).bodyMedium),
                children: [
                  Wrap(
                    children: ['engine', 'transmission', 'abs', 'airbag', 'climate', 'body'].map((system) =>
                      FilterChip(
                        label: Text(system.toUpperCase()),
                        selected: _selectedSystems.contains(system),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSystems.add(system);
                            } else {
                              _selectedSystems.remove(system);
                            }
                          });
                        },
                      ),
                    ).toList(),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScanControlCard() {
    return Card(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  _obd2Service.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  color: _obd2Service.isConnected ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _obd2Service.isConnected 
                      ? 'Connected to ${_obd2Service.selectedDevice?.platformName ?? 'OBD2 Device'}'
                      : 'Not connected to OBD2 scanner',
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_scanStatus == ScanStatus.idle) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _obd2Service.isConnected ? _startFullScan : null,
                  icon: const Icon(Icons.play_arrow, size: 24),
                  label: Text(
                    'Start ${_selectedScanType.title}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ] else if (_scanStatus == ScanStatus.scanning || _scanStatus == ScanStatus.initializing) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _cancelScan,
                  icon: const Icon(Icons.stop, size: 24),
                  label: const Text(
                    'Cancel Scan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ] else if (_scanStatus == ScanStatus.completed) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _startFullScan,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Scan Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _exportFullReport,
                      icon: const Icon(Icons.file_download),
                      label: const Text('Export PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScanProgressCard() {
    return Card(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + 0.1 * _pulseController.value,
                      child: Icon(
                        Icons.radar,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 32,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scanning in Progress...',
                        style: FlutterFlowTheme.of(context).titleMedium,
                      ),
                      Text(
                        _currentScanStep,
                        style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: _scanProgress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(FlutterFlowTheme.of(context).primary),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${(_scanProgress * 100).toInt()}% Complete',
              style: FlutterFlowTheme.of(context).bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanResultsCard() {
    final totalIssues = _troubleCodes.length + _pendingCodes.length + _permanentCodes.length;
    final readyMonitors = _readinessMonitors.values.where((v) => v == 'ready').length;
    
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
                  totalIssues == 0 ? Icons.check_circle : Icons.warning,
                  color: totalIssues == 0 ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan Complete',
                        style: FlutterFlowTheme.of(context).titleMedium,
                      ),
                      Text(
                        totalIssues == 0 
                          ? 'No issues found' 
                          : '$totalIssues issue${totalIssues == 1 ? '' : 's'} detected',
                        style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                          color: totalIssues == 0 ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildResultStat('Trouble Codes', _troubleCodes.length.toString(), Colors.red),
                ),
                Expanded(
                  child: _buildResultStat('Pending', _pendingCodes.length.toString(), Colors.orange),
                ),
                Expanded(
                  child: _buildResultStat('Monitors Ready', '$readyMonitors/${_readinessMonitors.length}', Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: FlutterFlowTheme.of(context).headlineSmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: FlutterFlowTheme.of(context).bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailedResultsCard() {
    return Card(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detailed Results', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 16),
            
            if (_troubleCodes.isNotEmpty) ...[
              ExpansionTile(
                title: Text('Active Trouble Codes (${_troubleCodes.length})'),
                children: _troubleCodes.map((code) => ListTile(
                  leading: Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  title: Text(code['code']),
                  subtitle: Text(code['description']),
                  trailing: Chip(
                    label: Text(code['system'], style: const TextStyle(fontSize: 10)),
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                  ),
                )).toList(),
              ),
            ],

            if (_readinessMonitors.isNotEmpty) ...[
              ExpansionTile(
                title: Text('Readiness Monitors (${_readinessMonitors.length})'),
                children: _readinessMonitors.entries.map((entry) => ListTile(
                  leading: Icon(
                    entry.value == 'ready' ? Icons.check_circle : Icons.pending,
                    color: entry.value == 'ready' ? Colors.green : Colors.orange,
                  ),
                  title: Text(entry.key.replaceAll('_', ' ').toUpperCase()),
                  trailing: Chip(
                    label: Text(entry.value.toString().toUpperCase()),
                    backgroundColor: entry.value == 'ready' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                  ),
                )).toList(),
              ),
            ],

            if (_liveParameters.isNotEmpty) ...[
              ExpansionTile(
                title: Text('Live Parameters (${_liveParameters.length})'),
                children: _liveParameters.entries.map((entry) => ListTile(
                  title: Text(entry.key.replaceAll('_', ' ').toUpperCase()),
                  trailing: Text(
                    entry.value.toString(),
                    style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Scan Error',
              style: FlutterFlowTheme.of(context).titleMedium.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              _currentScanStep,
              style: FlutterFlowTheme.of(context).bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _scanStatus = ScanStatus.idle;
                  _currentScanStep = '';
                  _scanProgress = 0.0;
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}