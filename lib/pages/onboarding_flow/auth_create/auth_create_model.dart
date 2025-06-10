import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_model.dart';

class AuthCreateModel extends FlutterFlowModel {
  // Controllers
  late final TextEditingController displayNameTextController;
  late final TextEditingController emailAddressTextController;
  late final TextEditingController passwordTextController;

  // Focus Nodes
  late final FocusNode displayNameFocusNode;
  late final FocusNode emailAddressFocusNode;
  late final FocusNode passwordFocusNode;

  // Password visibility toggle
  bool passwordVisibility = false;

  // Validators
  FormFieldValidator<String> displayNameTextControllerValidator =
      (context) => null;
  FormFieldValidator<String> emailAddressTextControllerValidator =
      (context) => null;
  FormFieldValidator<String> passwordTextControllerValidator =
      (context) => null;

  @override
  void initState(BuildContext context) {
    displayNameTextController = TextEditingController();
    emailAddressTextController = TextEditingController();
    passwordTextController = TextEditingController();

    displayNameFocusNode = FocusNode();
    emailAddressFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    displayNameTextController.dispose();
    emailAddressTextController.dispose();
    passwordTextController.dispose();

    displayNameFocusNode.dispose();
    emailAddressFocusNode.dispose();
    passwordFocusNode.dispose();
  }
}
