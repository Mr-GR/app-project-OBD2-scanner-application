import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _includeChats = true;
  bool _includeVehicles = true;
  bool _includeScanReports = true;
  bool _includeSettings = false;
  String _exportFormat = 'JSON';
  double _totalDataSize = 0.0;

  final List<String> _exportFormats = ['JSON', 'CSV', 'PDF'];

  @override
  void initState() {
    super.initState();
    _calculateDataSize();
  }

  void _calculateDataSize() {
    // Mock data sizes - in real app, this would calculate actual sizes
    setState(() {
      _totalDataSize = 45.2; // MB
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        elevation: 0,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30,
          borderWidth: 1,
          buttonSize: 60,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 30,
          ),
          onPressed: () async {
            context.go('/profile-settings');
          },
        ),
        title: Text(
          'Data Management',
          style: FlutterFlowTheme.of(context).titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDataOverview(),
            const SizedBox(height: 24),
            _buildExportSection(),
            const SizedBox(height: 24),
            _buildClearDataSection(),
            const SizedBox(height: 24),
            _buildDataTypesSection(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDataOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FlutterFlowTheme.of(context).primary,
            FlutterFlowTheme.of(context).secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.data_usage_outlined, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'Data Overview',
                style: FlutterFlowTheme.of(context).titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDataItem(
                  'Total Data',
                  '${_totalDataSize.toStringAsFixed(1)} MB',
                  Icons.storage_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDataItem(
                  'Chat Messages',
                  '1,247',
                  Icons.chat_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDataItem(
                  'Vehicles',
                  '3',
                  Icons.directions_car_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDataItem(
                  'Scan Reports',
                  '156',
                  Icons.assessment_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.download_outlined, color: FlutterFlowTheme.of(context).primary),
              const SizedBox(width: 12),
              Text(
                'Export Data',
                style: FlutterFlowTheme.of(context).titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Export Format:'),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _exportFormat,
                items: _exportFormats.map((format) => DropdownMenuItem(
                  value: format,
                  child: Text(format),
                )).toList(),
                onChanged: (value) => setState(() => _exportFormat = value!),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _exportData(),
            icon: const Icon(Icons.download),
            label: const Text('Export Selected Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Estimated size: ${_calculateExportSize().toStringAsFixed(1)} MB',
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearDataSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.delete_forever_outlined, color: Colors.red),
              const SizedBox(width: 12),
              Text(
                'Clear Data',
                style: FlutterFlowTheme.of(context).titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline, color: Colors.orange),
            title: const Text('Clear All Chats'),
            subtitle: const Text('Delete all chat messages and conversations'),
            trailing: ElevatedButton(
              onPressed: () => _showClearConfirmation('chats'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(80, 32),
              ),
              child: const Text('Clear'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.directions_car_outlined, color: Colors.blue),
            title: const Text('Clear All Vehicles'),
            subtitle: const Text('Delete all vehicle information and data'),
            trailing: ElevatedButton(
              onPressed: () => _showClearConfirmation('vehicles'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(80, 32),
              ),
              child: const Text('Clear'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.assessment_outlined, color: Colors.purple),
            title: const Text('Clear All Scan Reports'),
            subtitle: const Text('Delete all diagnostic scan reports'),
            trailing: ElevatedButton(
              onPressed: () => _showClearConfirmation('scan reports'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                minimumSize: const Size(80, 32),
              ),
              child: const Text('Clear'),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showClearAllConfirmation(),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Clear All Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTypesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist_outlined, color: FlutterFlowTheme.of(context).primary),
              const SizedBox(width: 12),
              Text(
                'Data Types to Export',
                style: FlutterFlowTheme.of(context).titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            value: _includeChats,
            onChanged: (val) => setState(() => _includeChats = val),
            title: const Text('Chat Messages'),
            subtitle: const Text('Include all chat conversations and AI responses'),
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.chat_outlined),
          ),
          SwitchListTile.adaptive(
            value: _includeVehicles,
            onChanged: (val) => setState(() => _includeVehicles = val),
            title: const Text('Vehicle Information'),
            subtitle: const Text('Include vehicle details, VIN, and specifications'),
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.directions_car_outlined),
          ),
          SwitchListTile.adaptive(
            value: _includeScanReports,
            onChanged: (val) => setState(() => _includeScanReports = val),
            title: const Text('Scan Reports'),
            subtitle: const Text('Include all diagnostic scan results and reports'),
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.assessment_outlined),
          ),
          SwitchListTile.adaptive(
            value: _includeSettings,
            onChanged: (val) => setState(() => _includeSettings = val),
            title: const Text('App Settings'),
            subtitle: const Text('Include app preferences and configuration'),
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
    );
  }

  double _calculateExportSize() {
    double size = 0.0;
    if (_includeChats) size += 25.3; // Mock chat data size
    if (_includeVehicles) size += 8.7; // Mock vehicle data size
    if (_includeScanReports) size += 11.2; // Mock scan data size
    if (_includeSettings) size += 0.5; // Mock settings data size
    return size;
  }

  void _exportData() {
    if (!_includeChats && !_includeVehicles && !_includeScanReports && !_includeSettings) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one data type to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Exporting data in $_exportFormat format...'),
            const SizedBox(height: 16),
            Text('Selected data types:'),
            if (_includeChats) const Text('• Chat Messages'),
            if (_includeVehicles) const Text('• Vehicle Information'),
            if (_includeScanReports) const Text('• Scan Reports'),
            if (_includeSettings) const Text('• App Settings'),
            const SizedBox(height: 8),
            Text('Estimated size: ${_calculateExportSize().toStringAsFixed(1)} MB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performExport();
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _performExport() {
    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exporting Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Preparing your data for export...'),
          ],
        ),
      ),
    );

    // Simulate export process
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close progress dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data exported successfully as obd2_data.${_exportFormat.toLowerCase()}'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Download',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download started (mock)')),
              );
            },
          ),
        ),
      );
    });
  }

  void _showClearConfirmation(String dataType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear $dataType'),
        content: Text(
          'This will permanently delete all your $dataType. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearData(dataType);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete ALL your data including chats, vehicles, scan reports, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearAllData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _clearData(String dataType) {
    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Clearing $dataType'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Deleting $dataType...'),
          ],
        ),
      ),
    );

    // Simulate clearing process
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop(); // Close progress dialog
      setState(() {
        _totalDataSize -= _getDataTypeSize(dataType);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All $dataType cleared successfully'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _clearAllData() {
    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Clearing All Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Deleting all data...'),
          ],
        ),
      ),
    );

    // Simulate clearing process
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close progress dialog
      setState(() {
        _totalDataSize = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data cleared successfully'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  double _getDataTypeSize(String dataType) {
    switch (dataType) {
      case 'chats':
        return 25.3;
      case 'vehicles':
        return 8.7;
      case 'scan reports':
        return 11.2;
      default:
        return 0.0;
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data management settings saved! (mock)')),
              );
              context.go('/profile-settings');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.go('/profile-settings'),
            style: OutlinedButton.styleFrom(
              foregroundColor: FlutterFlowTheme.of(context).primary,
              side: BorderSide(color: FlutterFlowTheme.of(context).primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }
} 