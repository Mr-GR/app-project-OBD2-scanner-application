import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'auth_login_widget.dart' show AuthLoginWidget;

class AuthLoginModel extends FlutterFlowModel<AuthLoginWidget> {
  // Controllers
  TextEditingController? emailAddressTextController;
  TextEditingController? passwordTextController;

  // Focus Nodes
  FocusNode? emailAddressFocusNode;
  FocusNode? passwordFocusNode;

  // Visibility toggle
  bool passwordVisibility = false;

  // Validators
  String? Function(String?)? emailAddressTextControllerValidator;
  String? Function(String?)? passwordTextControllerValidator;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;

    emailAddressTextControllerValidator = (val) {
      final v = val?.trim() ?? '';
      if (v.isEmpty) return 'Email is required';
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(v)) {
        return 'Enter a valid email';
      }
      return null;
    };

    passwordTextControllerValidator = (val) {
      final v = val?.trim() ?? '';
      if (v.isEmpty) return 'Password is required';
      if (v.length < 6) return 'Must be at least 6 characters';
      return null;
    };
  }

  @override
  void dispose() {
    emailAddressTextController?.dispose();
    passwordTextController?.dispose();
    emailAddressFocusNode?.dispose();
    passwordFocusNode?.dispose();
  }
}
