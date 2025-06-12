import '/flutter_flow/flutter_flow_util.dart';
import 'auth_forgot_password_widget.dart' show AuthForgotPasswordWidget;
import 'package:flutter/material.dart';

class AuthForgotPasswordModel
    extends FlutterFlowModel<AuthForgotPasswordWidget> {
  /// State fields for stateful widgets in this page.

  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(String?)? emailAddressTextControllerValidator;

  @override
  void initState(BuildContext context) {
    emailAddressTextControllerValidator = (val) {
      final v = val?.trim() ?? '';
      if (v.isEmpty) {
        return 'Email is required';
      }
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(v)) {
        return 'Enter a valid email';
      }
      return null;
    };
  }

  @override
  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();
  }
}
