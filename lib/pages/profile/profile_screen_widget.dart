import 'package:flutter/material.dart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile (UI template)', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 16),
            Text('This is a placeholder for profile screen.'),
          ],
        ),
      ),
    );
  }
} 