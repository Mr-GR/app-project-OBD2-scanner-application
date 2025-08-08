import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'home/home_page/home_page_widget.dart';
import 'diagnostic/diagnostics_tab_widget.dart';
import 'connection/bluetooth_connection_widget.dart';
import 'connection/connection_screen.dart';

class MainTabNavigator extends StatefulWidget {
  const MainTabNavigator({super.key});

  @override
  State<MainTabNavigator> createState() => _MainTabNavigatorState();
}

class _MainTabNavigatorState extends State<MainTabNavigator> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    const HomePageContent(),
    const DiagnosticsTabContent(),
    const BluetoothConnectionContent(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        selectedItemColor: FlutterFlowTheme.of(context).primary,
        unselectedItemColor: FlutterFlowTheme.of(context).secondaryText,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Diagnostics'),
          BottomNavigationBarItem(icon: Icon(Icons.bluetooth), label: 'Bluetooth'),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePageWidget();
  }
}

class DiagnosticsTabContent extends StatelessWidget {
  const DiagnosticsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const DiagnosticsTabWidget();
  }
}

class BluetoothConnectionContent extends StatelessWidget {
  const BluetoothConnectionContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const BluetoothConnectionWidget();
  }
}

class ConnectionTabContent extends StatelessWidget {
  const ConnectionTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConnectionScreen();
  }
}