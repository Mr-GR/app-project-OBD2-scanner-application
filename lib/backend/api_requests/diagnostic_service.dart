import 'dart:async';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'obd2_scanner_service.dart';
import 'nhtsa_api_service.dart';
import 'gpt_api_service.dart';
import '../models/diagnostic_models.dart';

class DiagnosticService {
  final OBD2ScannerService _obd2Service = OBD2ScannerService();
  final NHTSAApiService _nhtsaService = NHTSAApiService();
  final GPTApiService _gptService;
  
  DiagnosticService(String gptApiKey) : _gptService = GPTApiService(gptApiKey);

  // Stream controllers for real-time updates
  final StreamController<String> _statusController = StreamController<String>.broadcast();
  final StreamController<double> _progressController = StreamController<double>.broadcast();
  final StreamController<DiagnosticReport> _reportController = StreamController<DiagnosticReport>.broadcast();

  // Streams for UI updates
  Stream<String> get statusStream => _statusController.stream;
  Stream<double> get progressStream => _progressController.stream;
  Stream<DiagnosticReport> get reportStream => _reportController.stream;

  // Perform complete diagnostic scan with AI analysis
  Future<DiagnosticReport> performCompleteDiagnostic({
    required String vehicleVin,
    required BluetoothDevice? obd2Device,
    bool includeAI = true,
  }) async {
    try {
      _statusController.add('Initializing diagnostic scan...');
      _progressController.add(0.0);

      DiagnosticReport report;
      NHTSAVehicleData? vehicleData;

      // Step 1: Get vehicle data from NHTSA (10%)
      _statusController.add('Fetching vehicle information...');
      _progressController.add(0.1);
      
      try {
        vehicleData = await _nhtsaService.getVehicleDataByVin(vehicleVin);
        if (vehicleData != null) {
          _statusController.add('Vehicle data retrieved: ${vehicleData.year} ${vehicleData.make} ${vehicleData.model}');
        } else {
          _statusController.add('Vehicle data not available from NHTSA');
        }
      } catch (e) {
        print('Error fetching vehicle data: $e');
        _statusController.add('Warning: Could not fetch vehicle data');
      }

      // Step 2: Perform OBD2 scan (40%)
      if (obd2Device != null) {
        _statusController.add('Connecting to OBD2 device...');
        _progressController.add(0.2);
        
        final connected = await _obd2Service.connectToDevice(obd2Device);
        if (!connected) {
          throw Exception('Failed to connect to OBD2 device');
        }

        _statusController.add('Connected to OBD2 device. Starting scan...');
        _progressController.add(0.3);
        
        report = await _obd2Service.performDiagnosticScan(vehicleVin);
        
        _statusController.add('OBD2 scan completed. Found ${report.troubleCodes.length} trouble codes.');
        _progressController.add(0.5);
        
        await _obd2Service.disconnect();
      } else {
        // Create mock report for testing
        _statusController.add('No OBD2 device provided. Creating mock scan data...');
        _progressController.add(0.3);
        
        report = _createMockDiagnosticReport(vehicleVin);
        _progressController.add(0.5);
      }

      // Step 3: Generate AI analysis (50%)
      if (includeAI) {
        _statusController.add('Generating AI diagnostic analysis...');
        _progressController.add(0.6);
        
        final aiAnalysis = await _gptService.generateDiagnosticAnalysis(
          report: report,
          vehicleData: vehicleData,
        );

        // Update report with AI analysis
        report = DiagnosticReport(
          id: report.id,
          vehicleVin: report.vehicleVin,
          scanDate: report.scanDate,
          troubleCodes: report.troubleCodes,
          liveData: report.liveData,
          emissionsStatus: report.emissionsStatus,
          vehicleData: vehicleData,
          gptAnalysis: aiAnalysis['analysis'] ?? '',
          severity: aiAnalysis['severity'] ?? report.severity,
          recommendations: _extractRecommendations(aiAnalysis),
          rawScanData: report.rawScanData,
          healthScore: _extractHealthScore(aiAnalysis),
        );

        _statusController.add('AI analysis completed');
        _progressController.add(0.9);
      } else {
        // Update report with vehicle data only
        report = DiagnosticReport(
          id: report.id,
          vehicleVin: report.vehicleVin,
          scanDate: report.scanDate,
          troubleCodes: report.troubleCodes,
          liveData: report.liveData,
          emissionsStatus: report.emissionsStatus,
          vehicleData: vehicleData,
          gptAnalysis: '',
          severity: report.severity,
          recommendations: [],
          rawScanData: report.rawScanData,
        );
      }

      _statusController.add('Diagnostic scan completed successfully!');
      _progressController.add(1.0);

      // Emit final report
      _reportController.add(report);
      
      return report;

    } catch (e) {
      _statusController.add('Error during diagnostic scan: $e');
      _progressController.add(0.0);
      rethrow;
    }
  }

