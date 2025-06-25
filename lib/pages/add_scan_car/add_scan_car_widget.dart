import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_theme.dart';

class AddScanCarWidget extends StatelessWidget {
  const AddScanCarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Scan Car'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Scan Car (UI template)', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 16),
            Text('This is a placeholder for add scan car screen.'),
          ],
        ),
      ),
    );
  }
} 