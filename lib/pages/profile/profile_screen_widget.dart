import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class ProfileScreenWidget extends StatefulWidget {
  const ProfileScreenWidget({super.key});

  @override
  State<ProfileScreenWidget> createState() => _ProfileScreenWidgetState();
}

class _ProfileScreenWidgetState extends State<ProfileScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile (UI Template)',
              style: FlutterFlowTheme.of(context).titleLarge,
            ),
            const SizedBox(height: 16),
            const Text('This is a placeholder for profile screen.'),
            const SizedBox(height: 24),
            _buildProfileSection('Account', [
              _buildProfileItem('Personal Information', Icons.person),
              _buildProfileItem('Security Settings', Icons.security),
              _buildProfileItem('Data Management', Icons.storage),
            ]),
            const SizedBox(height: 16),
            _buildProfileSection('App', [
              _buildProfileItem('Appearance', Icons.palette),
              _buildProfileItem('Notifications', Icons.notifications),
              _buildProfileItem('Support', Icons.help),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> items) {
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

  Widget _buildProfileItem(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: FlutterFlowTheme.of(context).primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Placeholder for profile navigation
      },
    );
  }
} 