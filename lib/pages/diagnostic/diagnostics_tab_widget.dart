import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:o_b_d2_scanner_frontend/backend/api_requests/diagnostic_service.dart';
import 'package:o_b_d2_scanner_frontend/pages/chat/chat_screen_widget.dart';
import 'package:provider/provider.dart';
import 'package:o_b_d2_scanner_frontend/backend/providers/chat_provider.dart';
import 'package:o_b_d2_scanner_frontend/backend/providers/vehicle_provider.dart';
import 'package:o_b_d2_scanner_frontend/pages/vehicles/add_vehicle_widget.dart';
import 'package:o_b_d2_scanner_frontend/backend/schema/vehicle_record.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'scan_results_screen.dart';

// Recent chat model
class RecentChat {
  final String id;
  final String question;
  final String timestamp;
  final String vehicleVin;

  RecentChat({
    required this.id,
    required this.question,
    required this.timestamp,
    required this.vehicleVin,
  });
}

// Recent scan model
class RecentScan {
  final String id;
  final String type;
  final String timestamp;
  final String result;
  final String vehicleVin;

  RecentScan({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.result,
    required this.vehicleVin,
  });
}

class DiagnosticsTabWidget extends StatefulWidget {
  const DiagnosticsTabWidget({super.key});

  @override
  State<DiagnosticsTabWidget> createState() => _DiagnosticsTabWidgetState();
}

