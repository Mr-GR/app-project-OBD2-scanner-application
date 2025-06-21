# ChatGPT API Integration Setup Guide

This guide will help you set up the ChatGPT API integration in your OBD2 Scanner Flutter application.

## Prerequisites

1. An OpenAI API key (get one from [OpenAI Platform](https://platform.openai.com/api-keys))
2. Flutter development environment
3. Basic knowledge of Flutter development

## Setup Instructions

### 1. Install Dependencies

The required dependencies have already been added to `pubspec.yaml`:
- `dio: ^5.4.0` - For HTTP requests
- `flutter_dotenv: ^5.1.0` - For environment variable management

Run the following command to install the dependencies:
```bash
flutter pub get
```

### 2. Configure API Key

1. Copy the example environment file:
   ```bash
   cp env.example .env
   ```

2. Edit the `.env` file and add your OpenAI API key:
   ```
   OPENAI_API_KEY=sk-your-actual-api-key-here
   OPENAI_API_BASE_URL=https://api.openai.com/v1
   ```

   **Important**: Never commit your `.env` file to version control. It's already added to `.gitignore`.

### 3. Access the Chat Interface

The chat interface is available at the `/chat` route. You can navigate to it programmatically:

```dart
// Navigate to chat screen
context.go('/chat');
```

Or add a button in your existing UI:

```dart
ElevatedButton(
  onPressed: () => context.go('/chat'),
  child: Text('Open AI Assistant'),
)
```

## Features

### Chat Interface
- **Real-time messaging** with ChatGPT
- **Streaming responses** for better user experience
- **Message history** with timestamps
- **Error handling** with user-friendly messages
- **Loading indicators** during API calls

### Settings Panel
- **Model selection** (GPT-3.5-turbo, GPT-4, etc.)
- **Temperature control** (0.0 - 2.0)
- **Max tokens** configuration (100 - 4000)
- **Streaming toggle** (on/off)
- **System message** configuration
- **Conversation management**

### Advanced Features
- **Conversation persistence** using SharedPreferences
- **Settings persistence** across app sessions
- **Error recovery** and retry mechanisms
- **Rate limiting** handling
- **Network error** handling

## API Service Architecture

### ChatGPTApiService
Located at `lib/backend/api_requests/chatgpt_api_service.dart`

**Key Methods:**
- `sendMessage()` - Send a single message and get response
- `sendMessageStream()` - Stream responses in real-time
- `getAvailableModels()` - Fetch available OpenAI models

### ChatProvider
Located at `lib/backend/providers/chat_provider.dart`

**Key Features:**
- State management for chat conversations
- Settings management
- Conversation persistence
- Error handling

## Usage Examples

### Basic Chat Usage
```dart
// Get the chat provider
final chatProvider = context.read<ChatProvider>();

// Send a message
await chatProvider.sendMessage("Hello, how can you help me with OBD2 diagnostics?");

// Listen to conversation changes
Consumer<ChatProvider>(
  builder: (context, chatProvider, child) {
    return ListView.builder(
      itemCount: chatProvider.conversationHistory.length,
      itemBuilder: (context, index) {
        final message = chatProvider.conversationHistory[index];
        return Text(message.content);
      },
    );
  },
)
```

### Custom System Message
```dart
// Add a system message to set context
chatProvider.addSystemMessage(
  "You are an expert in OBD2 diagnostics and automotive repair. "
  "Provide helpful, accurate advice about car diagnostics and troubleshooting."
);
```

### Settings Configuration
```dart
// Update chat settings
await chatProvider.updateSettings(
  model: 'gpt-4',
  temperature: 0.5,
  maxTokens: 2000,
  useStreaming: true,
);
```

## Error Handling

The integration includes comprehensive error handling for:
- **Invalid API key** (401 errors)
- **Rate limiting** (429 errors)
- **Network timeouts**
- **Connection errors**
- **Invalid responses**

Error messages are displayed to users in a user-friendly format.

## Security Considerations

1. **API Key Protection**: Never expose your API key in client-side code
2. **Environment Variables**: Use `.env` files for configuration
3. **Git Ignore**: Ensure `.env` is in your `.gitignore`
4. **Rate Limiting**: Be aware of OpenAI's rate limits
5. **Cost Management**: Monitor your API usage to control costs

## Troubleshooting

### Common Issues

1. **"API key not configured" error**
   - Ensure your `.env` file exists and contains the correct API key
   - Check that the API key starts with `sk-`

2. **"Invalid API key" error**
   - Verify your API key is correct
   - Check if your OpenAI account has sufficient credits

3. **Network errors**
   - Check your internet connection
   - Verify the API base URL is correct

4. **Rate limiting errors**
   - Wait a moment before sending another message
   - Consider upgrading your OpenAI plan

### Debug Mode

Enable debug logging by checking the console output. The API service includes detailed logging for troubleshooting.

## Cost Optimization

1. **Use GPT-3.5-turbo** for most conversations (cheaper)
2. **Limit max tokens** to reduce costs
3. **Use streaming** for better user experience
4. **Monitor usage** in your OpenAI dashboard

## Support

For issues related to:
- **OpenAI API**: Contact OpenAI support
- **Flutter integration**: Check the code comments and documentation
- **App-specific issues**: Review the error messages and logs

## License

This ChatGPT integration is part of your OBD2 Scanner application. Ensure compliance with OpenAI's terms of service and usage policies. 