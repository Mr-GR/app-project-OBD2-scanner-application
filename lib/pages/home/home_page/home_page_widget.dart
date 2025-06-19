import 'package:o_b_d2_scanner_frontend/flutter_flow/flutter_flow_icon_button.dart';
import 'package:o_b_d2_scanner_frontend/pages/chat/ai_chat_widget.dart';
import 'package:o_b_d2_scanner_frontend/pages/manual_configuration/manual_configuration_widget.dart';
import 'package:o_b_d2_scanner_frontend/pages/obd2_bluetooth_configuration/obd2_bluetooth_configuration_widget.dart';
import 'package:o_b_d2_scanner_frontend/pages/settings/settings/settings_widget.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          leading: _selectedIndex != 0
              ? FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 30,
                  borderWidth: 1,
                  buttonSize: 60,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 30,
                  ),
                  onPressed: () async {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                )
              : null,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: _selectedIndex == 0
              ? _buildHomeContent(context)
              : _selectedIndex == 1
                  ? const SettingsWidget()
                  : Center(
                      child: Text(
                        'Profile Page Coming Soon...',
                        style: FlutterFlowTheme.of(context).bodyLarge,
                      ),
                    ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 24.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Welcome to Auto Fix',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context)
                      .headlineMedium
                      .override(
                        font: GoogleFonts.interTight(
                          fontWeight: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .fontWeight,
                          fontStyle: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .fontStyle,
                        ),
                        letterSpacing: 0.0,
                      ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFeatureCard(
                  icon: FontAwesomeIcons.bars,
                  label: 'Manual Setup',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManualConfigurationWidget()),
                  ),
                ),
                _buildFeatureCard(
                  icon: FontAwesomeIcons.screwdriver,
                  label: 'OBD2 Scanner',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Obd2BluetoothConfigurationWidget()),
                  ),
                ),
                _buildFeatureCard(
                  icon: FontAwesomeIcons.robot,
                  label: 'AI Chat',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AiChatWidget()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(20.0),
                    width: 250,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Cars coming soon...',
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Padding(
          //   padding: const EdgeInsets.only(top: 16.0),
          //   child: FFButtonWidget(
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => const AiChatWidget(),
          //         ),
          //       );
          //     },
          //     text: 'Get Started',
          //     options: FFButtonOptions(
          //       width: double.infinity,
          //       height: 50.0,
          //       padding: const EdgeInsets.all(8.0),
          //       iconAlignment: IconAlignment.start,
          //       iconPadding: const EdgeInsetsDirectional.all(0.0),
          //       color: Colors.black,
          //       textStyle: FlutterFlowTheme.of(context).titleSmall.override(
          //             font: GoogleFonts.interTight(
          //               fontWeight:
          //                   FlutterFlowTheme.of(context).titleSmall.fontWeight,
          //               fontStyle:
          //                   FlutterFlowTheme.of(context).titleSmall.fontStyle,
          //             ),
          //             color: FlutterFlowTheme.of(context).secondaryBackground,
          //             letterSpacing: 0.0,
          //           ),
          //       elevation: 2.0,
          //       borderRadius: BorderRadius.circular(12.0),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16.0),
        width: 180,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).primaryBackground,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              color: Colors.black,
              size: 32.0,
            ),
            const SizedBox(height: 8.0),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.inter(
                      fontWeight: 
                          FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                    ),
                    letterSpacing: 0.0,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
