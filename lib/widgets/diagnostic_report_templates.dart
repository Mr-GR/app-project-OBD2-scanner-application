import 'package:flutter/material.dart';
import '../flutter_flow/flutter_flow_theme.dart';

class DiagnosticReportTemplates extends StatelessWidget {
  const DiagnosticReportTemplates({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diagnostic Report Templates'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Diagnostic Report Templates (UI template)', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 16),
            Text('This is a placeholder for diagnostic report templates.'),
          ],
        ),
      ),
    );
  }
} 