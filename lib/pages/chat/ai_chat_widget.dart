import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  List<Map<String, String>> messages = [];

  Future<void> sendMessage(String question) async {
    // Check if level is selected
    if (selectedLevel == null) {
      setState(() {
        messages.add({
          'role': 'ai',
          'text': 'Please select your experience level before asking a question:\n\n**BEGINNER**: New to car maintenance, prefer simple explanations and basic steps\n**EXPERT**: Experienced with automotive work, want detailed technical information',
        });
      });
      return;
    }

    setState(() {
      messages.add({'role': 'user', 'text': question});
      isAwaitingResponse = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final url = Uri.parse('http://${Config.baseUrl}/api/ask');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'question': question,
          'level': selectedLevel,
        }),
      );

      if (response.statusCode == 200) {
        final answer = jsonDecode(response.body)['answer'];
        setState(() {
          messages.add({'role': 'ai', 'text': answer});
          isAwaitingResponse = false;
        });
      } else {
        setState(() {
          messages.add({
            'role': 'ai',
            'text': '❌ Error: ${response.statusCode} ${response.reasonPhrase ?? 'Unknown error'}',
          });
          isAwaitingResponse = false;
        });
      }
    } catch (e) {
      setState(() {
        messages.add({'role': 'ai', 'text': '⚠️ Network error: $e'});
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
        border: Border.all(color: FlutterFlowTheme.of(context).primary.withOpacity(0.2)),
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

  Widget _buildBubble(Map<String, String> message) {
    final isUser = message['role'] == 'user';
    final bgColor = isUser 
        ? FlutterFlowTheme.of(context).primary 
        : FlutterFlowTheme.of(context).secondaryBackground;
    final textColor = isUser ? Colors.white : Colors.white;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: FlutterFlowTheme.of(context).primary,
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
            ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message['text'] ?? '',
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
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
            // Center — Get Pro (disabled routing)
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
                      'Get Pro',
                      style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 22.0,
                    ),
                  ],
                ),
              ),
            ),
            // Left — Back button
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  GoRouter.of(context).push('/home');
                },
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
            // Right — Menu
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
            // Chat history
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Welcome message if no level selected
                  if (selectedLevel == null)
                    _buildBubble({
                      'role': 'ai',
                      'text': 'Welcome! I\'m your automotive AI assistant. Please select your experience level below to get started.',
                    }),
                  ...messages.map(_buildBubble).toList(),
                  if (isAwaitingResponse)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                          child: AnimatedTextKit(
                            repeatForever: true,
                            animatedTexts: [
                              TyperAnimatedText('Typing...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Level selector just above input
            if (selectedLevel == null) _buildLevelSelector(),
            // Input area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: Colors.transparent,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attachment),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    onPressed: () {
                      // TODO: Add file picker logic
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          sendMessage(value.trim());
                        }
                      },
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
