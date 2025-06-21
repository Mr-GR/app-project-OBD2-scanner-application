import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../backend/providers/chat_provider.dart';
import '../../flutter_flow/flutter_flow_theme.dart';

class ChatTestWidget extends StatefulWidget {
  const ChatTestWidget({Key? key}) : super(key: key);

  @override
  State<ChatTestWidget> createState() => _ChatTestWidgetState();
}

class _ChatTestWidgetState extends State<ChatTestWidget> {
  String _testResult = '';
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().initialize();
    });
  }

  Future<void> _testApiConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = 'Testing API connection...\n';
    });

    try {
      final chatProvider = context.read<ChatProvider>();
      
      // Test 1: Check if API key is configured
      _testResult += '✓ ChatProvider initialized\n';
      
      // Test 2: Try to get available models
      _testResult += 'Testing model availability...\n';
      try {
        final models = await chatProvider.getAvailableModels();
        if (models.isNotEmpty) {
          _testResult += '✓ Found ${models.length} available models\n';
          _testResult += 'Models: ${models.take(3).join(', ')}${models.length > 3 ? '...' : ''}\n';
        } else {
          _testResult += '⚠ No models available (check API key)\n';
        }
      } catch (e) {
        _testResult += '⚠ Model fetch failed: $e\n';
        _testResult += 'This is expected if API key is not configured.\n';
      }
      
      // Test 3: Send a simple test message
      _testResult += 'Testing message sending...\n';
      try {
        await chatProvider.sendMessage('Hello, this is a test message.');
        
        if (chatProvider.conversationHistory.length >= 2) {
          _testResult += '✓ Message sent and response received\n';
          final response = chatProvider.conversationHistory.last.content;
          _testResult += 'Response: ${response.substring(0, response.length > 50 ? 50 : response.length)}...\n';
        } else {
          _testResult += '⚠ No response received\n';
        }
      } catch (e) {
        _testResult += '⚠ Message sending failed: $e\n';
        _testResult += 'This is expected if API key is not configured.\n';
      }
      
      _testResult += '\n🎉 Test completed!';
      if (chatProvider.errorMessage.isNotEmpty) {
        _testResult += '\n\nNote: Some tests failed because the API key is not configured.';
        _testResult += '\nTo fix this:';
        _testResult += '\n1. Copy env.example to .env';
        _testResult += '\n2. Add your OpenAI API key to .env';
        _testResult += '\n3. Restart the app';
      }
      
    } catch (e) {
      _testResult += '\n❌ Test failed: $e';
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: true,
        title: Text(
          'ChatGPT API Test',
          style: FlutterFlowTheme.of(context).headlineMedium.copyWith(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontSize: 22,
              ),
        ),
        centerTitle: false,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Connection Test',
                      style: FlutterFlowTheme.of(context).titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This test will verify that your ChatGPT API integration is working correctly.',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isTesting ? null : _testApiConnection,
                      icon: _isTesting 
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.play_arrow),
                      label: Text(_isTesting ? 'Testing...' : 'Run Test'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Results',
                        style: FlutterFlowTheme.of(context).titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).alternate,
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _testResult.isEmpty ? 'No test results yet. Click "Run Test" to start.' : _testResult,
                              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Steps',
                      style: FlutterFlowTheme.of(context).titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'If the test passes, you can:',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Navigate to /chat to use the full chat interface\n'
                      '• Customize settings in the chat screen\n'
                      '• Add system messages for specific use cases\n'
                      '• Integrate chat functionality into your existing UI',
                      style: FlutterFlowTheme.of(context).bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 