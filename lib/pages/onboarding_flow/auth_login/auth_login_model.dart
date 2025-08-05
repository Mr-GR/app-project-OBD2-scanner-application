import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'auth_login_widget.dart' show AuthLoginWidget;

class AuthLoginModel extends FlutterFlowModel<AuthLoginWidget> {
  // Controllers
  TextEditingController? emailAddressTextController;

  // Focus Nodes
  FocusNode? emailAddressFocusNode;

  // Validators
  String? Function(String?)? emailAddressTextControllerValidator;

  @override
  void initState(BuildContext context) {
    emailAddressTextControllerValidator = (val) {
      final v = val?.trim() ?? '';
      if (v.isEmpty) return 'Email is required';
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(v)) {
        return 'Enter a valid email';
      }
      return null;
    };
  }

  @override
  void dispose() {
    emailAddressTextController?.dispose();
    emailAddressFocusNode?.dispose();
  }
}
