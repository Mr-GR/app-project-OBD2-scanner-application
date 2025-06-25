
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  Map<String, dynamic>? _vehicleInfo;

  void _navigateToAddCar() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddVehicleWidget(),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _vehicleInfo = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
=======
import 'package:flutter/material.dart';
import '../../../flutter_flow/flutter_flow_theme.dart';

class HomePageWidget extends StatelessWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
>>>>>>> f478dc7 (Update all files to ensure clean structure)
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
=======
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top full-width card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome Back!', style: FlutterFlowTheme.of(context).titleLarge),
                    const SizedBox(height: 8),
                    Text('Ready for your next scan or chat?', style: FlutterFlowTheme.of(context).bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Responsive carousel in the middle
            SizedBox(
              height: 150,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _QuickActionCard(
                        icon: Icons.flash_on,
                        color: Colors.orange,
                        title: 'Quick Scan',
                        subtitle: 'Start a new vehicle scan',
                        onTap: () {},
                      ),
                      SizedBox(width: 16),
                      _QuickActionCard(
                        icon: Icons.chat_bubble_outline,
                        color: Colors.blue,
                        title: 'AI Chat',
                        subtitle: 'Ask the AI assistant',
                        onTap: () {
                          context.go('/chat-ai');
                        },
                      ),
                      SizedBox(width: 16),
                      _QuickActionCard(
                        icon: Icons.add_card,
                        color: Colors.green,
                        title: 'Add Car',
                        subtitle: 'Add a new vehicle',
                        onTap: _navigateToAddCar,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Quick Code Check card
            _QuickCodeCheckCard(),
            const SizedBox(height: 24),
            // Vehicle card at the bottom
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    width: width > 500 ? 500 : double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: _vehicleInfo == null
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('My Vehicle', style: FlutterFlowTheme.of(context).titleMedium),
                              const SizedBox(height: 8),
                              Text('No vehicle added yet. Tap "Add Car" to get started.', style: FlutterFlowTheme.of(context).bodySmall),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('My Vehicle', style: FlutterFlowTheme.of(context).titleMedium),
                              const SizedBox(height: 8),
                              _formField('Make', _vehicleInfo!['make']),
                              _formField('Model', _vehicleInfo!['model']),
                              _formField('Year', _vehicleInfo!['year']),
                              _formField('Trim', _vehicleInfo!['trim']),
                              _formField('VIN', _vehicleInfo!['vin']),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formField(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        initialValue: value.toString(),
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          isDense: true,
        ),
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(icon, color: color, size: 28),
                  radius: 24,
                ),
                const SizedBox(height: 16),
                Text(title, style: FlutterFlowTheme.of(context).titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: FlutterFlowTheme.of(context).bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickCodeCheckCard extends StatefulWidget {
  @override
  State<_QuickCodeCheckCard> createState() => _QuickCodeCheckCardState();
}

class _QuickCodeCheckCardState extends State<_QuickCodeCheckCard> {
  final TextEditingController _codeController = TextEditingController();
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _result;

  Future<void> _checkCode() async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Please enter a code.';
      });
      return;
    }
    try {
      // TODO: Replace with your backend URL
      final url = Uri.parse('http://${Config.baseUrl}/api/scanner/dtc/lookup?code=$code');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _result = json.decode(response.body);
        });
      } else {
        setState(() {
          _error = 'Code not found or backend error.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Code Check', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Enter DTC Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _checkCode,
              child: _loading ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text('Check Code'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Colors.red)),
            ],
            if (_result != null) ...[
              const SizedBox(height: 16),
              Text('Result:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              if (_result!['description'] != null)
                Text('Description: ${_result!['description']}'),
              if (_result!['suggestions'] != null)
                Text('Suggestions: ${_result!['suggestions']}'),
            ],
          ],
        ),
>>>>>>> 8a14f7e (Added UI chat and connection to backend service)
=======
      body: Center(
        child: Text('Home Page (UI template)'),
>>>>>>> f478dc7 (Update all files to ensure clean structure)
      ),
    );
  }
}
