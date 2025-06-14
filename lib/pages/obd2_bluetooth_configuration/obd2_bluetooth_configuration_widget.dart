import 'package:o_b_d2_scanner_frontend/pages/manual_configuration/manual_configuration_model.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ),
      ),
      body: Container(),
    );
  }
}
