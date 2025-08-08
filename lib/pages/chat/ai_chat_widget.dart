import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/config.dart';
import '/services/auth_service.dart';
import '/models/chat_message.dart';
import '/models/chat_conversation.dart';
import '/services/chat_persistence_service.dart';
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
  // Suggestion prompts for new users
  final List<String> _suggestionPrompts = [
    "Why is my check engine light on?",
    "How do I clear error codes?", 
    "What does P0300 code mean?",
  ];
  ChatConversation? currentConversation;
  bool isInBulkDeleteMode = false;
  Set<String> selectedConversationsForDelete = {};
  
  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    // Don't auto-load conversations - let user access via hamburger menu
  }

  Future<void> _loadConversation(String conversationId) async {
    try {
      final conversationWithMessages = await ChatPersistenceService.getConversation(conversationId);
      setState(() {
        currentConversation = conversationWithMessages;
        if (conversationWithMessages.messages != null) {
          messages = conversationWithMessages.messages!;
        } else {
          messages = [];
        }
      });
    } catch (e) {
      print('Error loading conversation: $e');
    }
  }

  Future<void> _showConversationDrawer() async {
    try {
      final conversations = await ChatPersistenceService.getConversations();
      
      if (conversations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No conversations found. Start a new chat!')),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryText,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isInBulkDeleteMode ? 'Select Conversations' : 'Chat History',
                        style: FlutterFlowTheme.of(context).titleLarge,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (conversations.isNotEmpty && !isInBulkDeleteMode)
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'bulk_delete') {
                                  setState(() {
                                    isInBulkDeleteMode = true;
                                    selectedConversationsForDelete.clear();
                                  });
                                } else if (value == 'delete_all') {
                                  Navigator.pop(context);
                                  await _showDeleteAllConfirmation();
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'bulk_delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.checklist, color: Colors.orange),
                                      SizedBox(width: 8),
                                      Text('Bulk Delete'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete_all',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_sweep, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete All'),
                                    ],
                                  ),
                                ),
                              ],
                              child: Icon(
                                Icons.more_vert,
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                          IconButton(
                            onPressed: () {
                              if (isInBulkDeleteMode) {
                                setState(() {
                                  isInBulkDeleteMode = false;
                                  selectedConversationsForDelete.clear();
                                });
                              } else {
                                Navigator.pop(context);
                              }
                            },
                            icon: Icon(isInBulkDeleteMode ? Icons.cancel : Icons.close),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      final isSelected = currentConversation?.id == conversation.id;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
                              : FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? FlutterFlowTheme.of(context).primary
                                : FlutterFlowTheme.of(context).primaryBackground,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          onTap: () async {
                            if (isInBulkDeleteMode) {
                              setState(() {
                                if (selectedConversationsForDelete.contains(conversation.id)) {
                                  selectedConversationsForDelete.remove(conversation.id);
                                } else {
                                  selectedConversationsForDelete.add(conversation.id);
                                }
                              });
                            } else {
                              Navigator.pop(context);
                              await _loadConversation(conversation.id);
                            }
                          },
                          leading: isInBulkDeleteMode
                              ? Checkbox(
                                  value: selectedConversationsForDelete.contains(conversation.id),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedConversationsForDelete.add(conversation.id);
                                      } else {
                                        selectedConversationsForDelete.remove(conversation.id);
                                      }
                                    });
                                  },
                                  activeColor: FlutterFlowTheme.of(context).primary,
                                )
                              : CircleAvatar(
                                  backgroundColor: FlutterFlowTheme.of(context).primary,
                                  child: Icon(
                                    Icons.chat,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                          title: Text(
                            conversation.title ?? 'Untitled Chat',
                            style: FlutterFlowTheme.of(context).titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Created: ${_formatDate(conversation.createdAt)}',
                                style: FlutterFlowTheme.of(context).bodySmall,
                              ),
                            ],
                          ),
                          trailing: isInBulkDeleteMode
                              ? null
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: FlutterFlowTheme.of(context).primary,
                                        size: 20,
                                      ),
                                    const SizedBox(width: 8),
                                    PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (value == 'delete') {
                                          await _deleteConversation(conversation.id);
                                          Navigator.pop(context);
                                          _showConversationDrawer(); // Refresh the drawer
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Delete'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      child: Icon(
                                        Icons.more_vert,
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (isInBulkDeleteMode && selectedConversationsForDelete.isNotEmpty)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _bulkDeleteConversations();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Delete Selected (${selectedConversationsForDelete.length})',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      if (!isInBulkDeleteMode)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _startNewConversation();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FlutterFlowTheme.of(context).primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Start New Conversation',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading conversations: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteConversation(String conversationId) async {
    try {
      await ChatPersistenceService.deleteConversation(conversationId);
      
      // If we're deleting the current conversation, clear it
      if (currentConversation?.id == conversationId) {
        setState(() {
          currentConversation = null;
          messages = [];
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversation deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting conversation: $e')),
      );
    }
  }

  void _startNewConversation() {
    setState(() {
      currentConversation = null;
      messages = [];
    });
  }

  void _clearCurrentChat() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Current Chat'),
          content: const Text('Are you sure you want to clear the current chat? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  messages = [];
                  currentConversation = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat cleared')),
                );
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _bulkDeleteConversations() async {
    if (selectedConversationsForDelete.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Conversations'),
          content: Text(
            'Are you sure you want to delete ${selectedConversationsForDelete.length} conversation(s)? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                try {
                  // Delete each selected conversation
                  for (String conversationId in selectedConversationsForDelete) {
                    await ChatPersistenceService.deleteConversation(conversationId);
                    
                    // If we're deleting the current conversation, clear it
                    if (currentConversation?.id == conversationId) {
                      setState(() {
                        currentConversation = null;
                        messages = [];
                      });
                    }
                  }
                  
                  setState(() {
                    isInBulkDeleteMode = false;
                    selectedConversationsForDelete.clear();
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted ${selectedConversationsForDelete.length} conversations')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting conversations: $e')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteAllConfirmation() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Conversations'),
          content: const Text(
            'Are you sure you want to delete ALL conversations? This will permanently remove all your chat history and cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAllConversations();
              },
              child: const Text('Delete All', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAllConversations() async {
    try {
      final conversations = await ChatPersistenceService.getConversations();
      
      for (ChatConversation conversation in conversations) {
        await ChatPersistenceService.deleteConversation(conversation.id);
      }
      
      setState(() {
        currentConversation = null;
        messages = [];
        isInBulkDeleteMode = false;
        selectedConversationsForDelete.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All conversations deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting all conversations: $e')),
      );
    }
  }

  Future<void> _createNewConversation({String? title}) async {
    try {
      final conversation = await ChatPersistenceService.createConversation(
        title: title ?? 'Chat ${DateTime.now().day}/${DateTime.now().month}',
      );
      setState(() {
        currentConversation = conversation;
        messages = [];
      });
    } catch (e) {
      print('Error creating conversation: $e');
    }
  }

  Future<void> sendMessage(String question) async {
    // Create conversation if it doesn't exist, using the question as title
    if (currentConversation == null) {
      // Truncate question to reasonable title length
      final titleFromQuestion = question.length > 50 
          ? '${question.substring(0, 47)}...'
          : question;
      await _createNewConversation(title: titleFromQuestion);
    }

    final userMessage = ChatMessage.user(
      content: question,
      conversationId: currentConversation?.id,
    );

    setState(() {
      messages.add(userMessage);
      isAwaitingResponse = true;
    });

    // Save user message to backend
    if (currentConversation != null) {
      try {
        await ChatPersistenceService.saveMessage(
          conversationId: currentConversation!.id,
          message: userMessage,
        );
      } catch (e) {
        print('Error saving user message: $e');
      }
    }

    final authService = AuthService();
    final token = await authService.getStoredToken();
    final url = Uri.parse('${Config.baseUrl}/api/chat'); // Always use /api/chat

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': question,
          // Removed level parameter
          'context': null, // No context for regular messages
          'include_diagnostics': false,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final messageContent = responseData['message']['content'];
        final suggestions = responseData['suggestions'] as List<dynamic>?;

        final aiMessage = ChatMessage.assistant(
          content: messageContent,
          conversationId: currentConversation?.id,
          suggestions: suggestions?.cast<String>(),
        );

        setState(() {
          messages.add(aiMessage);
          isAwaitingResponse = false;
        });

        // Save AI message to backend
        if (currentConversation != null) {
          try {
            await ChatPersistenceService.saveMessage(
              conversationId: currentConversation!.id,
              message: aiMessage,
            );
          } catch (e) {
            print('Error saving AI message: $e');
          }
        }
      } else {
        print('Chat API Error - Status: ${response.statusCode}, Body: ${response.body}');
        final errorMessage = ChatMessage.assistant(
          content: '❌ Error: ${response.statusCode} ${response.reasonPhrase ?? 'Unknown error'}',
          conversationId: currentConversation?.id,
        );
        setState(() {
          messages.add(errorMessage);
          isAwaitingResponse = false;
        });
      }
    } catch (e) {
      final errorMessage = ChatMessage.assistant(
        content: '⚠️ Network error: $e',
        conversationId: currentConversation?.id,
      );
      setState(() {
        messages.add(errorMessage);
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

  Widget _buildSuggestionPrompts() {
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
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: FlutterFlowTheme.of(context).primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Try asking about:',
                style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                  color: FlutterFlowTheme.of(context).primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestionPrompts.map((prompt) => 
              InkWell(
                onTap: () => sendMessage(prompt),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        prompt,
                        style: TextStyle(
                          fontSize: 13,
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
        ],
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

  Widget _buildBubble(ChatMessage message) {
    final isUser = message.messageType == MessageType.user;
    final bgColor = isUser
        ? FlutterFlowTheme.of(context).primary
        : FlutterFlowTheme.of(context).secondaryBackground;
    final textColor = isUser ? Colors.white : Colors.white;
    final isMarkdown = message.format == 'markdown';
    final suggestions = message.suggestions;

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
                          data: message.content,
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
                          message.content,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (messages.isNotEmpty)
                    InkWell(
                      onTap: () => _clearCurrentChat(),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.delete_outline,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: () => _showConversationDrawer(),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Icons.menu,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 28.0,
                      ),
                    ),
                  ),
                ],
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
                  if (messages.isEmpty)
                    _buildBubble(ChatMessage.assistant(
                      content: 'Welcome! I\'m your automotive AI assistant. Choose a suggestion below or ask me anything about your vehicle.',
                    )),
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
            if (messages.isEmpty) _buildSuggestionPrompts(),
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
                        hintText: 'Ask me about your vehicle...',
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
