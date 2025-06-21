import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../backend/providers/vehicle_provider.dart';
import '../../backend/schema/vehicle_record.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import 'add_vehicle_widget.dart';
import 'vehicle_detail_widget.dart';

class VehicleListWidget extends StatefulWidget {
  const VehicleListWidget({Key? key}) : super(key: key);

  @override
  State<VehicleListWidget> createState() => _VehicleListWidgetState();
}

class _VehicleListWidgetState extends State<VehicleListWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: true,
        title: Text(
          'My Vehicles',
          style: FlutterFlowTheme.of(context).headlineMedium.copyWith(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontSize: 22,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddVehicleWidget(),
                ),
              );
            },
          ),
        ],
        centerTitle: false,
        elevation: 2,
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, vehicleProvider, child) {
          if (vehicleProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vehicleProvider.errorMessage.isNotEmpty) {
            return _buildErrorWidget(vehicleProvider);
          }

          if (vehicleProvider.vehicles.isEmpty) {
            return _buildEmptyState();
          }

          return _buildVehicleList(vehicleProvider);
        },
      ),
    );
  }

  Widget _buildErrorWidget(VehicleProvider vehicleProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Vehicles',
            style: FlutterFlowTheme.of(context).headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            vehicleProvider.errorMessage,
            style: FlutterFlowTheme.of(context).bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              vehicleProvider.clearError();
              vehicleProvider.initialize();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.car,
            size: 64,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'No Vehicles Added',
            style: FlutterFlowTheme.of(context).headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first vehicle to start tracking diagnostics and chat sessions.',
            style: FlutterFlowTheme.of(context).bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddVehicleWidget(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Vehicle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleList(VehicleProvider vehicleProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vehicleProvider.vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicleProvider.vehicles[index];
        return _buildVehicleCard(vehicle, vehicleProvider);
      },
    );
  }

  Widget _buildVehicleCard(VehicleRecord vehicle, VehicleProvider vehicleProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          vehicleProvider.selectVehicle(vehicle);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleDetailWidget(vehicle: vehicle),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.nickname ?? '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                          style: FlutterFlowTheme.of(context).titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'VIN: ${vehicle.vin}',
                          style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleVehicleAction(value, vehicle, vehicleProvider),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildVehicleInfo('Make', vehicle.make),
                  ),
                  Expanded(
                    child: _buildVehicleInfo('Model', vehicle.model),
                  ),
                  Expanded(
                    child: _buildVehicleInfo('Year', vehicle.year),
                  ),
                ],
              ),
              if (vehicle.color != null || vehicle.licensePlate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (vehicle.color != null) ...[
                      Expanded(
                        child: _buildVehicleInfo('Color', vehicle.color!),
                      ),
                    ],
                    if (vehicle.licensePlate != null) ...[
                      Expanded(
                        child: _buildVehicleInfo('Plate', vehicle.licensePlate!),
                      ),
                    ],
                  ],
                ),
              ],
              if (vehicle.lastScanDate != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Last scan: ${_formatDate(vehicle.lastScanDate!)}',
                      style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
      begin: 0.3,
      duration: 300.ms,
    );
  }

  Widget _buildVehicleInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FlutterFlowTheme.of(context).bodySmall.copyWith(
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
        ),
        Text(
          value,
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _handleVehicleAction(String action, VehicleRecord vehicle, VehicleProvider vehicleProvider) {
    switch (action) {
      case 'edit':
        _showEditVehicleDialog(vehicle, vehicleProvider);
        break;
      case 'delete':
        _showDeleteVehicleDialog(vehicle, vehicleProvider);
        break;
    }
  }

  void _showEditVehicleDialog(VehicleRecord vehicle, VehicleProvider vehicleProvider) {
    final nicknameController = TextEditingController(text: vehicle.nickname);
    final colorController = TextEditingController(text: vehicle.color);
    final licensePlateController = TextEditingController(text: vehicle.licensePlate);
    final mileageController = TextEditingController(text: vehicle.mileage);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Vehicle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Nickname',
                  hintText: 'e.g., My Car, Work Truck',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  hintText: 'e.g., Red, Blue, Silver',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: licensePlateController,
                decoration: const InputDecoration(
                  labelText: 'License Plate',
                  hintText: 'e.g., ABC123',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mileageController,
                decoration: const InputDecoration(
                  labelText: 'Mileage',
                  hintText: 'e.g., 50000',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await vehicleProvider.updateVehicle(
                vin: vehicle.vin,
                nickname: nicknameController.text.trim().isEmpty ? null : nicknameController.text.trim(),
                color: colorController.text.trim().isEmpty ? null : colorController.text.trim(),
                licensePlate: licensePlateController.text.trim().isEmpty ? null : licensePlateController.text.trim(),
                mileage: mileageController.text.trim().isEmpty ? null : mileageController.text.trim(),
              );
              
              if (success) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vehicle updated successfully')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteVehicleDialog(VehicleRecord vehicle, VehicleProvider vehicleProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text(
          'Are you sure you want to delete ${vehicle.nickname ?? 'this vehicle'}? '
          'This will also delete all associated scan results and chat sessions. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await vehicleProvider.deleteVehicle(vehicle.vin);
              if (success) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vehicle deleted successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 