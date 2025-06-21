import 'package:o_b_d2_scanner_frontend/index.dart';
import 'package:o_b_d2_scanner_frontend/pages/onboarding_flow/auth_create/auth_create_model.dart';
import 'package:o_b_d2_scanner_frontend/widgets/onboarding_tutorial_system.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:o_b_d2_scanner_frontend/pages/home/main_tab_scaffold.dart';
import 'package:go_router/go_router.dart';
export 'auth_create_model.dart';

class AuthCreateWidget extends StatefulWidget {
  const AuthCreateWidget({super.key});

  @override
  State<AuthCreateWidget> createState() => _AuthCreateWidgetState();
}

class _AuthCreateWidgetState extends State<AuthCreateWidget> {
  late AuthCreateModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuthCreateModel());
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
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        automaticallyImplyLeading: false,
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
            Navigator.of(context).pop();
          },
        ),
        actions: [],
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 32, 0, 8),
                  child: Text(
                    'Create an account to get started!',
                    style: FlutterFlowTheme.of(context).displayMedium.copyWith(
                          fontFamily: "Inter",
                          fontWeight: FlutterFlowTheme.of(context)
                              .displayMedium
                              .fontWeight,
                          fontStyle: FlutterFlowTheme.of(context)
                              .displayMedium
                              .fontStyle,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 12),
                  child: Text(
                    'Get answer about your vehicle quick.',
                    style: FlutterFlowTheme.of(context).labelLarge.copyWith(
                          fontFamily: "Inter",
                          fontWeight: FlutterFlowTheme.of(context)
                              .labelLarge
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).labelLarge.fontStyle,
                        ),
                  ),
                ),
                _buildTextField(
                  context,
                  label: 'Display Name',
                  controller: _model.displayNameTextController,
                  focusNode: _model.displayNameFocusNode,
                  capitalization: TextCapitalization.words,
                  validator: _model.displayNameTextControllerValidator,
                ),
                _buildTextField(
                  context,
                  label: 'Email Address',
                  controller: _model.emailAddressTextController,
                  focusNode: _model.emailAddressFocusNode,
                  capitalization: TextCapitalization.none,
                  validator: _model.emailAddressTextControllerValidator,
                ),
                _buildPasswordField(context),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      16.0, 12.0, 16.0, 24.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      if (_model.emailAddressTextController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Email and Password cannot be left blank.'),
                          ),
                        );
                        return;
                      }

                      // TODO: Implement actual account creation logic here
                      // For now, just simulate successful account creation
                      
                      // Check if user has completed onboarding
                      final isOnboardingComplete = await OnboardingTutorialSystem.isOnboardingComplete();
                      
                      if (mounted) {
                        if (isOnboardingComplete) {
                          // User has completed onboarding, go to main app
                          GoRouter.of(context).go('/home');
                        } else {
                          // New user, show onboarding first
                          GoRouter.of(context).go('/onboarding');
                        }
                      }
                    },
                    text: 'Create Account',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 60.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 0.0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primaryText,
                      textStyle:
                          FlutterFlowTheme.of(context).titleMedium.copyWith(
                                fontFamily: "Inter",
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .fontStyle,
                              ),
                      elevation: 4.0,
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(50.0),
                      hoverColor: FlutterFlowTheme.of(context).primaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required TextCapitalization capitalization,
    required FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textCapitalization: capitalization,
        obscureText: false,
        decoration: _buildInputDecoration(context, label),
        style: FlutterFlowTheme.of(context).headlineMedium,
        cursorColor: FlutterFlowTheme.of(context).primary,
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
      child: TextFormField(
        controller: _model.passwordTextController,
        focusNode: _model.passwordFocusNode,
        obscureText: !_model.passwordVisibility,
        decoration: _buildInputDecoration(context, 'Password').copyWith(
          suffixIcon: InkWell(
            onTap: () => setState(
              () => _model.passwordVisibility = !_model.passwordVisibility,
            ),
            child: Icon(
              _model.passwordVisibility
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
        ),
        style: FlutterFlowTheme.of(context).headlineMedium,
        cursorColor: FlutterFlowTheme.of(context).primary,
        validator: _model.passwordTextControllerValidator,
      ),
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: FlutterFlowTheme.of(context).labelLarge,
      errorStyle: FlutterFlowTheme.of(context).labelMedium.copyWith(
            color: FlutterFlowTheme.of(context).error,
            height: 1.5,
          ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).alternate,
          width: 2,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).primary,
          width: 2,
        ),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).error,
          width: 2,
        ),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).error,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: FlutterFlowTheme.of(context).secondaryBackground,
      contentPadding: const EdgeInsetsDirectional.fromSTEB(0, 16, 16, 8),
    );
  }
}
