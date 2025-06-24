import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_theme.dart';

class UpgradeProScreen extends StatelessWidget {
  const UpgradeProScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upgrade to Pro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upgrade to Pro (UI template)', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 16),
            Text('This is a placeholder for upgrade to pro.'),
          ],
        ),
      ),
    );
  }
} 