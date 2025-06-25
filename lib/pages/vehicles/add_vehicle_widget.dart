import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/services/vehicle_service.dart';

class AddVehicleWidget extends StatefulWidget {
  const AddVehicleWidget({super.key});

  @override
  State<AddVehicleWidget> createState() => _AddVehicleWidgetState();
}

class _AddVehicleWidgetState extends State<AddVehicleWidget> {
  final _formKey = GlobalKey<FormState>();
  final _vinController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _vinController.dispose();
    super.dispose();
  }

  Future<void> _lookupVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final vehicle = await VehicleService.getVehicleByVin(_vinController.text.trim());

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vehicle found: ${vehicle.make} ${vehicle.model} ${vehicle.year}'),
            backgroundColor: Colors.green,
          ),
        );

        // Return vehicle data to home page
        Navigator.pop(context, {
          'make': vehicle.make,
          'model': vehicle.model,
          'year': vehicle.year,
          'vin': vehicle.vin,
          'vehicleType': vehicle.vehicleType,
          'bodyClass': vehicle.bodyClass,
          'engineModel': vehicle.engineModel,
          'fuelType': vehicle.fuelType,
          'transmission': vehicle.transmission,
          'engineCylinders': vehicle.engineCylinders,
          'engineDisplacement': vehicle.engineDisplacement,
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
      body: Padding(
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
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _lookupVehicle,
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
                      : const Text('Lookup Vehicle'),
                ),
              ),
              const SizedBox(height: 16),
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
} 