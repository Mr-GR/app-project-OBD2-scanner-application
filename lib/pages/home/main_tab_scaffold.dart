import 'package:flutter/material.dart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Diagnostics',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {},
      ),
    );
  }
}

class _DiagnosticsTabPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Diagnostics')),
      body: Center(child: Text('Diagnostics (UI template)')),
    );
  }
} 