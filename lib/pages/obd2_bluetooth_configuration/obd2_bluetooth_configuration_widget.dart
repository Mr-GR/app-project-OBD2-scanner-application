import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:google_fonts/google_fonts.dart';

class Obd2BluetoothConfigurationWidget extends StatefulWidget {
  const Obd2BluetoothConfigurationWidget({super.key});

  @override
  State<Obd2BluetoothConfigurationWidget> createState() => _Obd2BluetoothConfigurationWidgetState();
}

class _Obd2BluetoothConfigurationWidgetState extends State<Obd2BluetoothConfigurationWidget> {
  late ManualConfigurationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ManualConfigurationModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
=======
import '../../flutter_flow/flutter_flow_theme.dart';

class Obd2BluetoothConfigurationWidget extends StatelessWidget {
  const Obd2BluetoothConfigurationWidget({Key? key}) : super(key: key);
>>>>>>> f478dc7 (Update all files to ensure clean structure)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: false,
        title: Text(
          'OBD2 Scanner Bluetooth',
          style: FlutterFlowTheme.of(context).displaySmall.override(
                font: GoogleFonts.interTight(
                  fontWeight:
                      FlutterFlowTheme.of(context).displaySmall.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).displaySmall.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).primaryText,
                letterSpacing: 0.0,
                fontWeight:
                    FlutterFlowTheme.of(context).displaySmall.fontWeight,
                fontStyle:
                    FlutterFlowTheme.of(context).displaySmall.fontStyle,
              ),
=======
      appBar: AppBar(
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
>>>>>>> f478dc7 (Update all files to ensure clean structure)
        ),
      ),
    );
  }
}
