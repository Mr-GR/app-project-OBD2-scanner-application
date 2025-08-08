enum MessageType {
  user,
  assistant,
  diagnostic,
  error,
}

class ChatMessage {
  final String id;
  final String content;
  final MessageType messageType;
  final DateTime timestamp;
  final String? conversationId;
  final List<String>? suggestions;
  final String format;

  ChatMessage({
    required this.id,
    required this.content,
    required this.messageType,
    required this.timestamp,
    this.conversationId,
    this.suggestions,
    this.format = 'plain',
  });

  factory ChatMessage.user({
    required String content,
    String? conversationId,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      messageType: MessageType.user,
      timestamp: DateTime.now(),
      conversationId: conversationId,
      format: 'plain',
    );
  }

  factory ChatMessage.assistant({
    required String content,
    String? conversationId,
    List<String>? suggestions,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      messageType: MessageType.assistant,
      timestamp: DateTime.now(),
      conversationId: conversationId,
      suggestions: suggestions,
      format: 'markdown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'message_type': messageType.name,
      'timestamp': timestamp.toIso8601String(),
      'conversationId': conversationId,
      'suggestions': suggestions,
      'format': format,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      content: json['content'] ?? '',
      messageType: MessageType.values.firstWhere(
        (e) => e.name == json['message_type'],
        orElse: () => MessageType.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      conversationId: json['conversationId']?.toString(),
      suggestions: json['suggestions'] != null 
          ? List<String>.from(json['suggestions'])
          : null,
      format: json['format'] ?? 'plain',
    );
  }
} 