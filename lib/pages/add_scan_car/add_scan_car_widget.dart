import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../vehicles/add_vehicle_widget.dart';

class AddScanCarWidget extends StatefulWidget {
  const AddScanCarWidget({Key? key}) : super(key: key);

  @override
  State<AddScanCarWidget> createState() => _AddScanCarWidgetState();
}

class _AddScanCarWidgetState extends State<AddScanCarWidget> {
  bool _isLoading = false;
  String _selectedMethod = 'manual'; // 'manual' or 'obd2'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: true,
        title: Text(
          'Add/Scan Car',
          style: FlutterFlowTheme.of(context).headlineMedium.copyWith(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontSize: 22,
              ),
        ),
        centerTitle: false,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMethodSelector(),
            const SizedBox(height: 24),
            _buildMethodContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Method',
              style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMethodOption(
                    'manual',
                    'Manual Entry',
                    FontAwesomeIcons.keyboard,
                    'Enter VIN manually',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMethodOption(
                    'obd2',
                    'OBD2 Scanner',
                    FontAwesomeIcons.bluetooth,
                    'Connect to ELM327',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOption(String method, String title, IconData icon, String subtitle) {
    final isSelected = _selectedMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1)
              : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? FlutterFlowTheme.of(context).primary
                  : FlutterFlowTheme.of(context).secondaryText,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected 
                    ? FlutterFlowTheme.of(context).primary
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodContent() {
    switch (_selectedMethod) {
      case 'manual':
        return _buildManualEntry();
      case 'obd2':
        return _buildOBD2Scanner();
      default:
        return _buildManualEntry();
    }
  }

  Widget _buildManualEntry() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.keyboard,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Manual VIN Entry',
                  style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Enter your vehicle\'s VIN (Vehicle Identification Number) to add it to your garage.',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _navigateToManualEntry();
              },
              icon: const Icon(Icons.add),
              label: const Text('Enter VIN Manually'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOBD2Scanner() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.bluetooth,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'OBD2 Scanner Connection',
                  style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Connect to your ELM327 OBD2 scanner to automatically read vehicle information and diagnostic data.',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).alternate,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Requirements:',
                    style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRequirement('ELM327 OBD2 scanner'),
                  _buildRequirement('Bluetooth or USB connection'),
                  _buildRequirement('Vehicle ignition turned on'),
                  _buildRequirement('Scanner connected to vehicle'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _connectToOBD2,
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.bluetooth_searching),
              label: Text(_isLoading ? 'Connecting...' : 'Connect to Scanner'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: FlutterFlowTheme.of(context).bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToManualEntry() {
    // Navigate to the existing AddVehicleWidget
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddVehicleWidget(),
      ),
    );
  }

  Future<void> _connectToOBD2() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate OBD2 connection process
      await Future.delayed(const Duration(seconds: 2));
      
      // For now, we'll simulate finding a vehicle
      // In a real implementation, this would connect to the OBD2 scanner
      // and read the VIN and other vehicle data
      
      if (mounted) {
        _showOBD2Result();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showOBD2Result() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vehicle Found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('VIN: 1HGBH41JXMN109186'),
            const SizedBox(height: 8),
            Text('Make: Honda'),
            Text('Model: Civic'),
            Text('Year: 2021'),
            const SizedBox(height: 16),
            Text(
              'Would you like to add this vehicle to your garage?',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addVehicleFromOBD2();
            },
            child: const Text('Add Vehicle'),
          ),
        ],
      ),
    );
  }

  Future<void> _addVehicleFromOBD2() async {
    final vehicleProvider = context.read<VehicleProvider>();
    
    final vehicle = await vehicleProvider.addVehicle(
      vin: '1HGBH41JXMN109186',
      make: 'Honda',
      model: 'Civic',
      year: '2021',
      nickname: 'My Honda Civic',
    );

    if (vehicle != null) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle added successfully from OBD2 scan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
} 