import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_theme.dart';

class VehicleDetailWidget extends StatelessWidget {
  const VehicleDetailWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle Detail (UI template)', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 16),
            Text('This is a placeholder for vehicle detail.'),
          ],
        ),
      ),
    );
  }
} 