  // Extract recommendations from AI analysis
  List<String> _extractRecommendations(Map<String, dynamic> aiAnalysis) {
    final recommendations = <String>[];
    
    // Extract from recommendations section
    final recText = aiAnalysis['recommendations'] ?? '';
    if (recText.isNotEmpty) {
      final lines = recText.split('\n');
      for (final line in lines) {
        if (line.trim().isNotEmpty && 
            (line.trim().startsWith('-') || 
             line.trim().startsWith('•') || 
             line.trim().startsWith('1.') ||
             line.trim().startsWith('2.') ||
             line.trim().startsWith('3.'))) {
          recommendations.add(line.trim().replaceAll(RegExp(r'^[-•\d\.\s]+'), ''));
        }
      }
    }
    
    // Add priority issues
    final priorityIssues = aiAnalysis['priorityIssues'] as List<dynamic>? ?? [];
    recommendations.addAll(priorityIssues.cast<String>());
    
    return recommendations;
  }

  // Extract health score from AI analysis
  int? _extractHealthScore(Map<String, dynamic> aiAnalysis) {
    final healthScoreStr = aiAnalysis['healthScore'] ?? '';
    if (healthScoreStr.isNotEmpty) {
      return int.tryParse(healthScoreStr);
    }
    return null;
  }

