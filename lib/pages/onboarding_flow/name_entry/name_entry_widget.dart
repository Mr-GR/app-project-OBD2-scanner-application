import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/auth/auth_util.dart';
import 'name_entry_model.dart';

class NameEntryWidget extends StatefulWidget {
  const NameEntryWidget({super.key});

  static String routeName = 'name_entry';
  static String routePath = '/nameEntry';

  @override
  State<NameEntryWidget> createState() => _NameEntryWidgetState();
}

class _NameEntryWidgetState extends State<NameEntryWidget> {
  late NameEntryModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NameEntryModel());

    _model.nameTextController ??= TextEditingController();
    _model.nameFocusNode ??= FocusNode();
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 64),
                          // Welcome Icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Icon(
                              Icons.person_add_rounded,
                              size: 40,
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Welcome!',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).displaySmall.copyWith(
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'What should we call you?',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).headlineMedium.copyWith(
                              letterSpacing: 0.0,
                              color: FlutterFlowTheme.of(context).primaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please enter your name to personalize your experience.',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).bodyLarge.copyWith(
                              letterSpacing: 0.0,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Name Field
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 1,
                              ),
                            ),
                            child: TextFormField(
                              controller: _model.nameTextController,
                              focusNode: _model.nameFocusNode,
                              autofocus: true,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.done,
                              textCapitalization: TextCapitalization.words,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'Your Name',
                                labelStyle: FlutterFlowTheme.of(context).bodyLarge.copyWith(
                                  letterSpacing: 0.0,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                ),
                                hintText: 'Enter your first name',
                                hintStyle: FlutterFlowTheme.of(context).bodyLarge.copyWith(
                                  letterSpacing: 0.0,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  size: 24,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(20),
                              ),
                              style: FlutterFlowTheme.of(context).bodyLarge.copyWith(
                                letterSpacing: 0.0,
                              ),
                              cursorColor: FlutterFlowTheme.of(context).primary,
                              validator: _model.nameTextControllerValidator,
                            ),
                          ),
                          const SizedBox(height: 32),
                          FFButtonWidget(
                            onPressed: _isLoading ? null : _handleContinue,
                            text: _isLoading ? 'Saving...' : 'Continue',
                            icon: _isLoading ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ) : Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 56.0,
                              padding: const EdgeInsets.all(0),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context).titleMedium.copyWith(
                                color: Colors.white,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                              ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          
                          // Error Message
                          if (_errorMessage != null) ...[  
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    size: 20,
                                    color: Colors.red.shade600,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                                        color: Colors.red.shade700,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 64),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _handleContinue() async {
    final name = _model.nameTextController.text.trim();
    
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your name';
      });
      return;
    }
    
    if (name.length < 2) {
      setState(() {
        _errorMessage = 'Name must be at least 2 characters';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Save the name to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_display_name', name);
      
      setState(() {
        _isLoading = false;
      });
      
      // Navigate to home page
      if (context.mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    }
  }
}