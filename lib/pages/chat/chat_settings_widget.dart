import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../backend/providers/chat_provider.dart';
import '../../flutter_flow/flutter_flow_theme.dart';

class ChatSettingsWidget extends StatefulWidget {
  const ChatSettingsWidget({Key? key}) : super(key: key);

  @override
  State<ChatSettingsWidget> createState() => _ChatSettingsWidgetState();
}

class _ChatSettingsWidgetState extends State<ChatSettingsWidget> {
  List<String> _availableModels = [];
  bool _isLoadingModels = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableModels();
  }

  Future<void> _loadAvailableModels() async {
    setState(() {
      _isLoadingModels = true;
    });

    try {
      final models = await context.read<ChatProvider>().getAvailableModels();
      setState(() {
        _availableModels = models;
        _isLoadingModels = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingModels = false;
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
          'Chat Settings',
          style: FlutterFlowTheme.of(context).headlineMedium.copyWith(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontSize: 22,
              ),
        ),
        centerTitle: false,
        elevation: 2,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildModelSelection(chatProvider),
              const SizedBox(height: 24),
              _buildTemperatureControl(chatProvider),
              const SizedBox(height: 24),
              _buildMaxTokensControl(chatProvider),
              const SizedBox(height: 24),
              _buildStreamingToggle(chatProvider),
              const SizedBox(height: 24),
              _buildSystemMessageSection(chatProvider),
              const SizedBox(height: 24),
              _buildClearConversationButton(chatProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModelSelection(ChatProvider chatProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Model',
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            const SizedBox(height: 12),
            if (_isLoadingModels)
              const Center(child: CircularProgressIndicator())
            else if (_availableModels.isEmpty)
              Text(
                'No models available',
                style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: chatProvider.selectedModel,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: _availableModels.map((model) {
                  return DropdownMenuItem(
                    value: model,
                    child: Text(model),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    chatProvider.updateSettings(model: value);
                  }
                },
              ),
            const SizedBox(height: 8),
            Text(
              'Choose the AI model for your conversations. GPT-4 is more capable but slower, while GPT-3.5 is faster and more cost-effective.',
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureControl(ChatProvider chatProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temperature',
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: chatProvider.temperature,
                    min: 0.0,
                    max: 2.0,
                    divisions: 20,
                    label: chatProvider.temperature.toStringAsFixed(1),
                    onChanged: (value) {
                      chatProvider.updateSettings(temperature: value);
                    },
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    chatProvider.temperature.toStringAsFixed(1),
                    style: FlutterFlowTheme.of(context).titleSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Focused',
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
                Text(
                  'Creative',
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Controls randomness in responses. Lower values make responses more focused and deterministic, while higher values make them more creative and varied.',
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaxTokensControl(ChatProvider chatProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Max Tokens',
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: chatProvider.maxTokens.toDouble(),
                    min: 100,
                    max: 4000,
                    divisions: 39,
                    label: chatProvider.maxTokens.toString(),
                    onChanged: (value) {
                      chatProvider.updateSettings(maxTokens: value.toInt());
                    },
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    chatProvider.maxTokens.toString(),
                    style: FlutterFlowTheme.of(context).titleSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Short',
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
                Text(
                  'Long',
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Maximum number of tokens in the response. Higher values allow for longer responses but may increase costs.',
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamingToggle(ChatProvider chatProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Streaming Responses',
                        style: FlutterFlowTheme.of(context).titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Show responses as they are generated',
                        style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: chatProvider.useStreaming,
                  onChanged: (value) {
                    chatProvider.updateSettings(useStreaming: value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemMessageSection(ChatProvider chatProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Message',
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Add a system message to set the context or behavior for the AI assistant.',
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showSystemMessageDialog(chatProvider),
              icon: const Icon(Icons.edit),
              label: const Text('Set System Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearConversationButton(ChatProvider chatProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conversation',
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Clear all conversation history. This action cannot be undone.',
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showClearConversationDialog(chatProvider),
              icon: const Icon(Icons.delete_forever),
              label: const Text('Clear Conversation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSystemMessageDialog(ChatProvider chatProvider) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Message'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Enter system message...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                chatProvider.addSystemMessage(controller.text.trim());
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('System message added')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showClearConversationDialog(ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Conversation'),
        content: const Text(
          'Are you sure you want to clear all conversation history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              chatProvider.clearConversation();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conversation cleared')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
} 