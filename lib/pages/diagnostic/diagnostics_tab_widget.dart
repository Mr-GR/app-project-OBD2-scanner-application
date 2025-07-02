import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:o_b_d2_scanner_frontend/config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class DiagnosticsTabWidget extends StatefulWidget {
  const DiagnosticsTabWidget({super.key});

  @override
  State<DiagnosticsTabWidget> createState() => _DiagnosticsTabWidgetState();
}

class _DiagnosticsTabWidgetState extends State<DiagnosticsTabWidget> {
  final PageController _liveDataController = PageController(viewportFraction: 0.8);
  
  // Scanner status
  bool _isConnected = false;
  bool _isConnecting = false;
  String _deviceName = 'ELM327 OBD2';
  double _batteryVoltage = 0.0;
  
  // Live data
  Map<String, dynamic> _liveData = {};
  bool _liveDataLoading = false;
  Timer? _liveDataTimer;
  
  // Trouble codes
  List<Map<String, dynamic>> _activeCodes = [];
  List<Map<String, dynamic>> _pendingCodes = [];
  bool _codesLoading = false;
  String? _codesError;
  
  // Vehicle health
  Map<String, dynamic> _healthStatus = {};
  bool _healthLoading = false;

  @override
  void initState() {
    super.initState();
    print('DiagnosticsTabWidget initState called'); // Debug
    
    // Load mock data immediately for testing
    _loadMockData();
    
    // Temporarily disable API calls for testing
    // _loadScannerStatus();
    // _loadTroubleCodes();
    // _loadVehicleHealth();
  }

  void _loadMockData() {
    print('Loading mock data...'); // Debug
    // Force mock data to load immediately
    setState(() {
      // Scanner status mock data
      _isConnected = true;
      _isConnecting = false;
      _deviceName = 'ELM327 Bluetooth OBD2';
      _batteryVoltage = 12.4;
      
      // Trouble codes mock data
      _activeCodes = [
        {
          'code': 'P0420',
          'description': 'Catalyst System Efficiency Below Threshold (Bank 1)',
          'severity': 'warning'
        }
      ];
      _pendingCodes = [
        {
          'code': 'P0171',
          'description': 'System Too Lean (Bank 1)',
          'severity': 'warning'
        },
        {
          'code': 'P0442',
          'description': 'Evaporative Emission Control System Leak Detected (small leak)',
          'severity': 'info'
        }
      ];
      _codesLoading = false;
      _codesError = null;
      
      // Vehicle health mock data
      _healthStatus = {
        'engine': 'good',
        'transmission': 'good',
        'emissions': 'warning',
        'fuel_system': 'warning',
        'cooling_system': 'good',
        'electrical_system': 'good',
        'brake_system': 'good',
        'exhaust_system': 'warning'
      };
      _healthLoading = false;
      
      // Live data mock
      _liveData = {
        'rpm': 850,
        'speed': 0,
        'engine_temp': 88,
        'fuel_level': 68,
      };
      _liveDataLoading = false;
    });
    
    print('Mock data loaded - isConnected: $_isConnected'); // Debug
    
    // Start live data updates since we're "connected"
    if (_liveDataTimer == null) {
      _startLiveDataUpdates();
    }
  }

