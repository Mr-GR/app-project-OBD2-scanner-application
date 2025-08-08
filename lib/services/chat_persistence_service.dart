import 'dart:convert';
import 'package:http/http.dart' as http;
import '/config.dart';
import '/models/chat_message.dart';
import '/models/chat_conversation.dart';
import '/services/auth_service.dart';

class ChatPersistenceService {
  static final AuthService _authService = AuthService();

  static Future<ChatConversation> createConversation({
    String? title,
  }) async {
    try {
      final response = await _authService.authenticatedRequest(
        'POST',
        '/api/chat/conversations',
        body: {
          'title': title,
        },
      );

      if (response == null) {
        throw Exception('Authentication required - please login again');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ChatConversation.fromJson(data);
      } else {
        throw Exception('Failed to create conversation: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error creating conversation: $e');
    }
  }

  static Future<List<ChatConversation>> getConversations() async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/api/chat/conversations',
      );

      if (response == null) {
        throw Exception('Authentication required - please login again');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((item) => ChatConversation.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch conversations: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error fetching conversations: $e');
    }
  }

  static Future<ChatConversation> getConversation(String conversationId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/api/chat/conversations/$conversationId',
      );

      if (response == null) {
        throw Exception('Authentication required - please login again');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatConversation.fromJson(data);
      } else {
        throw Exception('Failed to fetch conversation: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error fetching conversation: $e');
    }
  }

  static Future<ChatMessage> saveMessage({
    required String conversationId,
    required ChatMessage message,
  }) async {
    try {
      print('Saving message: ${message.toJson()}'); // Debug log
      final response = await _authService.authenticatedRequest(
        'POST',
        '/api/chat/conversations/$conversationId/messages',
        body: message.toJson(),
      );

      if (response == null) {
        throw Exception('Authentication required - please login again');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ChatMessage.fromJson(data);
      } else {
        print('Save message error - Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to save message: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error saving message: $e');
    }
  }

  static Future<List<ChatMessage>> getMessages(String conversationId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/api/chat/conversations/$conversationId/messages',
      );

      if (response == null) {
        throw Exception('Authentication required - please login again');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((item) => ChatMessage.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch messages: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error fetching messages: $e');
    }
  }

  static Future<void> deleteConversation(String conversationId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'DELETE',
        '/api/chat/conversations/$conversationId',
      );

      if (response == null) {
        throw Exception('Authentication required - please login again');
      }

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete conversation: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error deleting conversation: $e');
    }
  }

  static Future<ChatConversation> updateConversationTitle({
    required String conversationId,
    required String title,
  }) async {
    try {
      final response = await _authService.authenticatedRequest(
        'PATCH',
        '/api/chat/conversations/$conversationId',
        body: {'title': title},
      );

      if (response == null) {
        throw Exception('Authentication required - please login again');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatConversation.fromJson(data);
      } else {
        throw Exception('Failed to update conversation: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error updating conversation: $e');
    }
  }
}