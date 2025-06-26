import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/config.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class AiChatWidget extends StatefulWidget {
  const AiChatWidget({super.key});

  static String routeName = 'AiChat';
  static String routePath = '/ai_chat';

  @override
  State<AiChatWidget> createState() => _AiChatWidgetState();
}

class _AiChatWidgetState extends State<AiChatWidget> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isAwaitingResponse = false;
  String? selectedLevel; // 'beginner' or 'expert'

  List<Map<String, dynamic>> messages = [];

  Future<void> sendMessage(String question) async {
    if (selectedLevel == null) {
      setState(() {
        messages.add({
          'role': 'ai',
          'text': 'Please select your experience level before asking a question.',
          'format': 'markdown',
        });
      });
      return;
    }

    setState(() {
      messages.add({
        'role': 'user',
        'text': question,
        'format': 'plain',
      });
      isAwaitingResponse = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final url = Uri.parse('http://${Config.baseUrl}/api/chat'); // Always use /api/chat

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': question,
          'level': selectedLevel,
          'context': null, // No context for regular messages
          'include_diagnostics': false,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final messageContent = responseData['message']['content'];
        final suggestions = responseData['suggestions'] as List<dynamic>?;

        setState(() {
          messages.add({
            'role': 'ai',
            'text': messageContent,
            'format': 'markdown',
            'suggestions': suggestions,
          });
          isAwaitingResponse = false;
        });
      } else {
        setState(() {
          messages.add({
            'role': 'ai',
            'text': '❌ Error: ${response.statusCode} ${response.reasonPhrase ?? 'Unknown error'}',
            'format': 'plain',
          });
          isAwaitingResponse = false;
        });
      }
    } catch (e) {
      setState(() {
        messages.add({
          'role': 'ai',
          'text': '⚠️ Network error: $e',
          'format': 'plain',
        });
        isAwaitingResponse = false;
      });
    }

    _controller.clear();

    await Future.delayed(const Duration(milliseconds: 200));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _buildLevelSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Your Experience Level',
            style: FlutterFlowTheme.of(context).titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLevelButton('beginner', 'BEGINNER', Icons.school),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLevelButton('expert', 'EXPERT', Icons.engineering),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelButton(String level, String label, IconData icon) {
    final isSelected = selectedLevel == level;
    return InkWell(
      onTap: () {
        setState(() {
          selectedLevel = level;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? FlutterFlowTheme.of(context).primary
              : FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).primary.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : FlutterFlowTheme.of(context).primary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                color: isSelected
                    ? Colors.white
                    : FlutterFlowTheme.of(context).primary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(List<dynamic> suggestions) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: suggestions.map((suggestion) =>
          InkWell(
            onTap: () => sendMessage(suggestion),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 14,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 12,
                      color: FlutterFlowTheme.of(context).primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> message) {
    final isUser = message['role'] == 'user';
    final bgColor = isUser
        ? FlutterFlowTheme.of(context).primary
        : FlutterFlowTheme.of(context).secondaryBackground;
    final textColor = isUser ? Colors.white : Colors.white;
    final isMarkdown = message['format'] == 'markdown';
    final suggestions = message['suggestions'] as List<dynamic>?;

    return Column(
      children: [
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 4.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
                  ),
                ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(16),
                  constraints: BoxConstraints(
                    maxWidth: isUser
                        ? MediaQuery.of(context).size.width * 0.8
                        : MediaQuery.of(context).size.width * 0.85,
                    minWidth: 100,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isUser ? 20 : 4),
                      topRight: Radius.circular(isUser ? 4 : 20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isMarkdown && !isUser
                      ? MarkdownBody(
                          data: message['text'] ?? '',
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(color: textColor, fontSize: 15, height: 1.4),
                            h1: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                            h2: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
                            h3: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2),
                            listBullet: TextStyle(color: textColor, fontSize: 15),
                            strong: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                            em: TextStyle(color: textColor, fontStyle: FontStyle.italic),
                            code: TextStyle(
                              color: Colors.orange[300],
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              fontFamily: 'monospace',
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      : SelectableText(
                          message['text'] ?? '',
                          style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
                        ),
                ),
              ),
              if (isUser) const SizedBox(width: 8),
            ],
          ),
        ),
        // Show suggestions if available
        if (suggestions != null && suggestions.isNotEmpty && !isUser)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 40.0, top: 8.0),
              child: _buildSuggestions(suggestions),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'AI Chat',
                      style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chat,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 22.0,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => GoRouter.of(context).push('/home'),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 24.0,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => scaffoldKey.currentState?.openDrawer(),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.menu,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 28.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  if (selectedLevel == null)
                    _buildBubble({
                      'role': 'ai',
                      'text': 'Welcome! I\'m your automotive AI assistant. Please select your experience level below to get started.',
                      'format': 'plain',
                    }),
                  ...messages.map(_buildBubble).toList(),
                  if (isAwaitingResponse)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: FlutterFlowTheme.of(context).primary,
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: SizedBox(
                              width: 60,
                              child: DefaultTextStyle(
                                style: const TextStyle(fontSize: 16.0, color: Colors.white),
                                child: AnimatedTextKit(
                                  repeatForever: true,
                                  animatedTexts: [
                                    TyperAnimatedText('●●●', speed: const Duration(milliseconds: 200)),
                                    TyperAnimatedText('○●●', speed: const Duration(milliseconds: 200)),
                                    TyperAnimatedText('○○●', speed: const Duration(milliseconds: 200)),
                                    TyperAnimatedText('○○○', speed: const Duration(milliseconds: 200)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (selectedLevel == null) _buildLevelSelector(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: Colors.transparent,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attachment),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    onPressed: () {
                      // TODO: Add diagnostic context picker
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: selectedLevel == null
                            ? 'Select your level first...'
                            : 'Ask me about your vehicle...',
                        filled: true,
                        fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    icon: const Icon(Icons.mic),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    onPressed: () {
                      // TODO: Add mic input logic
                    },
                  ),
                  const SizedBox(width: 5),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          FlutterFlowTheme.of(context).primary,
                          FlutterFlowTheme.of(context).secondary,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                      onTap: () {
                        final question = _controller.text.trim();
                        if (question.isNotEmpty) {
                          sendMessage(question);
                        }
                      },
                      borderRadius: BorderRadius.circular(100),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
