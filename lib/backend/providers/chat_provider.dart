import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_requests/chatgpt_api_service.dart';
import '../providers/vehicle_provider.dart';
import '../models/chat_session.dart';

enum ChatStatus {
  idle,
  loading,
  streaming,
  error,
}

class ChatProvider extends ChangeNotifier {
  final ChatGPTApiService _apiService = ChatGPTApiService();
  
  List<ChatMessage> _conversationHistory = [];
  ChatStatus _status = ChatStatus.idle;
  String _errorMessage = '';
  String _currentStreamingMessage = '';
  bool _isStreaming = false;
  
  // Vehicle context
  String? _currentVehicleVin;
  String? _currentChatSessionId;
  String _chatTitle = 'New Chat';
  
  // Settings
  String _selectedModel = 'gpt-3.5-turbo';
  double _temperature = 0.7;
  int _maxTokens = 1000;
  bool _useStreaming = true;

  // Getters
  List<ChatMessage> get conversationHistory => _conversationHistory;
  ChatStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get currentStreamingMessage => _currentStreamingMessage;
  bool get isStreaming => _isStreaming;
  String get selectedModel => _selectedModel;
  double get temperature => _temperature;
  int get maxTokens => _maxTokens;
  bool get useStreaming => _useStreaming;
  String? get currentVehicleVin => _currentVehicleVin;
  String? get currentChatSessionId => _currentChatSessionId;
  String get chatTitle => _chatTitle;

  // Initialize the provider
  Future<void> initialize() async {
    await _apiService.initialize();
    await _loadConversationHistory();
    await _loadSettings();
  }

  // Set vehicle context for chat
  void setVehicleContext(String? vehicleVin, String? sessionId, String title) {
    _currentVehicleVin = vehicleVin;
    _currentChatSessionId = sessionId;
    _chatTitle = title;
    notifyListeners();
  }

  // Load existing chat session
  Future<void> loadChatSession(String sessionId, VehicleProvider vehicleProvider) async {
    final session = vehicleProvider.chatSessions
        .where((s) => s.id == sessionId)
        .firstOrNull;
    
    if (session != null) {
      _conversationHistory = List.from(session.messages);
      _currentVehicleVin = session.vehicleVin;
      _currentChatSessionId = session.id;
      _chatTitle = session.title;
      notifyListeners();
    }
  }

  // Send a message to ChatGPT
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message to conversation
    final userMessage = ChatMessage(
      role: 'user',
      content: message.trim(),
    );
    _conversationHistory.add(userMessage);
    notifyListeners();

    // Set loading status
    _setStatus(ChatStatus.loading);
    _errorMessage = '';

