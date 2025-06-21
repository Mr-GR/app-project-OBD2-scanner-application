import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatGPTApiService {
  static final ChatGPTApiService _instance = ChatGPTApiService._internal();
  factory ChatGPTApiService() => _instance;
  ChatGPTApiService._internal();

  late Dio _dio;
  String? _apiKey;
  String _baseUrl = 'https://api.openai.com/v1';

  Future<void> initialize() async {
    try {
      await dotenv.load();
      _apiKey = dotenv.env['OPENAI_API_KEY'];
      _baseUrl = dotenv.env['OPENAI_API_BASE_URL'] ?? 'https://api.openai.com/v1';
    } catch (e) {
      print('Warning: Could not load .env file: $e');
      print('Using default configuration. Set OPENAI_API_KEY in .env file for full functionality.');
      _apiKey = null; // Will use mock data
      _baseUrl = 'https://api.openai.com/v1';
    }
    
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));

    // Add interceptors for logging and error handling
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print(obj),
    ));
  }

  Future<ChatGPTResponse> sendMessage({
    required String message,
    required List<ChatMessage> conversationHistory,
    String model = 'gpt-3.5-turbo',
    double temperature = 0.7,
    int maxTokens = 1000,
    bool stream = false,
  }) async {
    if (_apiKey == null) {
      throw ChatGPTException('API key not configured. Please set OPENAI_API_KEY in .env file.');
    }

    try {
      final messages = [
        ...conversationHistory.map((msg) => {
          'role': msg.role,
          'content': msg.content,
        }),
        {'role': 'user', 'content': message},
      ];

      final requestBody = {
        'model': model,
        'messages': messages,
        'temperature': temperature,
        'max_tokens': maxTokens,
        'stream': stream,
      };

      final response = await _dio.post(
        '/chat/completions',
        data: requestBody,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return ChatGPTResponse.fromJson(data);
      } else {
        throw ChatGPTException('API request failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ChatGPTException('Invalid API key. Please check your OpenAI API key.');
      } else if (e.response?.statusCode == 429) {
        throw ChatGPTException('Rate limit exceeded. Please try again later.');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw ChatGPTException('Connection timeout. Please check your internet connection.');
      } else {
        throw ChatGPTException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ChatGPTException('Unexpected error: $e');
    }
  }

  Stream<ChatGPTStreamResponse> sendMessageStream({
    required String message,
    required List<ChatMessage> conversationHistory,
    String model = 'gpt-3.5-turbo',
    double temperature = 0.7,
    int maxTokens = 1000,
  }) async* {
    if (_apiKey == null) {
      throw ChatGPTException('API key not configured. Please set OPENAI_API_KEY in .env file.');
    }

    try {
      final messages = [
        ...conversationHistory.map((msg) => {
          'role': msg.role,
          'content': msg.content,
        }),
        {'role': 'user', 'content': message},
      ];

      final requestBody = {
        'model': model,
        'messages': messages,
        'temperature': temperature,
        'max_tokens': maxTokens,
        'stream': true,
      };

      // For now, we'll use the regular API call and simulate streaming
      // This is more reliable than dealing with Dio's streaming complexities
      final response = await _dio.post(
        '/chat/completions',
        data: requestBody,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'] as String;
        
        // Simulate streaming by yielding chunks of the response
        const chunkSize = 10;
        for (int i = 0; i < content.length; i += chunkSize) {
          final chunk = content.substring(i, i + chunkSize > content.length ? content.length : i + chunkSize);
          yield ChatGPTStreamResponse(
            choices: [
              StreamChoice(
                index: 0,
                delta: StreamDelta(content: chunk),
              ),
            ],
          );
          await Future.delayed(const Duration(milliseconds: 50)); // Simulate streaming delay
        }
        
        yield ChatGPTStreamResponse.done();
      } else {
        throw ChatGPTException('API request failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ChatGPTException('Invalid API key. Please check your OpenAI API key.');
      } else if (e.response?.statusCode == 429) {
        throw ChatGPTException('Rate limit exceeded. Please try again later.');
      } else {
        throw ChatGPTException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ChatGPTException('Unexpected error: $e');
    }
  }

  Future<List<String>> getAvailableModels() async {
    if (_apiKey == null) {
      throw ChatGPTException('API key not configured. Please set OPENAI_API_KEY in .env file.');
    }

    try {
      final response = await _dio.get('/models');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final models = data['data'] as List;
        return models
            .where((model) => model['id'].toString().contains('gpt'))
            .map((model) => model['id'].toString())
            .toList();
      } else {
        throw ChatGPTException('Failed to fetch models: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ChatGPTException('Network error: ${e.message}');
    } catch (e) {
      throw ChatGPTException('Unexpected error: $e');
    }
  }
}

class ChatMessage {
  final String role; // 'user', 'assistant', or 'system'
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    role: json['role'],
    content: json['content'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class ChatGPTResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<Choice> choices;
  final Usage usage;

  ChatGPTResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
  });

  factory ChatGPTResponse.fromJson(Map<String, dynamic> json) => ChatGPTResponse(
    id: json['id'],
    object: json['object'],
    created: json['created'],
    model: json['model'],
    choices: (json['choices'] as List)
        .map((choice) => Choice.fromJson(choice))
        .toList(),
    usage: Usage.fromJson(json['usage']),
  );

  String get content => choices.first.message.content;
}

class Choice {
  final int index;
  final Message message;
  final String finishReason;

  Choice({
    required this.index,
    required this.message,
    required this.finishReason,
  });

  factory Choice.fromJson(Map<String, dynamic> json) => Choice(
    index: json['index'],
    message: Message.fromJson(json['message']),
    finishReason: json['finish_reason'],
  );
}

class Message {
  final String role;
  final String content;

  Message({
    required this.role,
    required this.content,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    role: json['role'],
    content: json['content'],
  );
}

class Usage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  Usage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory Usage.fromJson(Map<String, dynamic> json) => Usage(
    promptTokens: json['prompt_tokens'],
    completionTokens: json['completion_tokens'],
    totalTokens: json['total_tokens'],
  );
}

class ChatGPTStreamResponse {
  final String? id;
  final String? object;
  final int? created;
  final String? model;
  final List<StreamChoice>? choices;
  final bool isDone;

  ChatGPTStreamResponse({
    this.id,
    this.object,
    this.created,
    this.model,
    this.choices,
    this.isDone = false,
  });

  factory ChatGPTStreamResponse.fromJson(Map<String, dynamic> json) => ChatGPTStreamResponse(
    id: json['id'],
    object: json['object'],
    created: json['created'],
    model: json['model'],
    choices: json['choices'] != null
        ? (json['choices'] as List)
            .map((choice) => StreamChoice.fromJson(choice))
            .toList()
        : null,
  );

  factory ChatGPTStreamResponse.done() => ChatGPTStreamResponse(isDone: true);

  String? get content => choices?.first.delta.content;
}

class StreamChoice {
  final int index;
  final StreamDelta delta;
  final String? finishReason;

  StreamChoice({
    required this.index,
    required this.delta,
    this.finishReason,
  });

  factory StreamChoice.fromJson(Map<String, dynamic> json) => StreamChoice(
    index: json['index'],
    delta: StreamDelta.fromJson(json['delta']),
    finishReason: json['finish_reason'],
  );
}

class StreamDelta {
  final String? role;
  final String? content;

  StreamDelta({
    this.role,
    this.content,
  });

  factory StreamDelta.fromJson(Map<String, dynamic> json) => StreamDelta(
    role: json['role'],
    content: json['content'],
  );
}

class ChatGPTException implements Exception {
  final String message;
  ChatGPTException(this.message);

  @override
  String toString() => 'ChatGPTException: $message';
} 