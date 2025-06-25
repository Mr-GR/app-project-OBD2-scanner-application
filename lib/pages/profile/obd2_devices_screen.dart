import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_theme.dart';

class OBD2DevicesScreen extends StatelessWidget {
  const OBD2DevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OBD2 Devices'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OBD2 Devices (UI template)', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 16),
            Text('This is a placeholder for OBD2 devices.'),
          ],
        ),
      ),
    );
  }
} 