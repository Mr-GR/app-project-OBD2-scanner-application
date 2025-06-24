import 'package:flutter/material.dart';
import 'package:o_b_d2_scanner_frontend/pages/home/home_page/home_page_widget.dart';
import 'package:o_b_d2_scanner_frontend/pages/diagnostic/diagnostics_tab_widget.dart';

class MainTabScaffold extends StatelessWidget {
  const MainTabScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Tabs'),
      ),
      body: Center(
        child: Text('MainTabScaffold (UI template)'),
      ),
      bottomNavigationBar: BottomNavigationBar(
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