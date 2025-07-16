import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/services/vehicle_service.dart';
import '/services/obd2_bluetooth_service.dart';

class AddVehicleWidget extends StatefulWidget {
  const AddVehicleWidget({super.key});

  @override
  State<AddVehicleWidget> createState() => _AddVehicleWidgetState();
}

class _AddVehicleWidgetState extends State<AddVehicleWidget> {
  final _formKey = GlobalKey<FormState>();
  final _vinController = TextEditingController();
  bool _isLoading = false;
  bool _isLookingUp = false;
  bool _isScanningVin = false;
  VehicleResponse? _previewVehicle;
  bool _setPrimary = false;
  late OBD2BluetoothService _obd2Service;

  @override
  void initState() {
    super.initState();
    _obd2Service = OBD2BluetoothService();
  }

  @override
  void dispose() {
    _vinController.dispose();
    super.dispose();
  }

  Future<void> _getVinFromScanner() async {
    if (!_obd2Service.isConnected) {
      _showErrorSnackBar('OBD2 scanner not connected. Please connect via Connection tab first.');
      return;
    }

    setState(() {
      _isScanningVin = true;
    });

    try {
      // Clear any existing VIN data first
      _obd2Service.liveData.remove('vin');
      
      // Add some delay to ensure scanner is ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Request VIN from scanner using the working method
      await _obd2Service.requestVIN();
      
      // Wait longer for VIN processing (multi-frame response takes time)
      await Future.delayed(const Duration(seconds: 5));
      
      // Check if VIN was successfully retrieved
      final retrievedVin = _obd2Service.liveData['vin'];
      
      debugPrint('🔍 VIN retrieval attempt - got: $retrievedVin');
      
      if (retrievedVin != null && retrievedVin.toString().length >= 8) {
        // Auto-populate VIN field
        setState(() {
          _vinController.text = retrievedVin.toString().toUpperCase();
          _previewVehicle = null; // Clear any existing preview
        });
        
        _showSuccessSnackBar('VIN retrieved from scanner: ${retrievedVin.toString()}');
      } else {
        // Check if there was a VIN in the live data from previous requests
        if (_obd2Service.liveData.containsKey('vin') && _obd2Service.liveData['vin'] != null) {
          final existingVin = _obd2Service.liveData['vin'].toString();
          if (existingVin.length >= 8) {
            setState(() {
              _vinController.text = existingVin.toUpperCase();
              _previewVehicle = null;
            });
            _showSuccessSnackBar('Using previously retrieved VIN: $existingVin');
            return;
          }
        }
        _showErrorDialog('Unable to retrieve VIN from scanner. Please add manual.');
      }
    } catch (e) {
      debugPrint('🔍 VIN scanning error: $e');
      _showErrorDialog('Error scanning VIN. Please add manual.');
    } finally {
      if (mounted) {
        setState(() {
          _isScanningVin = false;
        });
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'VIN Scanner Error',
                  style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
              ],
            ),
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Text(
                message,
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('OK'),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _lookupVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLookingUp = true;
      _previewVehicle = null;
    });

    try {
      final vehicle = await VehicleService.getVehicleByVin(_vinController.text.trim());

      if (mounted) {
        setState(() {
          _previewVehicle = vehicle;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error looking up vehicle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLookingUp = false;
        });
      }
    }
  }

  Future<void> _addVehicle() async {
    if (_previewVehicle == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final savedVehicle = await VehicleService.addVehicle(
        vin: _vinController.text.trim(),
        isPrimary: _setPrimary,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vehicle added successfully: ${savedVehicle.make} ${savedVehicle.model}'),
            backgroundColor: Colors.green,
          ),
        );

        // Return success to trigger refresh
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding vehicle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vehicle'),
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Vehicle by VIN', style: FlutterFlowTheme.of(context).titleLarge),
              const SizedBox(height: 8),
              Text('Enter your vehicle\'s VIN to automatically get vehicle information',
                   style: FlutterFlowTheme.of(context).bodyMedium),
              const SizedBox(height: 24),

              // VIN Input
              TextFormField(
                controller: _vinController,
                decoration: const InputDecoration(
                  labelText: 'VIN *',
                  border: OutlineInputBorder(),
                  helperText: '17-character Vehicle Identification Number',
                  prefixIcon: Icon(Icons.directions_car),
                ),
                maxLength: 17,
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the VIN';
                  }
                  if (value.length != 17) {
                    return 'VIN must be exactly 17 characters';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_previewVehicle != null) {
                    setState(() {
                      _previewVehicle = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Get VIN from Scanner Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isScanningVin ? null : _getVinFromScanner,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isScanningVin
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bluetooth_searching, size: 20),
                            const SizedBox(width: 8),
                            const Text('Get VIN from Scanner'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Lookup Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLookingUp ? null : _lookupVehicle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLookingUp
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Lookup Vehicle'),
                ),
              ),

              // Vehicle Preview
              if (_previewVehicle != null) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text('Vehicle Found', style: FlutterFlowTheme.of(context).titleSmall),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _vehicleInfoRow('Make', _previewVehicle!.make),
                      _vehicleInfoRow('Model', _previewVehicle!.model),
                      _vehicleInfoRow('Year', _previewVehicle!.year),
                      _vehicleInfoRow('VIN', _previewVehicle!.vin ?? ''),
                      if (_previewVehicle!.vehicleType?.isNotEmpty == true)
                        _vehicleInfoRow('Type', _previewVehicle!.vehicleType!),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Set as Primary Checkbox
                CheckboxListTile(
                  title: const Text('Set as Primary Vehicle'),
                  subtitle: const Text('Use this vehicle for diagnostic context in AI chat'),
                  value: _setPrimary,
                  onChanged: (value) {
                    setState(() {
                      _setPrimary = value ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),

                // Add Vehicle Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addVehicle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlutterFlowTheme.of(context).primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Add Vehicle to Garage'),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: FlutterFlowTheme.of(context).primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                             color: FlutterFlowTheme.of(context).primary,
                             size: 20),
                        const SizedBox(width: 8),
                        Text('What is a VIN?',
                             style: FlutterFlowTheme.of(context).titleSmall),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A Vehicle Identification Number (VIN) is a unique 17-character code that identifies your vehicle. You can find it on your vehicle registration, insurance card, or on the dashboard near the windshield.',
                      style: FlutterFlowTheme.of(context).bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vehicleInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Unknown',
              style: FlutterFlowTheme.of(context).bodySmall,
            ),
          ),
        ],
      ),
    );
  }
} 