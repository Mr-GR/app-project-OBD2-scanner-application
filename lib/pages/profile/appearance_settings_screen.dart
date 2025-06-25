import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_theme.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appearance Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appearance Settings (UI template)', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 16),
            Text('This is a placeholder for appearance settings.'),
          ],
        ),
      ),
    );
  }
} 