import '/components/chat_component/writing_indicator/writing_indicator_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/models/chat_message.dart';
import '/services/chat_service.dart';
import 'ai_chat_component_widget.dart' show AiChatComponentWidget;
import 'package:flutter/material.dart';

class AiChatComponentModel extends FlutterFlowModel<AiChatComponentWidget> {
  ///  Local state fields for this component.

  List<ChatMessage> chatHistory = [];
  bool aiResponding = false;
  String inputContent = '';
  UserLevel? selectedLevel;
  bool showLevelSelector = true;

  ///  State fields for stateful widgets in this component.

  // State field(s) for ListView widget.
  ScrollController? listViewController;
  // Model for writingIndicator component.
  late WritingIndicatorModel writingIndicatorModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {
    listViewController = ScrollController();
    writingIndicatorModel = createModel(context, () => WritingIndicatorModel());
    textController = TextEditingController();
    textFieldFocusNode = FocusNode();
    
    // Start with empty chat history - will show empty state
  }

  @override
  void dispose() {
    listViewController?.dispose();
    writingIndicatorModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }

  Future<void> sendMessage() async {
    if (inputContent.trim().isEmpty) return;
    
    final userMessage = ChatMessage.user(
      content: inputContent,
      userLevel: selectedLevel,
    );
    
    chatHistory.add(userMessage);
    final currentInput = inputContent;
    inputContent = '';
    textController?.clear();
    aiResponding = true;
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      listViewController?.animateTo(
        listViewController!.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    try {
      final response = await ChatService.askQuestion(
        question: currentInput,
        level: selectedLevel?.name ?? 'beginner',
      );
      
      final aiMessage = ChatMessage.ai(content: response.answer);
      chatHistory.add(aiMessage);
      
      // If this was the first message, hide level selector
      if (showLevelSelector) {
        showLevelSelector = false;
      }
    } catch (e) {
      final errorMessage = ChatMessage.ai(
        content: "Sorry, I'm having trouble connecting right now. Please try again later.",
      );
      chatHistory.add(errorMessage);
    } finally {
      aiResponding = false;
      
      // Scroll to bottom after response
      WidgetsBinding.instance.addPostFrameCallback((_) {
        listViewController?.animateTo(
          listViewController!.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void selectLevel(UserLevel level) {
    selectedLevel = level;
    showLevelSelector = false;
  }
}