class _DiagnosticsTabWidgetState extends State<DiagnosticsTabWidget> {
  String? _selectedVehicleVin;
  BluetoothDevice? _selectedOBD2Device;
  late DiagnosticService _diagnosticService;
  final TextEditingController _aiQuestionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _diagnosticService = DiagnosticService('your-gpt-api-key-here');
    // Initialize vehicle provider and set initial vehicle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVehicleProvider();
    });
  }

  @override
  void dispose() {
    _aiQuestionController.dispose();
    _diagnosticService.dispose();
    super.dispose();
  }

  Future<void> _initializeVehicleProvider() async {
    final vehicleProvider = context.read<VehicleProvider>();
    await vehicleProvider.initialize();
    
    // Set initial selected vehicle
    if (vehicleProvider.vehicles.isNotEmpty) {
      setState(() {
        _selectedVehicleVin = vehicleProvider.vehicles.first.vin;
      });
      _updateChatVehicleContext(_selectedVehicleVin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProvider, child) {
        final vehicles = vehicleProvider.vehicles;
        final selectedVehicle = vehicles.isNotEmpty 
            ? vehicles.firstWhere(
                (v) => v.vin == _selectedVehicleVin,
                orElse: () => vehicles.first,
              )
            : null;

        return Scaffold(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            elevation: 0,
            title: Text(
              'Diagnostics',
              style: FlutterFlowTheme.of(context).titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  _buildQuickActionsCard(),
                  const SizedBox(height: 20),
                  _buildAIChatSection(),
                  const SizedBox(height: 20),
                  _buildMyCarSection(selectedVehicle, vehicles),
                  const SizedBox(height: 20),
                  _buildRecentScansCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVehicleDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 12,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: FlutterFlowTheme.of(context).primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: FlutterFlowTheme.of(context).titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  Icons.stacked_line_chart,
                  'Quick Scan',
                  _performDefaultScan,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  Icons.assessment,
                  'Full Scan',
                  _performFullScan,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  Icons.bluetooth,
                  'Connect',
                  _connectOBD2,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  Icons.history,
                  'Reports',
                  _viewReports,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 10,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIChatSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FlutterFlowTheme.of(context).primary,
            FlutterFlowTheme.of(context).secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.robot,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Diagnostics Assistant',
                        style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Ask me anything about your vehicle diagnostics',
                        style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _aiQuestionController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'e.g., "Start a diagnostic scan"',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send,
                        color: FlutterFlowTheme.of(context).primary, size: 16),
                    onPressed: _sendAIQuestion,
                  ),
                ),
                maxLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendAIQuestion(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScansCard() {
    final recentScans = _getRecentScans();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: FlutterFlowTheme.of(context).primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Recent Scans',
                style: FlutterFlowTheme.of(context).titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: _viewAllScans,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  'View All',
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    color: FlutterFlowTheme.of(context).primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (recentScans.isEmpty)
            Center(
              child: Text(
                'No recent scans',
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            )
          else
            ...recentScans.take(3).map((scan) => _buildRecentScanItem(scan)).toList(),
        ],
      ),
    );
  }

  Widget _buildRecentScanItem(RecentScan scan) {
    return InkWell(
      onTap: () => _openScanResults(scan),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: FlutterFlowTheme.of(context).alternate, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.assessment_outlined, color: FlutterFlowTheme.of(context).primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.type,
                    style: FlutterFlowTheme.of(context).bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    scan.timestamp,
                    style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getResultColor(scan.result).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                scan.result,
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: _getResultColor(scan.result),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'View',
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: FlutterFlowTheme.of(context).primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateChatVehicleContext(String? vehicleVin) {
    final chatProvider = context.read<ChatProvider>();
    if (vehicleVin != null) {
      final vehicleProvider = context.read<VehicleProvider>();
      final vehicle = vehicleProvider.getVehicleByVin(vehicleVin);
      if (vehicle != null) {
        final vehicleInfo = '${vehicle.year} ${vehicle.make} ${vehicle.model} (VIN: ${vehicle.vin})';
        chatProvider.setVehicleContext(
          vehicleVin,
          null,
          'Chat about ${vehicle.nickname ?? vehicleInfo}',
        );
        chatProvider.addVehicleSystemMessage(vehicleInfo);
      }
    }
  }

  void _sendAIQuestion() {
    final question = _aiQuestionController.text.trim();
    if (question.isNotEmpty) {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.sendMessage(question);
      _aiQuestionController.clear();
      
      // Navigate to chat screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreenWidget(
            vehicleVin: _selectedVehicleVin,
            initialTitle: 'Diagnostics Chat',
          ),
        ),
      );
    }
  }

  void _performDefaultScan() async {
    if (_selectedVehicleVin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a vehicle first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show scanning dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildScanningDialog(),
    );

    try {
      // TODO: BACKEND INTEGRATION - Replace with real OBD2 scan
      // This should connect to actual OBD2 device and perform real diagnostic scan
      // await _diagnosticService.performQuickScan(_selectedVehicleVin!);
      
      // Simulate scan progress
      await Future.delayed(const Duration(seconds: 3));

      // Close scanning dialog
      Navigator.pop(context);

      // Navigate to scan results
      _showScanResults();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quick scan completed successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Close scanning dialog
      Navigator.pop(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scan failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildScanningDialog() {
    return AlertDialog(
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Scanning Vehicle...',
            style: FlutterFlowTheme.of(context).titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we analyze your vehicle systems',
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showScanResults() {
    final vehicleProvider = context.read<VehicleProvider>();
    final selectedVehicle = vehicleProvider.getVehicleByVin(_selectedVehicleVin!);
    
    if (selectedVehicle == null) return;

    final scanResult = ScanResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'Quick Diagnostic Scan',
      timestamp: 'Just now',
      vehicleVin: _selectedVehicleVin!,
      vehicleName: selectedVehicle.nickname ?? '${selectedVehicle.year} ${selectedVehicle.make} ${selectedVehicle.model}',
      results: {
        'Engine Control Module': 'OK',
        'Transmission Control': 'OK',
        'Anti-lock Brake System': 'OK',
        'Airbag System': 'OK',
        'Climate Control': 'OK',
        'Fuel System': 'OK',
        'Oxygen Sensors': 'OK',
        'Catalytic Converter': 'OK',
        'Evaporative System': 'OK',
        'Secondary Air System': 'OK',
      },
      overallHealth: '85% Health',
      issues: [
        ScanIssue(
          code: 'P0171',
          description: 'System too lean (Bank 1)',
          severity: 'Medium',
          component: 'Fuel System',
          status: 'Active',
        ),
        ScanIssue(
          code: 'P0420',
          description: 'Catalyst system efficiency below threshold',
          severity: 'Low',
          component: 'Emission System',
          status: 'Pending',
        ),
      ],
      recommendations: [
        ScanRecommendation(
          title: 'Check Air Filter',
          description: 'Replace air filter to improve fuel efficiency',
          priority: 'Medium',
          estimatedCost: '\$15-25',
        ),
        ScanRecommendation(
          title: 'Inspect Oxygen Sensors',
          description: 'Have oxygen sensors checked for proper operation',
          priority: 'Low',
          estimatedCost: '\$50-150',
        ),
      ],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanResultsScreen(scanResult: scanResult),
      ),
    );
  }

  void _performFullScan() async {
    if (_selectedVehicleVin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a vehicle first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show scanning dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildFullScanningDialog(),
    );

    try {
      // TODO: BACKEND INTEGRATION - Replace with real OBD2 full scan
      // This should connect to actual OBD2 device and perform comprehensive diagnostic scan
      // await _diagnosticService.performFullScan(_selectedVehicleVin!);
      
      // Simulate full scan progress (longer than quick scan)
      await Future.delayed(const Duration(seconds: 5));

      // Close scanning dialog
      Navigator.pop(context);

      // Navigate to full scan results
      _showFullScanResults();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Full diagnostic scan completed successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Close scanning dialog
      Navigator.pop(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Full scan failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildFullScanningDialog() {
    return AlertDialog(
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Performing Full Diagnostic Scan...',
            style: FlutterFlowTheme.of(context).titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This comprehensive scan will analyze all vehicle systems',
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFullScanResults() {
    final vehicleProvider = context.read<VehicleProvider>();
    final selectedVehicle = vehicleProvider.getVehicleByVin(_selectedVehicleVin!);
    
    if (selectedVehicle == null) return;

    final scanResult = ScanResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'Full Diagnostic Scan',
      timestamp: 'Just now',
      vehicleVin: _selectedVehicleVin!,
      vehicleName: selectedVehicle.nickname ?? '${selectedVehicle.year} ${selectedVehicle.make} ${selectedVehicle.model}',
      results: {
        'Engine Control Module': 'OK',
        'Transmission Control': 'OK',
        'Anti-lock Brake System': 'OK',
        'Airbag System': 'OK',
        'Climate Control': 'OK',
        'Fuel System': 'Warning',
        'Oxygen Sensors': 'OK',
        'Catalytic Converter': 'OK',
        'Evaporative System': 'OK',
        'Secondary Air System': 'OK',
        'Engine Cooling System': 'OK',
        'Electrical System': 'OK',
        'Body Control Module': 'OK',
        'Instrument Cluster': 'OK',
        'Immobilizer System': 'OK',
      },
      overallHealth: '82% Health',
      issues: [
        ScanIssue(
          code: 'P0171',
          description: 'System too lean (Bank 1)',
          severity: 'Medium',
          component: 'Fuel System',
          status: 'Active',
        ),
        ScanIssue(
          code: 'P0420',
          description: 'Catalyst system efficiency below threshold',
          severity: 'Low',
          component: 'Emission System',
          status: 'Pending',
        ),
        ScanIssue(
          code: 'P0300',
          description: 'Random/Multiple cylinder misfire detected',
          severity: 'High',
          component: 'Engine',
          status: 'Active',
        ),
      ],
      recommendations: [
        ScanRecommendation(
          title: 'Check Air Filter',
          description: 'Replace air filter to improve fuel efficiency',
          priority: 'Medium',
          estimatedCost: '\$15-25',
        ),
        ScanRecommendation(
          title: 'Inspect Oxygen Sensors',
          description: 'Have oxygen sensors checked for proper operation',
          priority: 'Low',
          estimatedCost: '\$50-150',
        ),
        ScanRecommendation(
          title: 'Check Spark Plugs',
          description: 'Inspect and replace spark plugs if necessary',
          priority: 'High',
          estimatedCost: '\$30-80',
        ),
      ],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanResultsScreen(scanResult: scanResult),
      ),
    );
  }

  void _connectOBD2() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.bluetooth, color: FlutterFlowTheme.of(context).primary),
            const SizedBox(width: 8),
            Text(
              'OBD2 Connection',
              style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TODO: Implement OBD2 Device Connection',
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This feature will allow you to:\n'
              '• Scan for available OBD2 devices\n'
              '• Connect to ELM327 adapters\n'
              '• Pair with Bluetooth devices\n'
              '• Configure connection settings',
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to OBD2 devices screen when implemented
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('OBD2 device management coming soon!')),
              );
            },
            child: const Text('Manage Devices'),
          ),
        ],
      ),
    );
  }

  void _viewReports() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.assessment, color: FlutterFlowTheme.of(context).primary),
            const SizedBox(width: 8),
            Text(
              'Diagnostic Reports',
              style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TODO: Implement Reports & History Screen',
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This feature will show:\n'
              '• Complete scan history\n'
              '• Trend analysis\n'
              '• Health score progression\n'
              '• Issue tracking over time\n'
              '• Export capabilities',
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to reports screen when implemented
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reports & history coming soon!')),
              );
            },
            child: const Text('View History'),
          ),
        ],
      ),
    );
  }

  void _viewAllScans() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.history, color: FlutterFlowTheme.of(context).primary),
            const SizedBox(width: 8),
            Text(
              'All Scan History',
              style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TODO: Implement Complete Scan History',
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This feature will show:\n'
              '• All past diagnostic scans\n'
              '• Filter by date, vehicle, scan type\n'
              '• Search and sort capabilities\n'
              '• Detailed scan comparisons\n'
              '• Export scan data',
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to complete scan history when implemented
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Complete scan history coming soon!')),
              );
            },
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }

  void _openScanResults(RecentScan scan) {
    final vehicleProvider = context.read<VehicleProvider>();
    final selectedVehicle = vehicleProvider.getVehicleByVin(scan.vehicleVin);
    
    if (selectedVehicle == null) return;

    // Create scan result based on the recent scan
    final scanResult = ScanResult(
      id: scan.id,
      type: scan.type,
      timestamp: scan.timestamp,
      vehicleVin: scan.vehicleVin,
      vehicleName: selectedVehicle.nickname ?? '${selectedVehicle.year} ${selectedVehicle.make} ${selectedVehicle.model}',
      results: {
        'Engine Control Module': 'OK',
        'Transmission Control': 'OK',
        'Anti-lock Brake System': 'OK',
        'Airbag System': 'OK',
        'Climate Control': 'OK',
        'Fuel System': scan.type == 'Quick Scan' ? 'Warning' : 'OK',
        'Oxygen Sensors': 'OK',
        'Catalytic Converter': scan.type == 'Emissions Check' ? 'OK' : 'OK',
        'Evaporative System': 'OK',
        'Secondary Air System': 'OK',
      },
      overallHealth: scan.result,
      issues: scan.type == 'Quick Scan' ? [
        ScanIssue(
          code: 'P0171',
          description: 'System too lean (Bank 1)',
          severity: 'Medium',
          component: 'Fuel System',
          status: 'Active',
        ),
      ] : [],
      recommendations: scan.type == 'Quick Scan' ? [
        ScanRecommendation(
          title: 'Check Air Filter',
          description: 'Replace air filter to improve fuel efficiency',
          priority: 'Medium',
          estimatedCost: '\$15-25',
        ),
      ] : [],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanResultsScreen(scanResult: scanResult),
      ),
    );
  }

  void _addVehicle() {
    // Navigate to the existing AddVehicleWidget
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddVehicleWidget(),
      ),
    ).then((_) {
      // Refresh the vehicle list when returning from add vehicle screen
      final vehicleProvider = context.read<VehicleProvider>();
      vehicleProvider.initialize();
    });
  }

  Color _getResultColor(String result) {
    if (result.contains('%')) {
      final score = int.tryParse(result.replaceAll('%', '')) ?? 0;
      if (score >= 80) return Colors.green;
      if (score >= 60) return Colors.orange;
      return Colors.red;
    }
    if (result.toLowerCase().contains('ready')) return Colors.green;
    if (result.toLowerCase().contains('not ready')) return Colors.red;
    return Colors.grey;
  }

  List<RecentScan> _getRecentScans() {
    // TODO: BACKEND INTEGRATION - Replace with real scan history from Firebase/database
    // This should fetch actual scan results from the backend based on user's vehicles
    return [
      RecentScan(
        id: '1',
        type: 'Quick Scan',
        timestamp: '2 hours ago',
        result: '85% Health',
        vehicleVin: '1HGBH41JXMN109186',
      ),
      RecentScan(
        id: '2',
        type: 'Full Diagnostic',
        timestamp: '1 day ago',
        result: '82% Health',
        vehicleVin: '1HGBH41JXMN109186',
      ),
      RecentScan(
        id: '3',
        type: 'Emissions Check',
        timestamp: '3 days ago',
        result: 'Ready',
        vehicleVin: '5NPE34AF4FH012345',
      ),
    ];
  }

  Widget _buildMyCarSection(VehicleRecord? selectedVehicle, List<VehicleRecord> vehicles) {
    final isConnected = _selectedOBD2Device != null;
    
    // Show empty state if no vehicles
    if (vehicles.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: FlutterFlowTheme.of(context).alternate,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car, color: FlutterFlowTheme.of(context).primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'My Car',
                  style: FlutterFlowTheme.of(context).titleSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _addVehicle,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'Add Vehicle',
                    style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                      color: FlutterFlowTheme.of(context).primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 48,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Vehicles Added',
                    style: FlutterFlowTheme.of(context).titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first vehicle to start diagnostics',
                    style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addVehicle,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Vehicle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlutterFlowTheme.of(context).primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car, color: FlutterFlowTheme.of(context).primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'My Car',
                style: FlutterFlowTheme.of(context).titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: _addVehicle,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  'Add Vehicle',
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    color: FlutterFlowTheme.of(context).primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Vehicle selection and connection status
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.directions_car, color: FlutterFlowTheme.of(context).primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedVehicleVin,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18),
                          underline: Container(),
                          style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          items: vehicles.map((v) => DropdownMenuItem(
                            value: v.vin,
                            child: Text(
                              v.nickname ?? '${v.year} ${v.make} ${v.model}',
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )).toList(),
                          onChanged: (vin) {
                            setState(() {
                              _selectedVehicleVin = vin;
                            });
                            _updateChatVehicleContext(vin);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isConnected ? Colors.green : Colors.grey,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                      color: isConnected ? Colors.green : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isConnected ? 'Connected' : 'OBD2',
                      style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                        color: isConnected ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Vehicle details grid
          Row(
            children: [
              Expanded(
                child: _buildVehicleDetailItem(
                  icon: Icons.confirmation_number,
                  label: 'VIN',
                  value: selectedVehicle != null ? (selectedVehicle.vin.length > 8 ? selectedVehicle.vin.substring(0, 8) + '...' : selectedVehicle.vin) : 'N/A',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVehicleDetailItem(
                  icon: Icons.color_lens,
                  label: 'Color',
                  value: selectedVehicle?.color ?? 'N/A',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVehicleDetailItem(
                  icon: Icons.speed,
                  label: 'Mileage',
                  value: selectedVehicle?.mileage != null ? '${selectedVehicle!.mileage} km' : 'N/A',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Additional vehicle info
          Row(
            children: [
              Expanded(
                child: _buildVehicleDetailItem(
                  icon: Icons.confirmation_number,
                  label: 'License',
                  value: selectedVehicle?.licensePlate ?? 'N/A',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVehicleDetailItem(
                  icon: Icons.calendar_today,
                  label: 'Year',
                  value: selectedVehicle?.year ?? 'N/A',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVehicleDetailItem(
                  icon: Icons.engineering,
                  label: 'Make/Model',
                  value: selectedVehicle != null ? '${selectedVehicle.make} ${selectedVehicle.model}' : 'N/A',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 