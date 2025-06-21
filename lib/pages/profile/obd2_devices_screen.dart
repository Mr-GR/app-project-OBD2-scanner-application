import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';

class OBD2DevicesScreen extends StatefulWidget {
  const OBD2DevicesScreen({super.key});

  @override
  State<OBD2DevicesScreen> createState() => _OBD2DevicesScreenState();
}

class _OBD2DevicesScreenState extends State<OBD2DevicesScreen> {
  List<Map<String, String>> devices = [
    {'name': 'BlueDriver', 'id': 'A1:B2:C3:D4:E5:F6'},
    {'name': 'OBDLink MX+', 'id': '11:22:33:44:55:66'},
  ];

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
          'OBD2 Devices',
          style: FlutterFlowTheme.of(context).titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: FlutterFlowTheme.of(context).alternate,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.bluetooth, color: FlutterFlowTheme.of(context).primary, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device['name']!,
                        style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        device['id']!,
                        style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: FlutterFlowTheme.of(context).secondaryText),
                  onSelected: (value) {
                    if (value == 'rename') _renameDevice(index);
                    if (value == 'remove') _removeDevice(index);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'rename',
                      child: Text('Rename'),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        foregroundColor: Colors.white,
        onPressed: _addDevice,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addDevice() {
    setState(() {
      devices.add({'name': 'New Device', 'id': 'XX:XX:XX:XX:XX:XX'});
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device added (mock)!')),
    );
  }

  void _removeDevice(int index) {
    setState(() {
      devices.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device removed (mock)!')),
    );
  }

  void _renameDevice(int index) async {
    final controller = TextEditingController(text: devices[index]['name']);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Device'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Device Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        devices[index]['name'] = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device renamed (mock)!')),
      );
    }
  }
} 