import '/models/chat_message.dart';

class ChatConversation {
  final String id;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage>? messages;

  ChatConversation({
    required this.id,
    this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id']?.toString() ?? '',
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      messages: json['messages'] != null
          ? (json['messages'] as List).map((m) => ChatMessage.fromJson(m)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages?.map((m) => m.toJson()).toList(),
    };
  }
}