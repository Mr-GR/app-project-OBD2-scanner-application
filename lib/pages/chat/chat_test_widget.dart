import 'package:flutter/material.dart';

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
    // Removed backend provider logic
  }

  Future<void> _testApiConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = 'Testing API connection...\n';
    });
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isTesting = false;
      _testResult = 'API connection test complete (mock).';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isTesting ? null : _testApiConnection,
              child: Text('Test API Connection'),
            ),
            SizedBox(height: 20),
            Text(_testResult),
          ],
        ),
      ),
    );
  }
} 