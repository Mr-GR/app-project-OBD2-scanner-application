import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile Settings (UI template)', 
                style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 16),
            const Text('This is a placeholder for profile settings.'),
          ],
        ),
      ),
    );
  }
} 