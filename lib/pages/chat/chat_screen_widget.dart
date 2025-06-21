import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../backend/providers/chat_provider.dart';
import '../../backend/providers/vehicle_provider.dart';
import '../../backend/api_requests/chatgpt_api_service.dart';
import '../../backend/models/chat_session.dart';
import '../../flutter_flow/flutter_flow_theme.dart';

class ChatScreenWidget extends StatefulWidget {
  final String? vehicleVin;
  final String? chatSessionId;
  final String? initialTitle;
  final String? initialMessage;
  
  const ChatScreenWidget({
    Key? key,
    this.vehicleVin,
    this.chatSessionId,
    this.initialTitle,
    this.initialMessage,
  }) : super(key: key);

  @override
  State<ChatScreenWidget> createState() => _ChatScreenWidgetState();
}

class _ChatScreenWidgetState extends State<ChatScreenWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    final chatProvider = context.read<ChatProvider>();
    final vehicleProvider = context.read<VehicleProvider>();
    
    await chatProvider.initialize();
    await vehicleProvider.initialize();

    // Set vehicle context if provided
    if (widget.vehicleVin != null) {
      final vehicle = vehicleProvider.getVehicleByVin(widget.vehicleVin!);
      if (vehicle != null) {
        final vehicleInfo = '${vehicle.year} ${vehicle.make} ${vehicle.model} (VIN: ${vehicle.vin})';
        chatProvider.setVehicleContext(
          widget.vehicleVin,
          widget.chatSessionId,
          widget.initialTitle ?? 'Chat about ${vehicle.nickname ?? vehicleInfo}',
        );
        chatProvider.addVehicleSystemMessage(vehicleInfo);
      }
    } else if (widget.chatSessionId != null) {
      // Load existing chat session
      await chatProvider.loadChatSession(widget.chatSessionId!, vehicleProvider);
    }

    // Send initial message if provided
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        chatProvider.sendMessage(widget.initialMessage!);
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<ChatProvider>().sendMessage(message);
      _messageController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  Future<void> _saveChatSession() async {
    final chatProvider = context.read<ChatProvider>();
    final vehicleProvider = context.read<VehicleProvider>();
    
    await chatProvider.saveChatSession(vehicleProvider);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat session saved'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      drawer: _buildChatDrawer(),
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return Text(
              chatProvider.chatTitle,
              style: FlutterFlowTheme.of(context).headlineMedium.copyWith(
                    fontFamily: 'Outfit',
                    color: Colors.white,
                    fontSize: 20,
                  ),
            );
          },
        ),
        actions: [
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (chatProvider.currentVehicleVin != null) {
                return IconButton(
                  icon: const Icon(Icons.save, color: Colors.white),
                  onPressed: chatProvider.conversationHistory.isNotEmpty 
                      ? _saveChatSession 
                      : null,
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
        centerTitle: false,
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildChatMessages(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatMessages() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.conversationHistory.isEmpty) {
          return _buildWelcomeMessage();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: chatProvider.conversationHistory.length,
          itemBuilder: (context, index) {
            final message = chatProvider.conversationHistory[index];
            if (message.role == 'system') return const SizedBox.shrink();
            
            return _buildMessageBubble(message, index);
          },
        );
      },
    );
  }

  Widget _buildWelcomeMessage() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        String welcomeMessage = 'Welcome to AI Assistant';
        String subtitle = 'Ask me anything about OBD2, car diagnostics, or any other topic!';
        
        if (chatProvider.currentVehicleVin != null) {
          welcomeMessage = 'Vehicle Diagnostic Assistant';
          subtitle = 'I can help you with diagnostics for your vehicle. Ask me about error codes, maintenance, or any car-related questions!';
        }
        
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                chatProvider.currentVehicleVin != null 
                    ? FontAwesomeIcons.car 
                    : FontAwesomeIcons.robot,
                size: 64,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              const SizedBox(height: 16),
              Text(
                welcomeMessage,
                style: FlutterFlowTheme.of(context).headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: FlutterFlowTheme.of(context).bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isUser = message.role == 'user';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              child: Icon(
                FontAwesomeIcons.robot,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? FlutterFlowTheme.of(context).primary
                    : FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                      color: isUser ? Colors.white : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                      color: isUser 
                          ? Colors.white.withValues(alpha: 0.7)
                          : FlutterFlowTheme.of(context).secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: FlutterFlowTheme.of(context).secondary,
              child: Icon(
                FontAwesomeIcons.user,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
      begin: isUser ? 0.3 : -0.3,
      duration: 300.ms,
    );
  }

  Widget _buildMessageInput() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            border: Border(
              top: BorderSide(
                color: FlutterFlowTheme.of(context).alternate,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              if (chatProvider.status == ChatStatus.error)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          chatProvider.errorMessage,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      icon: chatProvider.status == ChatStatus.loading ||
                             chatProvider.status == ChatStatus.streaming
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                      onPressed: chatProvider.status == ChatStatus.loading ||
                                chatProvider.status == ChatStatus.streaming
                          ? null
                          : _sendMessage,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildChatDrawer() {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: _buildPreviousChatsList(),
          ),
          _buildDrawerFooter(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FlutterFlowTheme.of(context).primary,
            FlutterFlowTheme.of(context).primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chat,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Chat History',
                  style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Previous conversations',
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousChatsList() {
    // Use the same mock data as in the welcome screen
    final mockChats = [
      ChatSession(
        id: '1',
        vehicleVin: 'MOCKVIN123',
        sessionDate: DateTime.now().subtract(const Duration(days: 1)),
        title: 'Check Engine Light',
        messages: [
          ChatMessage(role: 'user', content: 'Why is my check engine light on?', timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2))),
          ChatMessage(role: 'assistant', content: 'It could be many things. Do you have a code?', timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2, minutes: 5))),
        ],
        summary: 'Discussed check engine light causes.',
        metadata: null,
      ),
      ChatSession(
        id: '2',
        vehicleVin: 'MOCKVIN456',
        sessionDate: DateTime.now().subtract(const Duration(days: 2)),
        title: 'Oil Change Advice',
        messages: [
          ChatMessage(role: 'user', content: 'When should I change my oil?', timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 1))),
          ChatMessage(role: 'assistant', content: 'Every 5,000 miles or 6 months is typical.', timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 1, minutes: 10))),
        ],
        summary: 'Oil change interval advice.',
        metadata: null,
      ),
      ChatSession(
        id: '3',
        vehicleVin: 'MOCKVIN789',
        sessionDate: DateTime.now().subtract(const Duration(days: 3)),
        title: 'OBD2 Code P0420',
        messages: [
          ChatMessage(role: 'user', content: 'What does code P0420 mean?', timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 3))),
          ChatMessage(role: 'assistant', content: 'P0420 means Catalyst System Efficiency Below Threshold.', timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 3, minutes: 7))),
        ],
        summary: 'Explained OBD2 code P0420.',
        metadata: null,
      ),
      ChatSession(
        id: '4',
        vehicleVin: 'MOCKVIN123',
        sessionDate: DateTime.now().subtract(const Duration(days: 4)),
        title: 'Brake System Check',
        messages: [
          ChatMessage(role: 'user', content: 'How do I check my brake fluid?', timestamp: DateTime.now().subtract(const Duration(days: 4, hours: 2))),
          ChatMessage(role: 'assistant', content: 'Check the brake fluid reservoir under the hood.', timestamp: DateTime.now().subtract(const Duration(days: 4, hours: 2, minutes: 3))),
        ],
        summary: 'Brake fluid maintenance advice.',
        metadata: null,
      ),
      ChatSession(
        id: '5',
        vehicleVin: 'MOCKVIN456',
        sessionDate: DateTime.now().subtract(const Duration(days: 5)),
        title: 'Tire Pressure',
        messages: [
          ChatMessage(role: 'user', content: 'What should my tire pressure be?', timestamp: DateTime.now().subtract(const Duration(days: 5, hours: 1))),
          ChatMessage(role: 'assistant', content: 'Check the sticker on your driver door jamb.', timestamp: DateTime.now().subtract(const Duration(days: 5, hours: 1, minutes: 8))),
        ],
        summary: 'Tire pressure guidance.',
        metadata: null,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: mockChats.length,
      itemBuilder: (context, index) {
        final chat = mockChats[index];
        return _buildDrawerChatTile(chat);
      },
    );
  }

  Widget _buildDrawerChatTile(ChatSession chat) {
    final isCurrentChat = chat.id == context.read<ChatProvider>().currentChatSessionId;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentChat 
            ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1)
            : FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentChat 
              ? FlutterFlowTheme.of(context).primary
              : FlutterFlowTheme.of(context).alternate,
          width: isCurrentChat ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isCurrentChat 
                ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.2)
                : FlutterFlowTheme.of(context).secondaryText.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            chat.vehicleVin.isNotEmpty ? FontAwesomeIcons.car : FontAwesomeIcons.robot,
            color: isCurrentChat 
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).secondaryText,
            size: 14,
          ),
        ),
        title: Text(
          chat.title,
          style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
            fontWeight: isCurrentChat ? FontWeight.bold : FontWeight.w500,
            color: isCurrentChat 
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).primaryText,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chat.vehicleVin.isNotEmpty)
              Text(
                'Vehicle: ${chat.vehicleVin}',
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
              ),
            Text(
              _formatTimestamp(chat.lastMessageTime),
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                color: FlutterFlowTheme.of(context).secondaryText,
                fontSize: 10,
              ),
            ),
          ],
        ),
        trailing: isCurrentChat 
            ? Icon(
                Icons.check_circle,
                color: FlutterFlowTheme.of(context).primary,
                size: 16,
              )
            : null,
        onTap: () {
          Navigator.pop(context); // Close drawer
          _loadChatSession(chat);
        },
      ),
    );
  }

  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        border: Border(
          top: BorderSide(
            color: FlutterFlowTheme.of(context).alternate,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Close drawer
                _startNewChat();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Swipe from left edge or tap menu to open',
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
              color: FlutterFlowTheme.of(context).secondaryText,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _loadChatSession(ChatSession chat) {
    final chatProvider = context.read<ChatProvider>();
    
    // Load the chat session
    chatProvider.setVehicleContext(
      chat.vehicleVin,
      chat.id,
      chat.title,
    );
    
    // Load messages
    chatProvider.loadChatSession(chat.id, context.read<VehicleProvider>());
  }

  void _startNewChat() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.clearConversation();
  }
} 