import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_theme.dart';

class ChatSettingsWidget extends StatefulWidget {
  const ChatSettingsWidget({Key? key}) : super(key: key);

  @override
  State<ChatSettingsWidget> createState() => _ChatSettingsWidgetState();
}

class _ChatSettingsWidgetState extends State<ChatSettingsWidget> {
  List<String> _availableModels = ['gpt-3.5-turbo', 'gpt-4'];
  bool _isLoadingModels = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available Models:', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 12),
            ..._availableModels.map((model) => ListTile(
                  title: Text(model),
                  leading: Icon(Icons.memory),
                )),
            const SizedBox(height: 24),
            Text('Temperature', style: FlutterFlowTheme.of(context).titleMedium),
            Slider(
              value: 1.0,
              min: 0.0,
              max: 2.0,
              divisions: 20,
              label: '1.0',
              onChanged: (value) {},
            ),
            const SizedBox(height: 12),
            Text('Choose the AI model for your conversations. GPT-4 is more capable but slower, while GPT-3.5 is faster and more cost-effective.',
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                )),
          ],
        ),
      ),
    );
  }
} 