import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../backend/providers/vehicle_provider.dart';
import '../../flutter_flow/flutter_flow_theme.dart';

class AddVehicleWidget extends StatefulWidget {
  const AddVehicleWidget({Key? key}) : super(key: key);

  @override
  State<AddVehicleWidget> createState() => _AddVehicleWidgetState();
}

class _AddVehicleWidgetState extends State<AddVehicleWidget> {
  final _formKey = GlobalKey<FormState>();
  final _vinController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _colorController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _mileageController = TextEditingController();
  
  bool _isLoading = false;
  bool _isVINValid = false;

  @override
  void dispose() {
    _vinController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _nicknameController.dispose();
    _colorController.dispose();
    _licensePlateController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: true,
        title: Text(
          'Add Vehicle',
          style: FlutterFlowTheme.of(context).headlineMedium.copyWith(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontSize: 22,
              ),
        ),
        centerTitle: false,
        elevation: 2,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Vehicle Information'),
              const SizedBox(height: 16),
              
              // VIN Field
              TextFormField(
                controller: _vinController,
                decoration: InputDecoration(
                  labelText: 'VIN (Vehicle Identification Number)',
                  hintText: 'Enter 17-character VIN',
                  suffixIcon: _isVINValid 
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : Icon(Icons.info_outline, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'VIN is required';
                  }
                  if (value.length != 17) {
                    return 'VIN must be 17 characters';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _isVINValid = value.length == 17;
                  });
                  if (_isVINValid) {
                    _lookupVIN(value);
                  }
                },
                textCapitalization: TextCapitalization.characters,
                maxLength: 17,
              ),
              const SizedBox(height: 16),

              // Make, Model, Year Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _makeController,
                      decoration: InputDecoration(
                        labelText: 'Make',
                        hintText: 'e.g., Toyota',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Make is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      decoration: InputDecoration(
                        labelText: 'Model',
                        hintText: 'e.g., Camry',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Model is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Year Field
              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(
                  labelText: 'Year',
                  hintText: 'e.g., 2020',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Year is required';
                  }
                  final year = int.tryParse(value);
                  if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                    return 'Please enter a valid year';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Additional Information (Optional)'),
              const SizedBox(height: 16),

              // Nickname Field
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: 'Nickname',
                  hintText: 'e.g., My Car, Work Truck',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Color and License Plate Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _colorController,
                      decoration: InputDecoration(
                        labelText: 'Color',
                        hintText: 'e.g., Red, Blue',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _licensePlateController,
                      decoration: InputDecoration(
                        labelText: 'License Plate',
                        hintText: 'e.g., ABC123',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Mileage Field
              TextFormField(
                controller: _mileageController,
                decoration: InputDecoration(
                  labelText: 'Current Mileage',
                  hintText: 'e.g., 50000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final mileage = int.tryParse(value);
                    if (mileage == null || mileage < 0) {
                      return 'Please enter a valid mileage';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

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
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Add Vehicle',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: FlutterFlowTheme.of(context).titleMedium.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _lookupVIN(String vin) {
    // This is a simplified VIN lookup
    // In a real app, you would call an API to get vehicle details
    // For now, we'll just show a placeholder
    if (vin.length == 17) {
      // Simulate API call delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _vinController.text == vin) {
          // This would be replaced with actual VIN lookup API
          // For demo purposes, we'll just show a message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('VIN lookup feature would be implemented here'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  Future<void> _addVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final vehicleProvider = context.read<VehicleProvider>();
      
      final vehicle = await vehicleProvider.addVehicle(
        vin: _vinController.text.trim().toUpperCase(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: _yearController.text.trim(),
        nickname: _nicknameController.text.trim().isEmpty 
            ? null 
            : _nicknameController.text.trim(),
        color: _colorController.text.trim().isEmpty 
            ? null 
            : _colorController.text.trim(),
        licensePlate: _licensePlateController.text.trim().isEmpty 
            ? null 
            : _licensePlateController.text.trim().toUpperCase(),
        mileage: _mileageController.text.trim().isEmpty 
            ? null 
            : _mileageController.text.trim(),
      );

      if (vehicle != null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${vehicle.nickname ?? 'Vehicle'} added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vehicleProvider.errorMessage),
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
} 