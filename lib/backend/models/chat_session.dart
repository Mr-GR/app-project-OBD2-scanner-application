import '../api_requests/chatgpt_api_service.dart';

class ChatSession {
  final String id;
  final String vehicleVin;
  final DateTime sessionDate;
  final String title;
  final List<ChatMessage> messages;
  final String? summary;
  final Map<String, dynamic>? metadata;

  ChatSession({
    required this.id,
    required this.vehicleVin,
    required this.sessionDate,
    required this.title,
    required this.messages,
    this.summary,
    this.metadata,
  });

  // Get the timestamp of the last message
  DateTime get lastMessageTime {
    if (messages.isEmpty) return sessionDate;
    return messages.last.timestamp;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicleVin': vehicleVin,
    'sessionDate': sessionDate.toIso8601String(),
    'title': title,
    'messages': messages.map((msg) => msg.toJson()).toList(),
    'summary': summary,
    'metadata': metadata,
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id: json['id'] ?? '',
    vehicleVin: json['vehicleVin'] ?? '',
    sessionDate: DateTime.parse(json['sessionDate']),
    title: json['title'] ?? '',
    messages: (json['messages'] as List?)
        ?.map((msg) => ChatMessage.fromJson(msg))
        .toList() ?? [],
    summary: json['summary'],
    metadata: json['metadata'] != null 
        ? Map<String, dynamic>.from(json['metadata']) 
        : null,
  );

  ChatSession copyWith({
    String? id,
    String? vehicleVin,
    DateTime? sessionDate,
    String? title,
    List<ChatMessage>? messages,
    String? summary,
    Map<String, dynamic>? metadata,
  }) =>
      ChatSession(
        id: id ?? this.id,
        vehicleVin: vehicleVin ?? this.vehicleVin,
        sessionDate: sessionDate ?? this.sessionDate,
        title: title ?? this.title,
        messages: messages ?? this.messages,
        summary: summary ?? this.summary,
        metadata: metadata ?? this.metadata,
      );
} 