import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:o_b_d2_scanner_frontend/backend/providers/chat_provider.dart';
import 'package:o_b_d2_scanner_frontend/backend/api_requests/diagnostic_service.dart';
import 'package:o_b_d2_scanner_frontend/widgets/connection_status_widget.dart';
import 'package:o_b_d2_scanner_frontend/widgets/enhanced_loading_widget.dart';
import 'package:o_b_d2_scanner_frontend/widgets/enhanced_error_handler.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:math';
import 'dart:async';
import 'home_page_model.dart';
export 'home_page_model.dart';

// NOTE: This is a visual-only version for preview
// All data is hardcoded placeholders - no backend integration

// Simple placeholder class for vehicle data
class VehicleRecord {
  final String vin;
  final String make;
  final String model;
  final String year;
  final String? nickname;
  final String? color;
  final String? licensePlate;
  final String? mileage;

  VehicleRecord({
    required this.vin,
    required this.make,
    required this.model,
    required this.year,
    this.nickname,
    this.color,
    this.licensePlate,
    this.mileage,
  });
}

// Simple placeholder class for recent chat data
class RecentChat {
  final String id;
  final String question;
  final String timestamp;
  final String? vehicleVin;

  RecentChat({
    required this.id,
    required this.question,
    required this.timestamp,
    this.vehicleVin,
  });
}

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;
  final TextEditingController _aiQuestionController = TextEditingController();
  String? _selectedVehicleVin;
  late DiagnosticService _diagnosticService;
  BluetoothDevice? _selectedOBD2Device;
  double _scanProgress = 0.0;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
    _selectedVehicleVin = _getMockVehicles().first.vin;
    _diagnosticService = DiagnosticService(
        'your-gpt-api-key-here'); // Replace with actual API key
    _initializeOBD2Device();
  }

  @override
  void dispose() {
    _aiQuestionController.dispose();
    _model.dispose();
    _diagnosticService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'Auto Fix',
                  style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const CompactConnectionStatusWidget(),
            ],
          ),
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
              child: Column(
                children: [
                  _buildHealthAndVehicleInfo(),
                  const SizedBox(height: 20),
                  _buildQuickActionsSection(),
                  const SizedBox(height: 20),
                  _buildAIChatSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthAndVehicleInfo() {
    final hasScanData = _hasRecentScanData();
    final healthScore = hasScanData ? _calculateVehicleHealth() : 0;
    final healthColor = _getHealthColor(healthScore);
    final healthStatus = hasScanData ? _getHealthStatus(healthScore) : 'No scan data';
    final emissionsReady = hasScanData ? _checkEmissionsReady() : false;
    final selectedVehicle = _getMockVehicles().firstWhere(
      (vehicle) => vehicle.vin == _selectedVehicleVin,
      orElse: () => _getMockVehicles().first,
    );
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FlutterFlowTheme.of(context).secondaryBackground,
            FlutterFlowTheme.of(context).primaryBackground,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
          // Header with vehicle name and health score
          Row(
            children: [
              // Health Gauge
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 1,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CustomPaint(
                        painter: CompactGaugePainter(
                          value: healthScore / 100,
                          color: healthColor,
                          backgroundColor: FlutterFlowTheme.of(context).alternate,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          healthScore.toString(),
                          style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                                color: healthColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                        ),
                        Text(
                          'HEALTH',
                          style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 6,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Vehicle Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedVehicle.nickname ?? '${selectedVehicle.year} ${selectedVehicle.make}',
                      style: FlutterFlowTheme.of(context).titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                    ),
                    Text(
                      '${selectedVehicle.year} ${selectedVehicle.make} ${selectedVehicle.model}',
                      style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 12,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      healthStatus,
                      style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                            color: healthColor,
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
          
          // Vehicle Details Grid
          Row(
            children: [
              Expanded(
                child: _buildVehicleDetailItem(
                  icon: Icons.confirmation_number,
                  label: 'VIN',
                  value: selectedVehicle.vin.substring(0, 8) + '...',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVehicleDetailItem(
                  icon: Icons.color_lens,
                  label: 'Color',
                  value: selectedVehicle.color ?? 'N/A',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVehicleDetailItem(
                  icon: Icons.directions_car,
                  label: 'License',
                  value: selectedVehicle.licensePlate ?? 'N/A',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Bottom row with mileage and emissions status
          Row(
            children: [
              Expanded(
                child: _buildVehicleDetailItem(
                  icon: Icons.speed,
                  label: 'Mileage',
                  value: selectedVehicle.mileage != null ? '${selectedVehicle.mileage} km' : 'N/A',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).alternate,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        emissionsReady ? Icons.check_circle : Icons.cancel,
                        color: emissionsReady
                            ? FlutterFlowTheme.of(context).success
                            : FlutterFlowTheme.of(context).error,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emissions',
                              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            Text(
                              emissionsReady ? 'Ready' : 'Not Ready',
                              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                                    color: emissionsReady
                                        ? FlutterFlowTheme.of(context).success
                                        : FlutterFlowTheme.of(context).error,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildQuickActionsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
                  FontAwesomeIcons.gear,
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
                      'Quick Actions',
                      style:
                          FlutterFlowTheme.of(context).titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                    ),
                    Text(
                      'Quickly access common vehicle maintenance tasks',
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
           // Quick action buttons
           Row(
             children: [
               Expanded(
                 child: _buildQuickActionButton(
                   icon: Icons.warning_amber,
                   label: 'TSB & Recalls',
                   color: Colors.orange,
                   onTap: () => _checkTSBAndRecalls(),
                 ),
               ),
               const SizedBox(width: 8),
               Expanded(
                 child: _buildQuickActionButton(
                   icon: Icons.location_on,
                   label: 'OBD2 Location',
                   color: Colors.blue,
                   onTap: () => _findOBD2Location(),
                 ),
               ),
             ],
           ),
           const SizedBox(height: 8),
           Row(
             children: [
               Expanded(
                 child: _buildQuickActionButton(
                   icon: Icons.safety_check,
                   label: 'Safe to Drive?',
                   color: Colors.green,
                   onTap: () => _checkSafeToDrive(),
                 ),
               ),
               const SizedBox(width: 8),
               Expanded(
                 child: _buildQuickActionButton(
                   icon: Icons.history,
                   label: 'Service History',
                   color: Colors.purple,
                   onTap: () => _viewServiceHistory(),
                 ),
               ),
             ],
           ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TODO: BACKEND INTEGRATION - Replace with real API calls
  void _checkTSBAndRecalls() async {
    final selectedVehicle = _getMockVehicles().firstWhere(
      (vehicle) => vehicle.vin == _selectedVehicleVin,
      orElse: () => _getMockVehicles().first,
    );

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Checking TSB & Recalls...',
              style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Searching for ${selectedVehicle.year} ${selectedVehicle.make} ${selectedVehicle.model}',
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      // TODO: BACKEND INTEGRATION - Replace with real NHTSA API call
      // await _diagnosticService.checkTSBAndRecalls(selectedVehicle.year, selectedVehicle.make, selectedVehicle.model);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Close loading dialog
      Navigator.pop(context);

      // Show results
      _showTSBAndRecallsResults(selectedVehicle);
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to check TSB & Recalls: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showTSBAndRecallsResults(VehicleRecord vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              'TSB & Recalls',
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
              '${vehicle.year} ${vehicle.make} ${vehicle.model}',
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // TODO: BACKEND INTEGRATION - Replace with real data from NHTSA API
            _buildTSBItem('TSB 21-1234', 'Engine Management System Update', 'Medium'),
            const SizedBox(height: 8),
            _buildTSBItem('TSB 21-5678', 'Transmission Control Module', 'Low'),
            const SizedBox(height: 16),
            _buildRecallItem('Recall 22-001', 'Airbag Sensor Replacement', 'High'),
            const SizedBox(height: 8),
            _buildRecallItem('Recall 22-002', 'Fuel Pump Assembly', 'Medium'),
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
              // TODO: Navigate to detailed TSB/Recall screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Detailed view coming soon!')),
              );
            },
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildTSBItem(String id, String description, String severity) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                id,
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  severity,
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: FlutterFlowTheme.of(context).bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildRecallItem(String id, String description, String severity) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                id,
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  severity,
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: FlutterFlowTheme.of(context).bodySmall,
          ),
        ],
      ),
    );
  }

  // TODO: BACKEND INTEGRATION - Replace with real API calls
  void _findOBD2Location() async {
    final selectedVehicle = _getMockVehicles().firstWhere(
      (vehicle) => vehicle.vin == _selectedVehicleVin,
      orElse: () => _getMockVehicles().first,
    );

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Finding OBD2 Location...',
              style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Searching for ${selectedVehicle.year} ${selectedVehicle.make} ${selectedVehicle.model}',
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      // TODO: BACKEND INTEGRATION - Replace with real API call
      // await _diagnosticService.findOBD2Location(selectedVehicle.year, selectedVehicle.make, selectedVehicle.model);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Close loading dialog
      Navigator.pop(context);

      // Show results
      _showOBD2LocationResults(selectedVehicle);
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to find OBD2 location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showOBD2LocationResults(VehicleRecord vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.location_on, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              'OBD2 Port Location',
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
              '${vehicle.year} ${vehicle.make} ${vehicle.model}',
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // TODO: BACKEND INTEGRATION - Replace with real data from API
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Primary Location',
                        style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Under the dashboard, driver\'s side, near the steering column',
                    style: FlutterFlowTheme.of(context).bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Alternative Location',
                        style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Center console, near the gear shift',
                    style: FlutterFlowTheme.of(context).bodySmall,
                  ),
                ],
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
              // TODO: Navigate to visual guide or video
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Visual guide coming soon!')),
              );
            },
            child: const Text('View Guide'),
          ),
        ],
      ),
    );
  }

  // TODO: BACKEND INTEGRATION - Replace with real OBD2 scan and GPT analysis
  void _checkSafeToDrive() async {
    final selectedVehicle = _getMockVehicles().firstWhere(
      (vehicle) => vehicle.vin == _selectedVehicleVin,
      orElse: () => _getMockVehicles().first,
    );

    // Check if OBD2 is connected
    if (_selectedOBD2Device == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.bluetooth_disabled, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'OBD2 Connection Required',
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
                'To check if your vehicle is safe to drive, please connect your OBD2 device first.',
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What this check includes:',
                      style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Engine diagnostic trouble codes\n'
                      '• Critical system status\n'
                      '• Safety-related warnings\n'
                      '• AI-powered safety assessment',
                      style: FlutterFlowTheme.of(context).bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Navigate to OBD2 connection screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('OBD2 connection coming soon!')),
                );
              },
              child: const Text('Connect OBD2'),
            ),
          ],
        ),
      );
      return;
    }

    // Show scanning dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Safety Check in Progress...',
              style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyzing ${selectedVehicle.year} ${selectedVehicle.make} ${selectedVehicle.model}',
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      // TODO: BACKEND INTEGRATION - Replace with real OBD2 scan and GPT analysis
      // final scanData = await _diagnosticService.performSafetyScan(_selectedVehicleVin!);
      // final safetyAssessment = await _diagnosticService.analyzeSafetyWithGPT(scanData);
      
      // Simulate scan and analysis
      await Future.delayed(const Duration(seconds: 3));

      // Close scanning dialog
      Navigator.pop(context);

      // Show results
      _showSafetyCheckResults(selectedVehicle);
    } catch (e) {
      // Close scanning dialog
      Navigator.pop(context);
      
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Safety check failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSafetyCheckResults(VehicleRecord vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.safety_check, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              'Safety Assessment',
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
              '${vehicle.year} ${vehicle.make} ${vehicle.model}',
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // TODO: BACKEND INTEGRATION - Replace with real GPT analysis results
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Overall Assessment: SAFE TO DRIVE',
                        style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your vehicle appears to be in good condition with no critical safety issues detected.',
                    style: FlutterFlowTheme.of(context).bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Minor Issues Found',
                        style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• P0171: System too lean (Bank 1)\n'
                    '• P0420: Catalyst efficiency below threshold\n'
                    'These are non-critical issues that should be addressed soon.',
                    style: FlutterFlowTheme.of(context).bodySmall,
                  ),
                ],
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
              // TODO: Navigate to detailed diagnostic report
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Detailed report coming soon!')),
              );
            },
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  // TODO: BACKEND INTEGRATION - Replace with real service history
  void _viewServiceHistory() async {
    final selectedVehicle = _getMockVehicles().firstWhere(
      (vehicle) => vehicle.vin == _selectedVehicleVin,
      orElse: () => _getMockVehicles().first,
    );

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Loading Service History...',
              style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fetching records for ${selectedVehicle.year} ${selectedVehicle.make} ${selectedVehicle.model}',
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      // TODO: BACKEND INTEGRATION - Replace with real service history API call
      // await _diagnosticService.getServiceHistory(_selectedVehicleVin!);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Close loading dialog
      Navigator.pop(context);

      // Show results
      _showServiceHistoryResults(selectedVehicle);
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load service history: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showServiceHistoryResults(VehicleRecord vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.history, color: Colors.purple),
            const SizedBox(width: 8),
            Text(
              'Service History',
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
              '${vehicle.year} ${vehicle.make} ${vehicle.model}',
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // TODO: BACKEND INTEGRATION - Replace with real service history data
            _buildServiceHistoryItem('Oil Change', '45,000 km', '2023-12-15', '\$45'),
            const SizedBox(height: 8),
            _buildServiceHistoryItem('Brake Inspection', '42,000 km', '2023-11-20', '\$80'),
            const SizedBox(height: 8),
            _buildServiceHistoryItem('Tire Rotation', '40,000 km', '2023-10-10', '\$30'),
            const SizedBox(height: 8),
            _buildServiceHistoryItem('Air Filter Replacement', '38,000 km', '2023-09-05', '\$25'),
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
              // TODO: Navigate to full service history screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Full service history coming soon!')),
              );
            },
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceHistoryItem(String service, String mileage, String date, String cost) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$mileage • $date',
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Text(
            cost,
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  void _openRecentChat(RecentChat chat) {
    // Send the question directly to the chat provider
    final chatProvider = context.read<ChatProvider>();
    chatProvider.sendMessage(chat.question);
    
    // Navigate to diagnostics tab to show the chat
    // TODO: Navigate to diagnostics tab index instead of pushing new route
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chat opened in Diagnostics tab'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _sendAIQuestion() {
    final question = _aiQuestionController.text.trim();
    if (question.isNotEmpty) {
      // Send the question directly to the chat provider
      final chatProvider = context.read<ChatProvider>();
      chatProvider.sendMessage(question);
      
      // Navigate to diagnostics tab to show the chat
      // TODO: Navigate to diagnostics tab index instead of pushing new route
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat opened in Diagnostics tab'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    _aiQuestionController.clear();
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
                        'AI Assistant',
                        style:
                            FlutterFlowTheme.of(context).titleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                      ),
                      Text(
                        'Ask me anything about your vehicle',
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

            // Recent Chats Section
            _buildRecentChatsSection(),

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
                  hintText: 'e.g., "How do I check my engine oil?"',
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

  Widget _buildRecentChatsSection() {
    final recentChats = _getRecentChats().take(2).toList(); // Limit to 2 chats

    if (recentChats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              Icons.history,
              color: Colors.white.withValues(alpha: 0.7),
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'No recent chats',
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              color: Colors.white.withValues(alpha: 0.8),
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              'Recent Chats',
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...recentChats.map((chat) => _buildRecentChatItem(chat)).toList(),
      ],
    );
  }

  Widget _buildRecentChatItem(RecentChat chat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => _openRecentChat(chat),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.question,
                        style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        chat.timestamp,
                        style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 9,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _hasRecentScanData() {
    // Check if we have recent scan data from the diagnostic service
    // In real app, check if there's actual OBD2 scan data
    return _selectedOBD2Device != null && _scanProgress > 0.0;
  }

  bool _checkEmissionsReady() {
    // Check if emissions monitors are ready based on real scan data
    // This would be populated from actual OBD2 emissions data
    return _selectedOBD2Device != null;
  }

  void _showOBD2Data() {
    // Show detailed OBD2 data modal/screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('OBD2 Monitor Data'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedOBD2Device != null) ...[
                Text(
                  'Connected Device: ${_selectedOBD2Device!.name}',
                  style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Monitor Status:',
                  style: FlutterFlowTheme.of(context).titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _buildMonitorStatusList(),
              ] else ...[
                Text(
                  'No OBD2 device connected',
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect an ELM327 device to view real-time monitor data.',
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (_selectedOBD2Device == null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showDeviceSelection();
              },
              child: const Text('Connect Device'),
            ),
        ],
      ),
    );
  }

  Widget _buildMonitorStatusList() {
    final monitors = [
      {'name': 'Misfire Monitor', 'status': 'Ready', 'color': Colors.green},
      {'name': 'Fuel System Monitor', 'status': 'Ready', 'color': Colors.green},
      {
        'name': 'Catalyst Monitor',
        'status': 'Not Ready',
        'color': Colors.orange
      },
      {
        'name': 'Evaporative System Monitor',
        'status': 'Ready',
        'color': Colors.green
      },
      {
        'name': 'Oxygen Sensor Monitor',
        'status': 'Ready',
        'color': Colors.green
      },
      {
        'name': 'Oxygen Sensor Heater Monitor',
        'status': 'Ready',
        'color': Colors.green
      },
    ];

    return Column(
      children: monitors
          .map((monitor) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      monitor['status'] == 'Ready'
                          ? Icons.check_circle
                          : Icons.warning,
                      color: monitor['color'] as Color,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        monitor['name'] as String,
                        style: FlutterFlowTheme.of(context).bodySmall,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            (monitor['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        monitor['status'] as String,
                        style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                              color: monitor['color'] as Color,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  void _showDeviceSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select OBD2 Device'),
        content: FutureBuilder<List<BluetoothDevice>>(
          future: _diagnosticService.getAvailableDevices(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final devices = snapshot.data ?? [];
            if (devices.isEmpty) {
              return const Text(
                  'No OBD2 devices found. Please pair your ELM327 device first.');
            }

            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return ListTile(
                    leading: const Icon(Icons.bluetooth),
                    title: Text(device.name ?? 'Unknown Device'),
                    subtitle: Text(device.address),
                    onTap: () {
                      setState(() {
                        _selectedOBD2Device = device;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeOBD2Device() async {
    try {
      final devices = await _diagnosticService.getAvailableDevices();
      if (devices.isNotEmpty) {
        setState(() {
          _selectedOBD2Device = devices.first;
        });
      }
    } catch (e) {
      print('Error initializing OBD2 device: $e');
    }
  }

  int _calculateVehicleHealth() {
    // Get health score from GPT analysis if available
    // This would be populated from the diagnostic service's GPT analysis
    if (_lastGptHealthScore != null) {
      return _lastGptHealthScore!;
    }

    // Fallback to basic calculation if no GPT analysis
    final mockTroubleCodes = 2;
    final mockEmissionsReady = 3;
    final mockTotalEmissions = 4;

    int health = 100;
    health -= mockTroubleCodes * 10;
    final notReadyEmissions = mockTotalEmissions - mockEmissionsReady;
    health -= notReadyEmissions * 5;

    return health.clamp(0, 100);
  }

  Color _getHealthColor(int healthScore) {
    if (healthScore >= 80) return FlutterFlowTheme.of(context).success;
    if (healthScore >= 60) return FlutterFlowTheme.of(context).warning;
    if (healthScore >= 40) return FlutterFlowTheme.of(context).error;
    return FlutterFlowTheme.of(context).error;
  }

  String _getHealthStatus(int healthScore) {
    if (healthScore >= 80) return 'Excellent condition';
    if (healthScore >= 60) return 'Good condition';
    if (healthScore >= 40) return 'Needs attention';
    return 'Requires immediate service';
  }

  // Store the last GPT health score
  int? _lastGptHealthScore;

  // Infer health score from GPT analysis sentiment
  int _inferHealthFromSentiment(String analysis) {
    final lowerAnalysis = analysis.toLowerCase();

    // Positive indicators
    int score = 50; // Start at neutral

    if (lowerAnalysis.contains('excellent') ||
        lowerAnalysis.contains('perfect')) {
      score += 30;
    } else if (lowerAnalysis.contains('good') ||
        lowerAnalysis.contains('healthy')) {
      score += 20;
    } else if (lowerAnalysis.contains('fair') ||
        lowerAnalysis.contains('acceptable')) {
      score += 10;
    }

    // Negative indicators
    if (lowerAnalysis.contains('critical') ||
        lowerAnalysis.contains('severe')) {
      score -= 40;
    } else if (lowerAnalysis.contains('warning') ||
        lowerAnalysis.contains('attention')) {
      score -= 20;
    } else if (lowerAnalysis.contains('minor') ||
        lowerAnalysis.contains('slight')) {
      score -= 10;
    }

    // Trouble code impact
    final troubleCodeCount = RegExp(r'P\d{4}').allMatches(analysis).length;
    score -= troubleCodeCount * 5;

    return score.clamp(0, 100);
  }

  // Add missing methods
  List<VehicleRecord> _getMockVehicles() {
    return [
      VehicleRecord(
        vin: '1HGBH41JXMN109186',
        make: 'Honda',
        model: 'Civic',
        year: '2021',
        nickname: 'My Daily Driver',
        color: 'Blue',
        licensePlate: 'ABC123',
        mileage: '45000',
      ),
      VehicleRecord(
        vin: '5NPE34AF4FH012345',
        make: 'Hyundai',
        model: 'Sonata',
        year: '2015',
        nickname: 'Work Car',
        color: 'Silver',
        licensePlate: 'XYZ789',
        mileage: '125000',
      ),
    ];
  }

  List<RecentChat> _getRecentChats() {
    return [
      RecentChat(
        id: '1',
        question: 'How do I check my engine oil?',
        timestamp: '2 hours ago',
        vehicleVin: '1HGBH41JXMN109186',
      ),
      RecentChat(
        id: '2',
        question: 'What does the check engine light mean?',
        timestamp: '1 day ago',
        vehicleVin: '1HGBH41JXMN109186',
      ),
      RecentChat(
        id: '3',
        question: 'How often should I change my brake fluid?',
        timestamp: '3 days ago',
        vehicleVin: '5NPE34AF4FH012345',
      ),
    ];
  }

  Widget _buildEnhancedFeaturesDemo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
            FlutterFlowTheme.of(context).secondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: FlutterFlowTheme.of(context).primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Enhanced Features Demo',
                style: FlutterFlowTheme.of(context).titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: FlutterFlowTheme.of(context).primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Experience the latest enhancements including improved loading states, error handling, accessibility features, and more.',
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showLoadingDemo(),
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Loading Demo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showErrorDemo(),
                  icon: const Icon(Icons.error_outline, size: 16),
                  label: const Text('Error Demo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).warning,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                GoRouter.of(context).push('/enhanced-features-demo');
              },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Full Enhanced Features Demo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadingDemo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enhanced Loading Demo'),
        content: SizedBox(
          height: 200,
          child: Column(
            children: [
              const EnhancedLoadingWidget(
                message: 'Connecting to vehicle...',
                type: LoadingType.spinner,
              ),
              const SizedBox(height: 20),
              const EnhancedLoadingWidget(
                message: 'Scanning systems...',
                type: LoadingType.progress,
                progress: 0.7,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorDemo() {
    EnhancedErrorHandler.showUserFriendlyError(
      context,
      'This is a demonstration of the enhanced error handling system. It provides user-friendly error messages with retry options.',
      title: 'Enhanced Error Demo',
      onRetry: () {
        Navigator.of(context).pop();
        EnhancedErrorHandler.showToast(
          context,
          'Retry action performed successfully!',
          type: ToastType.success,
        );
      },
      onDismiss: () {
        Navigator.of(context).pop();
        EnhancedErrorHandler.showToast(
          context,
          'Error dismissed',
          type: ToastType.info,
        );
      },
    );
  }

  void _navigateToFullDemo() {
    Navigator.of(context).pushNamed('/enhanced-features-demo');
  }
}

// Custom painter for the compact gauge
class CompactGaugePainter extends CustomPainter {
  final double value; // 0.0 to 1.0
  final Color color;
  final Color backgroundColor;

  CompactGaugePainter({
    required this.value,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Draw background arc
    final backgroundPaint = Paint()
      ..color = backgroundColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -2.356, // -135 degrees (start angle)
      4.712, // 270 degrees (sweep angle)
      false,
      backgroundPaint,
    );

    // Draw value arc
    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -2.356, // -135 degrees (start angle)
      4.712 * value, // 270 degrees * value (sweep angle)
      false,
      valuePaint,
    );

    // Draw subtle tick marks
    final tickPaint = Paint()
      ..color = backgroundColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 5; i++) {
      final angle = -2.356 + (4.712 * i / 5);
      final startRadius = radius - 6;
      final endRadius = radius - 1;

      final startPoint = Offset(
        center.dx + startRadius * cos(angle),
        center.dy + startRadius * sin(angle),
      );
      final endPoint = Offset(
        center.dx + endRadius * cos(angle),
        center.dy + endRadius * sin(angle),
      );

      canvas.drawLine(startPoint, endPoint, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
