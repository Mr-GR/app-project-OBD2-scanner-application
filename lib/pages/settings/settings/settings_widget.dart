import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingsModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings (UI Template)',
                  style: FlutterFlowTheme.of(context).titleLarge,
                ),
                const SizedBox(height: 16),
                const Text('This is a placeholder for settings.'),
                const SizedBox(height: 24),
                _buildSettingsSection('Account', [
                  _buildSettingsItem('Profile', Icons.person),
                  _buildSettingsItem('Security', Icons.security),
                  _buildSettingsItem('Notifications', Icons.notifications),
                ]),
                const SizedBox(height: 16),
                _buildSettingsSection('App', [
                  _buildSettingsItem('Appearance', Icons.palette),
                  _buildSettingsItem('Language', Icons.language),
                  _buildSettingsItem('About', Icons.info),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: FlutterFlowTheme.of(context).primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Placeholder for settings navigation
      },
    );
  }
}
