import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:o_b_d2_scanner_frontend/pages/manual_configuration/manual_configuration_model.dart';
import 'package:http/http.dart' as http;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManualConfigurationWidget extends StatefulWidget {
  const ManualConfigurationWidget({super.key});

  @override
  State<ManualConfigurationWidget> createState() =>
      _ManualConfigurationWidgetState();
}

class _ManualConfigurationWidgetState
    extends State<ManualConfigurationWidget> {
  late ManualConfigurationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController vinController = TextEditingController();
  Map<String, dynamic>? vinResult;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ManualConfigurationModel());
  }

  @override
  void dispose() {
    _model.dispose();
    vinController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final vin = vinController.text.trim().toUpperCase();

    if (vin.length != 17) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('VIN must be 17 characters long')),
      );
      return;
    }

    final uri = Uri.parse('http://0.0.0.0:8080/manual?vin=$vin');

    setState(() {
      isLoading = true;
      vinResult = null;
    });

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          vinResult = data;
        });
      } else {
        final error = jsonDecode(response.body)['detail'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request failed: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: FlutterFlowTheme.of(context).primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Manual Setup',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.interTight(
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).primaryText,
              ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: true,
        child: Padding(
          padding:
              const EdgeInsetsDirectional.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: vinController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Enter VIN',
                      labelStyle: FlutterFlowTheme.of(context).labelLarge,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              FFButtonWidget(
                onPressed: isLoading ? null : _handleSubmit,
                text: isLoading ? '' : 'Add Auto',
                icon: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 50.0,
                  padding: const EdgeInsets.all(0),
                  color: Colors.black,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        font: GoogleFonts.interTight(
                          fontWeight:
                              FlutterFlowTheme.of(context).titleSmall.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).titleSmall.fontStyle,
                        ),
                        color:
                            FlutterFlowTheme.of(context).secondaryBackground,
                        letterSpacing: 0.0,
                      ),
                  elevation: 2.0,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              const SizedBox(height: 24.0),
              if (vinResult != null)
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Make: ${vinResult!['make']}',
                            style: FlutterFlowTheme.of(context).bodyLarge),
                        Text('Model: ${vinResult!['model']}',
                            style: FlutterFlowTheme.of(context).bodyLarge),
                        Text('Year: ${vinResult!['year']}',
                            style: FlutterFlowTheme.of(context).bodyLarge),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
