import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/models/chat_message.dart';
import 'ai_chat_component_model.dart';

class AiChatComponentWidget extends StatefulWidget {
  const AiChatComponentWidget({super.key});

  @override
  State<AiChatComponentWidget> createState() => _AiChatComponentWidgetState();
}

class _AiChatComponentWidgetState extends State<AiChatComponentWidget> {
  late AiChatComponentModel _model;

  @override
  void initState() {
    super.initState();
    _model = AiChatComponentModel();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                                                            children: [
                                                              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.build,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                                                                            Text(
                  'AI Mechanic Assistant',
                  style: FlutterFlowTheme.of(context).titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
            const SizedBox(height: 20),
            Expanded(
              child: _model.chatHistory.isEmpty
                  ? _buildEmptyState()
                  : _buildChatList(),
            ),
            const SizedBox(height: 16),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.build,
              size: 40,
              color: FlutterFlowTheme.of(context).primary,
            ),
          ),
          const SizedBox(height: 24),
                                                                  Text(
            'AI Mechanic Assistant',
            style: FlutterFlowTheme.of(context).headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'I can help you with car diagnostics, repairs, and maintenance. Ask me anything about your vehicle!',
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
                                                      ),
                                                  ],
                                                ),
                                              );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _model.listViewController,
      itemCount: _model.chatHistory.length,
      itemBuilder: (context, index) {
        final message = _model.chatHistory[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.type == MessageType.user;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.build,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser 
                    ? FlutterFlowTheme.of(context).primary
                    : FlutterFlowTheme.of(context).tertiaryBackground,
                borderRadius: BorderRadius.circular(20),
                border: !isUser ? Border.all(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 1,
                ) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
              child: Text(
                message.content,
                style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                  color: isUser ? Colors.white : FlutterFlowTheme.of(context).primaryText,
                            ),
                          ),
                        ),
                      ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).accent1,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.person,
                color: FlutterFlowTheme.of(context).primaryText,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _model.textController,
              onChanged: (value) => _model.inputContent = value,
              style: FlutterFlowTheme.of(context).bodyMedium,
              decoration: InputDecoration(
                hintText: 'Ask about your car...',
                hintStyle: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _model.inputContent.trim().isEmpty
                  ? FlutterFlowTheme.of(context).secondaryText
                  : FlutterFlowTheme.of(context).primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _model.inputContent.trim().isEmpty ? null : () => _model.sendMessage(),
              icon: Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
