import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:go_router/go_router.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/home/home_page/home_page_widget.dart';
import '/auth/auth_util.dart';
import 'auth_login_model.dart';

class AuthLoginWidget extends StatefulWidget {
  const AuthLoginWidget({super.key});

  static String routeName = 'auth_Login';
  static String routePath = '/authLogin';

  @override
  State<AuthLoginWidget> createState() => _AuthLoginWidgetState();
}

class _AuthLoginWidgetState extends State<AuthLoginWidget> {
  late AuthLoginModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuthLoginModel());

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() {
          _isKeyboardVisible = visible;
        });
      });
    }

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    if (!isWeb) {
      _keyboardVisibilitySubscription.cancel();
    }
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
        elevation: 0,
      ),
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
                          // Magic Link Icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Icon(
                              Icons.mail_outline_rounded,
                              size: 40,
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Welcome back',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).displaySmall.copyWith(
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Enter your email and we\'ll send you a secure magic link to access your account instantly.',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).bodyLarge.copyWith(
                              letterSpacing: 0.0,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Email Field
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
                              controller: _model.emailAddressTextController,
                              focusNode: _model.emailAddressFocusNode,
                              autofocus: true,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                labelStyle: FlutterFlowTheme.of(context).bodyLarge.copyWith(
                                  letterSpacing: 0.0,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                ),
                                hintText: 'Enter your email address',
                                hintStyle: FlutterFlowTheme.of(context).bodyLarge.copyWith(
                                  letterSpacing: 0.0,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
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
                              validator: _model.emailAddressTextControllerValidator,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FFButtonWidget(
                            onPressed: _isLoading ? null : _handleLogin,
                            text: _isLoading ? 'Sending Magic Link...' : 'Send Magic Link',
                            icon: _isLoading ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ) : Icon(
                              Icons.send_rounded,
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
                          
                          // Error/Success Messages
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
                          
                          if (_successMessage != null) ...[  
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.mark_email_read_rounded,
                                    size: 32,
                                    color: Colors.green.shade600,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Check your email!',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                                      color: Colors.green.shade700,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'We\'ve sent a secure magic link to your email. Click the link to sign in instantly.',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                                      color: Colors.green.shade600,
                                      letterSpacing: 0.0,
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
  
  Future<void> _handleLogin() async {
    final email = _model.emailAddressTextController.text.trim();
    
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address';
        _successMessage = null;
      });
      return;
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
        _successMessage = null;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    try {
      final result = await AuthUtil.sendMagicLink(email);
      
      setState(() {
        _isLoading = false;
        if (result.success) {
          _successMessage = result.message;
          _errorMessage = null;
        } else {
          _errorMessage = result.message;
          _successMessage = null;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred. Please try again.';
        _successMessage = null;
      });
    }
  }
}
