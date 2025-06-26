import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:o_b_d2_scanner_frontend/config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/services/vehicle_service.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  List<VehicleResponse> _vehicles = [];
  bool _vehiclesLoading = true;
  final PageController _pageController = PageController(viewportFraction: 0.8);

  // Quick Code Check state
  final TextEditingController _dtcController = TextEditingController();
  Map<String, String>? _dtcResult;
  String? _dtcError;
  bool _dtcLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _vehiclesLoading = true;
    });

    try {
      final vehicles = await VehicleService.getVehicles();
      if (mounted) {
        setState(() {
          _vehicles = vehicles;
          _vehiclesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _vehiclesLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading vehicles: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToAddCar() async {
    final result = await GoRouter.of(context).push('/add-vehicle');
    if (result == true) {
      // Refresh vehicles list
      _loadVehicles();
    }
  }

  Future<void> _deleteVehicle(VehicleResponse vehicle) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Are you sure you want to delete ${vehicle.make} ${vehicle.model}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await VehicleService.deleteVehicle(vehicle.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehicle deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadVehicles(); // Refresh list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting vehicle: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _setPrimaryVehicle(VehicleResponse vehicle) async {
    try {
      await VehicleService.setPrimaryVehicle(vehicle.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${vehicle.make} ${vehicle.model} set as primary vehicle'),
            backgroundColor: Colors.green,
          ),
        );
        _loadVehicles(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting primary vehicle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _lookupDtcCode() async {
    final code = _dtcController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      _dtcLoading = true;
      _dtcResult = null;
      _dtcError = null;
    });

    try {
      final response = await http.get(Uri.parse('http://${Config.baseUrl}/api/scanner/dtc/lookup?code=$code'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _dtcResult = {
            'code': data['code'] ?? code,
            'description': data['description'] ?? 'No description found.'
          };
          _dtcError = null;
        });
      } else {
        setState(() {
          _dtcResult = null;
          _dtcError = 'Code not found.';
        });
      }
    } catch (e) {
      setState(() {
        _dtcResult = null;
        _dtcError = 'Error: $e';
      });
    } finally {
      setState(() {
        _dtcLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        elevation: 0,
        title: const Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVehicles,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadVehicles,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Card
                Card(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome Back!', style: FlutterFlowTheme.of(context).titleLarge),
                        const SizedBox(height: 8),
                        Text('Ready for your next scan or chat?', style: FlutterFlowTheme.of(context).bodyMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Carousel
                SizedBox(
                  height: 160,
                  child: PageView(
                    controller: _pageController,
                    children: [
                      _QuickActionCard(
                        icon: Icons.flash_on,
                        color: Colors.orange,
                        title: 'Quick Scan',
                        subtitle: 'Start a new vehicle scan',
                        onTap: () {},
                      ),
                      _QuickActionCard(
                        icon: Icons.chat_bubble_outline,
                        color: Colors.blue,
                        title: 'AI Chat',
                        subtitle: 'Ask the AI assistant',
                        onTap: () {
                          GoRouter.of(context).push('/chat');
                        },
                      ),
                      _QuickActionCard(
                        icon: Icons.add_card,
                        color: Colors.green,
                        title: 'Add Car',
                        subtitle: 'Add a new vehicle',
                        onTap: _navigateToAddCar,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Code Check
                Card(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quick Code Check', style: FlutterFlowTheme.of(context).titleMedium),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _dtcController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            hintText: 'Enter DTC Code',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _lookupDtcCode(),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _dtcLoading ? null : _lookupDtcCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FlutterFlowTheme.of(context).primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _dtcLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Check Code'),
                          ),
                        ),
                        if (_dtcResult != null)
                          Card(
                            color: FlutterFlowTheme.of(context).primaryBackground,
                            margin: const EdgeInsets.only(top: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Code: ${_dtcResult!['code']}', style: FlutterFlowTheme.of(context).titleSmall),
                                  const SizedBox(height: 8),
                                  Text('Description: ${_dtcResult!['description']}', style: FlutterFlowTheme.of(context).bodyMedium),
                                ],
                              ),
                            ),
                          ),
                        if (_dtcError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(_dtcError!, style: const TextStyle(color: Colors.red)),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // My Vehicles Section
                Card(
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
                            Text('My Vehicles', style: FlutterFlowTheme.of(context).titleMedium),
                            TextButton.icon(
                              onPressed: _navigateToAddCar,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Vehicle'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (_vehiclesLoading)
                          const Center(
                            child: CircularProgressIndicator(),
                          )
                        else if (_vehicles.isEmpty)
                          Column(
                            children: [
                              Icon(
                                Icons.directions_car_outlined,
                                size: 48,
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No vehicles added yet',
                                style: FlutterFlowTheme.of(context).bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap "Add Vehicle" to get started',
                                style: FlutterFlowTheme.of(context).bodySmall,
                              ),
                            ],
                          )
                        else
                          Column(
                            children: _vehicles.map((vehicle) => _buildVehicleCard(vehicle)).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        selectedItemColor: FlutterFlowTheme.of(context).primary,
        unselectedItemColor: FlutterFlowTheme.of(context).secondaryText,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Diagnostics'),
        ],
        currentIndex: 0,
        onTap: (index) {},
      ),
    );
  }

  Widget _buildVehicleCard(VehicleResponse vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: vehicle.isPrimary
              ? FlutterFlowTheme.of(context).primary
              : FlutterFlowTheme.of(context).primary.withOpacity(0.2),
          width: vehicle.isPrimary ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_car,
                color: FlutterFlowTheme.of(context).primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                  style: FlutterFlowTheme.of(context).titleSmall,
                ),
              ),
              if (vehicle.isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PRIMARY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'primary':
                      _setPrimaryVehicle(vehicle);
                      break;
                    case 'delete':
                      _deleteVehicle(vehicle);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (!vehicle.isPrimary)
                    PopupMenuItem(
                      value: 'primary',
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 18),
                          const SizedBox(width: 8),
                          const Text('Set as Primary'),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, size: 18, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'VIN: ${vehicle.vin}',
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
              fontFamily: 'monospace',
            ),
          ),
          if (vehicle.vehicleType?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              'Type: ${vehicle.vehicleType}',
              style: FlutterFlowTheme.of(context).bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 12),
                Text(title, style: FlutterFlowTheme.of(context).titleSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: FlutterFlowTheme.of(context).bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
