import 'package:flutter/material.dart';

class DiagnosticsTabWidget extends StatefulWidget {
  const DiagnosticsTabWidget({super.key});

  @override
  State<DiagnosticsTabWidget> createState() => _DiagnosticsTabWidgetState();
}

class _DiagnosticsTabWidgetState extends State<DiagnosticsTabWidget> {
  final TextEditingController _aiQuestionController = TextEditingController();

  @override
  void dispose() {
    _aiQuestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        elevation: 0,
        title: Text(
          'Diagnostics',
          style: FlutterFlowTheme.of(context).titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              _buildQuickActionsCard(),
              const SizedBox(height: 20),
              _buildAIChatSection(),
              const SizedBox(height: 20),
              _buildMyCarSection(),
              const SizedBox(height: 20),
              _buildRecentScansCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Icon(Icons.directions_car, size: 32),
                SizedBox(height: 8),
                Text('Scan'),
              ],
            ),
            Column(
              children: [
                Icon(Icons.history, size: 32),
                SizedBox(height: 8),
                Text('History'),
              ],
            ),
            Column(
              children: [
                Icon(Icons.settings, size: 32),
                SizedBox(height: 8),
                Text('Settings'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIChatSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Chat', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _aiQuestionController,
              decoration: InputDecoration(
                hintText: 'Ask the AI about your car...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyCarSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Car', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 12),
            Text('No vehicle selected. (UI template)'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScansCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Scans', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 12),
            Text('No scans yet. (UI template)'),
          ],
        ),
      ),
    );
  }
} 