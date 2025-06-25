import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_theme.dart';

class SubscriptionDetailsScreen extends StatelessWidget {
  const SubscriptionDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subscription Details (UI template)', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 16),
            Text('This is a placeholder for subscription details.'),
          ],
        ),
      ),
    );
  }
} 