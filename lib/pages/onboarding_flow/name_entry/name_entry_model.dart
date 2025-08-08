import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'name_entry_widget.dart' show NameEntryWidget;

class NameEntryModel extends FlutterFlowModel<NameEntryWidget> {
  // Controllers
  TextEditingController? nameTextController;

  // Focus Nodes
  FocusNode? nameFocusNode;

  // Validators
  String? Function(String?)? nameTextControllerValidator;

  @override
  void initState(BuildContext context) {
    nameTextControllerValidator = (val) {
      final v = val?.trim() ?? '';
      if (v.isEmpty) return 'Name is required';
      if (v.length < 2) return 'Name must be at least 2 characters';
      return null;
    };
  }

  @override
  void dispose() {
    nameTextController?.dispose();
    nameFocusNode?.dispose();
  }
}