    try {
      if (_useStreaming) {
        await _sendMessageStream(message);
      } else {
        await _sendMessageRegular(message);
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> _sendMessageRegular(String message) async {
    final response = await _apiService.sendMessage(
      message: message,
      conversationHistory: _conversationHistory,
      model: _selectedModel,
      temperature: _temperature,
      maxTokens: _maxTokens,
    );

    // Add assistant response to conversation
    final assistantMessage = ChatMessage(
      role: 'assistant',
      content: response.content,
    );
    _conversationHistory.add(assistantMessage);
    
    _setStatus(ChatStatus.idle);
    await _saveConversationHistory();
  }

  Future<void> _sendMessageStream(String message) async {
    _isStreaming = true;
    _currentStreamingMessage = '';
    _setStatus(ChatStatus.streaming);

    final assistantMessage = ChatMessage(
      role: 'assistant',
      content: '',
    );
    _conversationHistory.add(assistantMessage);

    try {
      await for (final streamResponse in _apiService.sendMessageStream(
        message: message,
        conversationHistory: _conversationHistory,
        model: _selectedModel,
        temperature: _temperature,
        maxTokens: _maxTokens,
      )) {
        if (streamResponse.isDone) {
          break;
        }

        if (streamResponse.content != null) {
          _currentStreamingMessage += streamResponse.content!;
          // Create a new message with updated content
          final updatedMessage = ChatMessage(
            role: 'assistant',
            content: _currentStreamingMessage,
            timestamp: assistantMessage.timestamp,
          );
          // Replace the message in the list
          final index = _conversationHistory.indexOf(assistantMessage);
          if (index != -1) {
            _conversationHistory[index] = updatedMessage;
          }
          notifyListeners();
        }
      }

      _isStreaming = false;
      _currentStreamingMessage = '';
      _setStatus(ChatStatus.idle);
      await _saveConversationHistory();
    } catch (e) {
      _isStreaming = false;
      _currentStreamingMessage = '';
      _setError(e.toString());
    }
  }

  // Save chat session to vehicle provider
  Future<void> saveChatSession(VehicleProvider vehicleProvider) async {
    if (_currentVehicleVin != null && _conversationHistory.isNotEmpty) {
      // Generate title from first user message if not set
      String title = _chatTitle;
      if (title == 'New Chat' && _conversationHistory.isNotEmpty) {
        final firstUserMessage = _conversationHistory
            .where((msg) => msg.role == 'user')
            .firstOrNull;
        if (firstUserMessage != null) {
          title = firstUserMessage.content.length > 30
              ? '${firstUserMessage.content.substring(0, 30)}...'
              : firstUserMessage.content;
        }
      }

      // Generate summary from assistant messages
      String? summary;
      final assistantMessages = _conversationHistory
          .where((msg) => msg.role == 'assistant')
          .toList();
      if (assistantMessages.isNotEmpty) {
        final lastAssistantMessage = assistantMessages.last;
        summary = lastAssistantMessage.content.length > 100
            ? '${lastAssistantMessage.content.substring(0, 100)}...'
            : lastAssistantMessage.content;
      }

      await vehicleProvider.addChatSession(
        vehicleVin: _currentVehicleVin!,
        title: title,
        messages: List.from(_conversationHistory),
        summary: summary,
        metadata: {
          'model': _selectedModel,
          'temperature': _temperature,
          'maxTokens': _maxTokens,
        },
      );
    }
  }

  // Clear conversation
  Future<void> clearConversation() async {
    _conversationHistory.clear();
    _currentStreamingMessage = '';
    _setStatus(ChatStatus.idle);
    _errorMessage = '';
    _currentChatSessionId = null;
    _chatTitle = 'New Chat';
    await _saveConversationHistory();
  }

  // Update settings
  Future<void> updateSettings({
    String? model,
    double? temperature,
    int? maxTokens,
    bool? useStreaming,
  }) async {
    if (model != null) _selectedModel = model;
    if (temperature != null) _temperature = temperature;
    if (maxTokens != null) _maxTokens = maxTokens;
    if (useStreaming != null) _useStreaming = useStreaming;
    
    await _saveSettings();
    notifyListeners();
  }

  // Get available models
  Future<List<String>> getAvailableModels() async {
    try {
      return await _apiService.getAvailableModels();
    } catch (e) {
      _setError('Failed to load models: $e');
      return [];
    }
  }

  // Add system message
  void addSystemMessage(String content) {
    final systemMessage = ChatMessage(
      role: 'system',
      content: content,
    );
    _conversationHistory.insert(0, systemMessage);
    notifyListeners();
  }

  // Add vehicle-specific system message
  void addVehicleSystemMessage(String vehicleInfo) {
    final systemMessage = ChatMessage(
      role: 'system',
      content: 'You are an AI assistant helping with vehicle diagnostics. '
          'Vehicle information: $vehicleInfo. '
          'Provide helpful, accurate advice about OBD2 diagnostics, error codes, '
          'and vehicle maintenance. Be concise but thorough.',
    );
    _conversationHistory.insert(0, systemMessage);
    notifyListeners();
  }

  // Remove message at index
  void removeMessage(int index) {
    if (index >= 0 && index < _conversationHistory.length) {
      _conversationHistory.removeAt(index);
      notifyListeners();
      _saveConversationHistory();
    }
  }

  // Private methods
  void _setStatus(ChatStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _status = ChatStatus.error;
    notifyListeners();
  }

  // Persistence methods
  Future<void> _saveConversationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _conversationHistory
          .map((msg) => msg.toJson())
          .toList();
      await prefs.setString('chat_conversation_history', 
          jsonEncode(historyJson));
    } catch (e) {
      print('Failed to save conversation history: $e');
    }
  }

  Future<void> _loadConversationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyString = prefs.getString('chat_conversation_history');
      if (historyString != null) {
        final historyJson = jsonDecode(historyString) as List;
        _conversationHistory = historyJson
            .map((json) => ChatMessage.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Failed to load conversation history: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('chat_model', _selectedModel);
      await prefs.setDouble('chat_temperature', _temperature);
      await prefs.setInt('chat_max_tokens', _maxTokens);
      await prefs.setBool('chat_use_streaming', _useStreaming);
    } catch (e) {
      print('Failed to save chat settings: $e');
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedModel = prefs.getString('chat_model') ?? 'gpt-3.5-turbo';
      _temperature = prefs.getDouble('chat_temperature') ?? 0.7;
      _maxTokens = prefs.getInt('chat_max_tokens') ?? 1000;
      _useStreaming = prefs.getBool('chat_use_streaming') ?? true;
    } catch (e) {
      print('Failed to load chat settings: $e');
    }
  }

  // Get previous chat sessions from vehicle provider
  List<ChatSession> getPreviousChatSessions() {
    // This would need to be called with a VehicleProvider context
    // For now, return empty list - this will be implemented when we have access to VehicleProvider
    return [];
  }

  // Get previous chat sessions with vehicle provider context
  List<ChatSession> getPreviousChatSessionsWithProvider(VehicleProvider vehicleProvider) {
    if (_currentVehicleVin != null) {
      return vehicleProvider.chatSessions
          .where((session) => session.vehicleVin == _currentVehicleVin)
          .toList();
    }
    return vehicleProvider.chatSessions;
  }
} 