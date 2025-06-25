import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ChatService {
  static const String _baseUrl = 'http://${Config.baseUrl}/api';

  static Future<ChatResponse> askQuestion({
    required String question,
    required String level,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ask'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'question': question,
          'level': level,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatResponse.fromJson(data);
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

class ChatResponse {
  final String answer;

  ChatResponse({required this.answer});

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      answer: json['answer'] ?? '',
    );
  }
} 