  @override
  void dispose() {
    _liveDataTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadScannerStatus() async {
    try {
      final response = await http.get(Uri.parse('http://${Config.baseUrl}/api/scanner/status'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _isConnected = data['connected'] ?? false;
            _deviceName = data['device_name'] ?? 'ELM327 OBD2';
            _batteryVoltage = (data['battery_voltage'] ?? 0.0).toDouble();
          });
          
          if (_isConnected && _liveDataTimer == null) {
            _startLiveDataUpdates();
          }
        }
      }
    } catch (e) {
      print('Error loading scanner status: $e');
      // Use mock data for testing
      _loadMockScannerStatus();
    }
  }

  void _loadMockScannerStatus() {
    if (mounted) {
      setState(() {
        _isConnected = true;
        _deviceName = 'ELM327 Bluetooth OBD2';
        _batteryVoltage = 12.4;
      });
      
      if (_isConnected && _liveDataTimer == null) {
        _startLiveDataUpdates();
      }
    }
  }

  Future<void> _toggleConnection() async {
    if (_isConnecting) return;
    
    setState(() {
      _isConnecting = true;
    });

    try {
      final endpoint = _isConnected ? 'disconnect' : 'connect';
      final response = await http.post(Uri.parse('http://${Config.baseUrl}/api/scanner/$endpoint'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _isConnected = data['connected'] ?? !_isConnected;
          });
          
          if (_isConnected) {
            _startLiveDataUpdates();
            _showSnackBar('Connected to OBD2 scanner', Colors.green);
          } else {
            _stopLiveDataUpdates();
            _showSnackBar('Disconnected from OBD2 scanner', Colors.orange);
          }
        }
      }
    } catch (e) {
      _showSnackBar('Connection error: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  void _startLiveDataUpdates() {
    _liveDataTimer?.cancel();
    _liveDataTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _loadLiveData();
    });
  }

  void _stopLiveDataUpdates() {
    _liveDataTimer?.cancel();
    _liveDataTimer = null;
  }

  Future<void> _loadLiveData() async {
    if (!_isConnected) return;
    
    try {
      final response = await http.get(Uri.parse('http://${Config.baseUrl}/api/scanner/live-data'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _liveData = data;
            _liveDataLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading live data: $e');
      // Use mock data for testing
      _loadMockLiveData();
    }
  }

  void _loadMockLiveData() {
    if (!_isConnected) return;
    
    // Simulate realistic changing values
    final baseRpm = 800;
    final rpmVariation = (DateTime.now().millisecondsSinceEpoch % 1000) / 10;
    
    if (mounted) {
      setState(() {
        _liveData = {
          'rpm': (baseRpm + rpmVariation).round(),
          'speed': 0, // Idle speed
          'engine_temp': 87 + (DateTime.now().millisecondsSinceEpoch % 100) / 50, // 87-89°C
          'fuel_level': 68, // 68% fuel
          'throttle_position': 0, // Idle
          'intake_air_temp': 25,
          'coolant_temp': 88,
          'fuel_pressure': 3.2,
        };
        _liveDataLoading = false;
      });
    }
  }

  Future<void> _loadTroubleCodes() async {
    setState(() {
      _codesLoading = true;
      _codesError = null;
    });

    try {
      final response = await http.get(Uri.parse('http://${Config.baseUrl}/api/scanner/dtc/scan'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _activeCodes = List<Map<String, dynamic>>.from(data['active_codes'] ?? []);
            _pendingCodes = List<Map<String, dynamic>>.from(data['pending_codes'] ?? []);
            _codesLoading = false;
          });
        }
      } else {
        setState(() {
          _codesError = 'Failed to scan for codes';
          _codesLoading = false;
        });
      }
    } catch (e) {
      print('Error loading trouble codes: $e');
      // Use mock data for testing
      _loadMockTroubleCodes();
    }
  }

  void _loadMockTroubleCodes() {
    if (mounted) {
      setState(() {
        _activeCodes = [
          {
            'code': 'P0420',
            'description': 'Catalyst System Efficiency Below Threshold (Bank 1)',
            'severity': 'warning'
          }
        ];
        _pendingCodes = [
          {
            'code': 'P0171',
            'description': 'System Too Lean (Bank 1)',
            'severity': 'warning'
          },
          {
            'code': 'P0442',
            'description': 'Evaporative Emission Control System Leak Detected (small leak)',
            'severity': 'info'
          }
        ];
        _codesLoading = false;
        _codesError = null;
      });
    }
  }

  Future<void> _clearTroubleCodes() async {
    try {
      final response = await http.post(Uri.parse('http://${Config.baseUrl}/api/scanner/dtc/clear'));
      if (response.statusCode == 200) {
        _showSnackBar('Trouble codes cleared', Colors.green);
        _loadTroubleCodes();
      } else {
        _showSnackBar('Failed to clear codes', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error clearing codes: $e', Colors.red);
    }
  }

  Future<void> _loadVehicleHealth() async {
    setState(() {
      _healthLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://${Config.baseUrl}/api/scanner/health-check'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _healthStatus = data;
            _healthLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading vehicle health: $e');
      // Use mock data for testing
      _loadMockVehicleHealth();
    }
  }

  void _loadMockVehicleHealth() {
    if (mounted) {
      setState(() {
        _healthStatus = {
          'engine': 'good',
          'transmission': 'good',
          'emissions': 'warning', // Because of P0420 code
          'fuel_system': 'warning', // Because of P0171 code
          'cooling_system': 'good',
          'electrical_system': 'good',
          'brake_system': 'good',
          'exhaust_system': 'warning'
        };
        _healthLoading = false;
      });
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
              'Device: $_deviceName',
              'Connection Status: ${_isConnected ? 'Connected' : 'Disconnected'}',
              if (_batteryVoltage > 0) 'Battery Voltage: ${_batteryVoltage.toStringAsFixed(1)}V',
            ]),
            pw.SizedBox(height: 16),

            // Live Data Section
            if (_liveData.isNotEmpty) ...[
              _buildPDFSection('LIVE DATA', [
                if (_liveData['rpm'] != null) 'Engine RPM: ${_liveData['rpm']} rpm',
                if (_liveData['speed'] != null) 'Vehicle Speed: ${_liveData['speed']} mph',
                if (_liveData['engine_temp'] != null) 'Engine Temperature: ${_liveData['engine_temp']}°C',
                if (_liveData['fuel_level'] != null) 'Fuel Level: ${_liveData['fuel_level']}%',
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

            // Vehicle Health Section
            if (_healthStatus.isNotEmpty) ...[
              _buildPDFSection('VEHICLE HEALTH STATUS', []),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: _healthStatus.entries.map((entry) {
                  final status = entry.value.toString().toUpperCase();
                  final color = status == 'GOOD' ? PdfColors.green800 :
                               status == 'WARNING' ? PdfColors.orange800 : PdfColors.red800;
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(entry.key.toUpperCase().replaceAll('_', ' ')),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(status, style: pw.TextStyle(color: color, fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  );
                }).toList(),
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
    print('DiagnosticsTabWidget build - isConnected: $_isConnected, activeCodes: ${_activeCodes.length}, healthStatus: ${_healthStatus.keys.length}'); // Debug
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
              _loadScannerStatus();
              _loadTroubleCodes();
              _loadVehicleHealth();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _loadScannerStatus(),
            _loadTroubleCodes(),
            _loadVehicleHealth(),
          ]);
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
                _buildLiveDataCarousel(),
                const SizedBox(height: 24),
                _buildTroubleCodesSection(),
                const SizedBox(height: 24),
                _buildVehicleHealthDashboard(),
                const SizedBox(height: 24),
                _buildQuickActionsGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScannerStatusCard() {
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
                  _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  color: _isConnected ? Colors.green : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Scanner Status', style: FlutterFlowTheme.of(context).titleMedium),
                      Text(
                        _isConnected ? 'Connected to $_deviceName' : 'Disconnected',
                        style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                          color: _isConnected ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _isConnecting ? null : _toggleConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isConnected ? Colors.red : FlutterFlowTheme.of(context).primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isConnecting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isConnected ? 'Disconnect' : 'Connect'),
                ),
              ],
            ),
            if (_isConnected && _batteryVoltage > 0) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.battery_std, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text('Battery: ${_batteryVoltage.toStringAsFixed(1)}V'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLiveDataCarousel() {
    if (!_isConnected) {
      return Card(
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
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('Live Data', style: FlutterFlowTheme.of(context).titleMedium),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: PageView(
            controller: _liveDataController,
            children: [
              _LiveDataCard(
                icon: Icons.speed,
                color: Colors.blue,
                title: 'RPM',
                value: '${_liveData['rpm'] ?? '--'}',
                unit: 'rpm',
              ),
              _LiveDataCard(
                icon: Icons.flash_on,
                color: Colors.orange,
                title: 'Speed',
                value: '${_liveData['speed'] ?? '--'}',
                unit: 'mph',
              ),
              _LiveDataCard(
                icon: Icons.thermostat,
                color: Colors.red,
                title: 'Engine Temp',
                value: '${_liveData['engine_temp'] ?? '--'}',
                unit: '°C',
              ),
              _LiveDataCard(
                icon: Icons.local_gas_station,
                color: Colors.green,
                title: 'Fuel Level',
                value: '${_liveData['fuel_level'] ?? '--'}',
                unit: '%',
              ),
            ],
          ),
        ),
      ],
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
                      onPressed: _codesLoading ? null : _loadTroubleCodes,
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
            border: Border.all(color: color.withOpacity(0.3)),
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

  Widget _buildVehicleHealthDashboard() {
    return Card(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle Health', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 16),
            
            if (_healthLoading)
              const Center(child: CircularProgressIndicator())
            else if (_healthStatus.isEmpty)
              Text('Health data unavailable', style: FlutterFlowTheme.of(context).bodyMedium)
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  _buildHealthItem('Engine', _healthStatus['engine'] ?? 'unknown'),
                  _buildHealthItem('Transmission', _healthStatus['transmission'] ?? 'unknown'),
                  _buildHealthItem('Emissions', _healthStatus['emissions'] ?? 'unknown'),
                  _buildHealthItem('Fuel System', _healthStatus['fuel_system'] ?? 'unknown'),
                  _buildHealthItem('Cooling', _healthStatus['cooling_system'] ?? 'unknown'),
                  _buildHealthItem('Electrical', _healthStatus['electrical_system'] ?? 'unknown'),
                  _buildHealthItem('Brakes', _healthStatus['brake_system'] ?? 'unknown'),
                  _buildHealthItem('Exhaust', _healthStatus['exhaust_system'] ?? 'unknown'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthItem(String title, String status) {
    Color statusColor;
    IconData statusIcon;
    
    switch (status.toLowerCase()) {
      case 'good':
      case 'ok':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'warning':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case 'error':
      case 'critical':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: FlutterFlowTheme.of(context).bodySmall),
                Text(status.toUpperCase(), 
                     style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                       color: statusColor,
                       fontWeight: FontWeight.bold,
                     )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Card(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Actions', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _QuickActionButton(
                  icon: Icons.search,
                  title: 'Full Scan',
                  color: Colors.blue,
                  onTap: _loadTroubleCodes,
                ),
                _QuickActionButton(
                  icon: Icons.timeline,
                  title: 'Live Data',
                  color: Colors.green,
                  onTap: _isConnected ? _loadLiveData : null,
                ),
                _QuickActionButton(
                  icon: Icons.clear,
                  title: 'Clear Codes',
                  color: Colors.red,
                  onTap: (_activeCodes.isNotEmpty || _pendingCodes.isNotEmpty) ? _clearTroubleCodes : null,
                ),
                _QuickActionButton(
                  icon: Icons.download,
                  title: 'Export Report',
                  color: Colors.orange,
                  onTap: _exportReport,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveDataCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String unit;

  const _LiveDataCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(title, style: FlutterFlowTheme.of(context).bodySmall),
              const SizedBox(height: 4),
              Text(value, style: FlutterFlowTheme.of(context).titleLarge.copyWith(color: color)),
              Text(unit, style: FlutterFlowTheme.of(context).bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: onTap != null ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: onTap != null ? color : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                color: onTap != null ? null : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 