import 'package:flutter/material.dart';
=======
import '../../flutter_flow/flutter_flow_theme.dart';

class Obd2BluetoothConfigurationWidget extends StatelessWidget {
  const Obd2BluetoothConfigurationWidget({Key? key}) : super(key: key);
>>>>>>> f478dc7 (Update all files to ensure clean structure)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        title: Text('OBD2 Bluetooth Configuration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OBD2 Bluetooth Configuration (UI template)', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 16),
            Text('This is a placeholder for OBD2 Bluetooth configuration.'),
          ],
=======
>>>>>>> f478dc7 (Update all files to ensure clean structure)
        ),
      ),
    );
  }
}
