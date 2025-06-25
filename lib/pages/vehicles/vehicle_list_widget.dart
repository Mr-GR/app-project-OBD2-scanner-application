import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_theme.dart';

class VehicleListWidget extends StatelessWidget {
  const VehicleListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle List (UI template)', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 16),
            Text('This is a placeholder for vehicle list.'),
          ],
        ),
      ),
    );
  }
} 