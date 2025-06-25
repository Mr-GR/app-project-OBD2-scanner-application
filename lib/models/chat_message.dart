enum MessageType {
  user,
  ai,
}

enum UserLevel {
  beginner,
  expert,
}

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final UserLevel? userLevel;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.userLevel,
  });

  factory ChatMessage.user({
    required String content,
    UserLevel? userLevel,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
      userLevel: userLevel,
    );
  }

  factory ChatMessage.ai({
    required String content,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.ai,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'userLevel': userLevel?.name,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      userLevel: json['userLevel'] != null
          ? UserLevel.values.firstWhere(
              (e) => e.name == json['userLevel'],
              orElse: () => UserLevel.beginner,
            )
          : null,
    );
  }
} 