import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/auth/auth_util.dart';
import 'settings_model.dart';
export 'settings_model.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  late SettingsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Settings state
  bool _autoScanEnabled = false;
  bool _saveReportsLocally = true;
  String _temperatureUnit = 'Celsius';
  String _speedUnit = 'MPH';
  
  // User state
  String? _userName;
  String? _userEmail;
  bool _userLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingsModel());
    _loadSettings();
    _loadUserData();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoScanEnabled = prefs.getBool('auto_scan_enabled') ?? false;
      _saveReportsLocally = prefs.getBool('save_reports_locally') ?? true;
      _temperatureUnit = prefs.getString('temperature_unit') ?? 'Celsius';
      _speedUnit = prefs.getString('speed_unit') ?? 'MPH';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _userLoading = true;
    });

    try {
      final userData = await AuthUtil.getCurrentUser();
      if (mounted && userData != null) {
        setState(() {
          _userName = userData['name'];
          _userEmail = userData['email'];
          _userLoading = false;
        });
      } else {
        setState(() {
          _userName = null;
          _userEmail = null;
          _userLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userName = null;
          _userEmail = null;
          _userLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: true,
          title: Text(
            'Settings',
            style: FlutterFlowTheme.of(context).headlineMedium,
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Section
                  if (!_userLoading) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 3,
                            color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.5),
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userName ?? 'User',
                                  style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_userEmail != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _userEmail!,
                                    style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Scanner Settings
                  _buildSettingsSection('Scanner Settings', [
                    _buildSwitchItem(
                      'Auto-scan on Connect',
                      'Automatically start diagnostics when OBD2 device connects',
                      Icons.auto_fix_high,
                      _autoScanEnabled,
                      (value) {
                        setState(() => _autoScanEnabled = value);
                        _saveSetting('auto_scan_enabled', value);
                      },
                    ),
                    _buildSwitchItem(
                      'Save Reports Locally',
                      'Store diagnostic reports on this device',
                      Icons.save,
                      _saveReportsLocally,
                      (value) {
                        setState(() => _saveReportsLocally = value);
                        _saveSetting('save_reports_locally', value);
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),
                  
                  // Units
                  _buildSettingsSection('Units', [
                    _buildDropdownItem(
                      'Temperature',
                      'Engine temperature display unit',
                      Icons.thermostat,
                      _temperatureUnit,
                      ['Celsius', 'Fahrenheit'],
                      (value) {
                        setState(() => _temperatureUnit = value!);
                        _saveSetting('temperature_unit', value);
                      },
                    ),
                    _buildDropdownItem(
                      'Speed',
                      'Vehicle speed display unit',
                      Icons.speed,
                      _speedUnit,
                      ['MPH', 'KM/H'],
                      (value) {
                        setState(() => _speedUnit = value!);
                        _saveSetting('speed_unit', value);
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),
                  
                  // Account
                  _buildSettingsSection('Account', [
                    _buildActionItem(
                      'Sign Out',
                      'Sign out of your account',
                      Icons.logout,
                      () => _showSignOutConfirmation(),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  
                  // App Info
                  _buildSettingsSection('App Info', [
                    _buildActionItem(
                      'App Version',
                      '1.0.0 (Build 1)',
                      Icons.info,
                      null,
                    ),
                    _buildActionItem(
                      'Contact Support',
                      'Get help with the app',
                      Icons.help_outline,
                      () => _contactSupport(),
                    ),
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Card(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSwitchItem(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon, color: FlutterFlowTheme.of(context).primary),
      title: Text(title, style: FlutterFlowTheme.of(context).bodyMedium),
      subtitle: Text(subtitle, style: FlutterFlowTheme.of(context).bodySmall),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: FlutterFlowTheme.of(context).primary,
      ),
    );
  }

  Widget _buildDropdownItem(String title, String subtitle, IconData icon, String value, List<String> options, Function(String?) onChanged) {
    return ListTile(
      leading: Icon(icon, color: FlutterFlowTheme.of(context).primary),
      title: Text(title, style: FlutterFlowTheme.of(context).bodyMedium),
      subtitle: Text(subtitle, style: FlutterFlowTheme.of(context).bodySmall),
      trailing: SizedBox(
        width: 120,
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          underline: Container(),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option, style: FlutterFlowTheme.of(context).bodySmall),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionItem(String title, String subtitle, IconData icon, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, color: FlutterFlowTheme.of(context).primary),
      title: Text(title, style: FlutterFlowTheme.of(context).bodyMedium),
      subtitle: Text(subtitle, style: FlutterFlowTheme.of(context).bodySmall),
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }

  // Helper methods for actions
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }


  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Get help and support:'),
            SizedBox(height: 16),
            Text('📧 Email: support@obd2scanner.com'),
            SizedBox(height: 8),
            Text('📱 Phone: 1-800-OBD-SCAN'),
            SizedBox(height: 8),
            Text('🌐 Website: www.obd2scanner.com/support'),
            SizedBox(height: 8),
            Text('⏰ Hours: Mon-Fri 9AM-6PM EST'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _performSignOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _performSignOut() async {
    try {
      // Show loading indicator
      _showSnackBar('Signing out...', FlutterFlowTheme.of(context).primary);
      
      // Perform sign out
      await AuthUtil.signOut();
      
      // Navigate to onboarding screen
      if (mounted) {
        context.go('/onboarding');
      }
    } catch (e) {
      // Show error message
      _showSnackBar(
        'Error signing out. Please try again.',
        Colors.red,
      );
    }
  }
}