  // Create mock diagnostic report for testing
  DiagnosticReport _createMockDiagnosticReport(String vehicleVin) {
    final troubleCodes = [
      DiagnosticTroubleCode(
        code: 'P0300',
        description: 'Random/Multiple Cylinder Misfire Detected',
        severity: 'P',
        category: 'Powertrain',
        isPending: false,
        isConfirmed: true,
      ),
      DiagnosticTroubleCode(
        code: 'P0171',
        description: 'System Too Lean (Bank 1)',
        severity: 'P',
        category: 'Powertrain',
        isPending: true,
        isConfirmed: false,
      ),
    ];

    final liveData = [
      LiveDataPoint(
        pid: '010C',
        name: 'Engine RPM',
        value: 750.0,
        unit: 'rpm',
        description: 'Engine revolutions per minute',
      ),
      LiveDataPoint(
        pid: '0105',
        name: 'Engine Coolant Temperature',
        value: 90.0,
        unit: '°C',
        description: 'Engine coolant temperature in Celsius',
      ),
      LiveDataPoint(
        pid: '010D',
        name: 'Vehicle Speed',
        value: 0.0,
        unit: 'km/h',
        description: 'Vehicle speed in kilometers per hour',
      ),
      LiveDataPoint(
        pid: '0111',
        name: 'Throttle Position',
        value: 12.5,
        unit: '%',
        description: 'Throttle position as a percentage',
      ),
    ];

    final emissionsStatus = [
      EmissionsMonitorStatus(
        monitor: 'Misfire Monitor',
        status: 'Ready',
        description: 'Emissions monitor status for misfire',
      ),
      EmissionsMonitorStatus(
        monitor: 'Fuel System Monitor',
        status: 'Ready',
        description: 'Emissions monitor status for fuel system',
      ),
      EmissionsMonitorStatus(
        monitor: 'Catalyst Monitor',
        status: 'Not Ready',
        description: 'Emissions monitor status for catalyst',
      ),
      EmissionsMonitorStatus(
        monitor: 'Evaporative System Monitor',
        status: 'Ready',
        description: 'Emissions monitor status for evaporative system',
      ),
    ];

    return DiagnosticReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      vehicleVin: vehicleVin,
      scanDate: DateTime.now(),
      troubleCodes: troubleCodes,
      liveData: liveData,
      emissionsStatus: emissionsStatus,
      vehicleData: null,
      gptAnalysis: '',
      severity: 'Warning',
      recommendations: [],
      rawScanData: {
        'protocol': 'Mock Protocol',
        'vehicleInfo': {},
        'supportedPids': ['0100', '0105', '010C', '010D', '0111'],
      },
    );
  }

  // Get available OBD2 devices
  Future<List<BluetoothDevice>> getAvailableDevices() async {
    try {
      final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      return devices.where((device) => 
          device.name?.toLowerCase().contains('obd') == true ||
          device.name?.toLowerCase().contains('elm327') == true ||
          device.name?.toLowerCase().contains('bluetooth') == true).toList();
    } catch (e) {
      print('Error getting available devices: $e');
      return [];
    }
  }

  // Validate VIN
  bool isValidVin(String vin) {
    return _nhtsaService.isValidVin(vin);
  }

  // Get vehicle data by VIN
  Future<NHTSAVehicleData?> getVehicleData(String vin) async {
    return await _nhtsaService.getVehicleDataByVin(vin);
  }

  // Get vehicle recalls
  Future<List<Map<String, dynamic>>> getVehicleRecalls(String vin) async {
    return await _nhtsaService.getVehicleRecalls(vin);
  }

  // Get vehicle complaints
  Future<List<Map<String, dynamic>>> getVehicleComplaints(String vin) async {
    return await _nhtsaService.getVehicleComplaints(vin);
  }

  // Generate maintenance recommendations
  Future<List<String>> generateMaintenanceRecommendations({
    required NHTSAVehicleData vehicleData,
    required List<LiveDataPoint> liveData,
  }) async {
    return await _gptService.generateMaintenanceRecommendations(
      vehicleData: vehicleData,
      liveData: liveData,
    );
  }

  // Generate quick analysis
  Future<String> generateQuickAnalysis(DiagnosticReport report) async {
    return await _gptService.generateQuickAnalysis(report);
  }

  // AI Chat method for diagnostics questions
  Future<String> askDiagnosticsAI({
    required String question,
    String? vehicleVin,
    DiagnosticReport? lastReport,
  }) async {
    try {
      // Get vehicle data if VIN provided
      NHTSAVehicleData? vehicleData;
      if (vehicleVin != null) {
        vehicleData = await _nhtsaService.getVehicleDataByVin(vehicleVin);
      }

      // Create context for the AI
      final context = {
        'question': question,
        'vehicleData': vehicleData?.toMap(),
        'lastReport': lastReport?.toMap(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Use GPT service to generate response
      final response = await _gptService.generateDiagnosticResponse(context);
      
      return response;
    } catch (e) {
      print('Error in AI diagnostics chat: $e');
      return 'I apologize, but I encountered an error while processing your question. Please try again or check your connection.';
    }
  }

  // Clear trouble codes
  Future<bool> clearTroubleCodes(BluetoothDevice device) async {
    try {
      final connected = await _obd2Service.connectToDevice(device);
      if (!connected) return false;
      
      final success = await _obd2Service.clearTroubleCodes();
      await _obd2Service.disconnect();
      
      return success;
    } catch (e) {
      print('Error clearing trouble codes: $e');
      return false;
    }
  }

  // Get live data stream
  Future<Stream<LiveDataPoint>?> getLiveDataStream({
    required BluetoothDevice device,
    required List<String> pids,
    Duration interval = const Duration(seconds: 1),
  }) async {
    try {
      final connected = await _obd2Service.connectToDevice(device);
      if (!connected) return null;

      final controller = StreamController<LiveDataPoint>();
      
      Timer.periodic(interval, (timer) async {
        try {
          for (final pid in pids) {
            final dataPoint = await _obd2Service.getLiveData(pid);
            if (dataPoint != null) {
              controller.add(dataPoint);
            }
          }
        } catch (e) {
          print('Error getting live data: $e');
          timer.cancel();
          controller.close();
          await _obd2Service.disconnect();
        }
      });

      return controller.stream;
    } catch (e) {
      print('Error setting up live data stream: $e');
      return null;
    }
  }

  // Dispose resources
  void dispose() {
    _statusController.close();
    _progressController.close();
    _reportController.close();
  }
} 