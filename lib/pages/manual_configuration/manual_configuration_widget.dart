import 'package:o_b_d2_scanner_frontend/pages/manual_configuration/manual_configuration_model.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManualConfigurationWidget extends StatefulWidget {
  const ManualConfigurationWidget({super.key});

  @override
  State<ManualConfigurationWidget> createState() => _ManualConfigurationWidgetState();
}

class _ManualConfigurationWidgetState extends State<ManualConfigurationWidget> {
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
          'Manual Setup',
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
