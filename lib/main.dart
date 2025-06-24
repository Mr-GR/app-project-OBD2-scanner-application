import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
<<<<<<< HEAD
import 'package:o_b_d2_scanner_frontend/pages/onboarding_flow/auth_forgot_password/auth_forgot_password_widget.dart';
=======
import 'package:o_b_d2_scanner_frontend/pages/chat/chat_screen_widget.dart';
import 'package:o_b_d2_scanner_frontend/pages/chat/chat_test_widget.dart';
import 'package:o_b_d2_scanner_frontend/pages/home/main_tab_scaffold.dart';
import 'package:o_b_d2_scanner_frontend/pages/settings/connection_settings_widget.dart';
import 'package:o_b_d2_scanner_frontend/pages/profile/profile_settings_screen.dart';
import 'package:o_b_d2_scanner_frontend/pages/profile/subscription_details_screen.dart';
import 'package:o_b_d2_scanner_frontend/pages/profile/payment_methods_screen.dart';
import 'package:o_b_d2_scanner_frontend/pages/profile/account_history_screen.dart';
import 'package:o_b_d2_scanner_frontend/pages/profile/personal_information_screen.dart';
import 'package:o_b_d2_scanner_frontend/pages/profile/notification_settings_screen.dart';
import 'package:o_b_d2_scanner_frontend/pages/profile/obd2_devices_screen.dart';
import 'package:o_b_d2_scanner_frontend/pages/profile/appearance_settings_screen.dart';
import 'package:o_b_d2_scanner_frontend/pages/profile/data_storage_settings_screen.dart';
import 'package:o_b_d2_scanner_frontend/pages/profile/security_settings_screen.dart';
import 'package:o_b_d2_scanner_frontend/pages/profile/data_management_screen.dart';
import 'package:o_b_d2_scanner_frontend/pages/profile/support_screen.dart';
import 'package:o_b_d2_scanner_frontend/pages/profile/upgrade_pro_screen.dart';
import 'package:o_b_d2_scanner_frontend/pages/diagnostic/scan_results_screen.dart';
import 'package:o_b_d2_scanner_frontend/widgets/integration_example.dart';
import 'package:o_b_d2_scanner_frontend/widgets/accessibility_widgets.dart';
import 'package:o_b_d2_scanner_frontend/widgets/onboarding_tutorial_system.dart';
>>>>>>> f478dc7 (Update all files to ensure clean structure)

import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'pages/onboarding_flow/auth_welcome/auth_welcome_screen_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await FlutterFlowTheme.initialize();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    AppStateNotifier.instance.stopShowingSplashImage();
    _router = createRouter();
  }

  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e as RouteMatch?))
          .toList();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'OBD2-Scanner-Frontend',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
<<<<<<< HEAD
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
=======
      theme: FlutterFlowTheme.of(context).theme,
      darkTheme: FlutterFlowTheme.of(context).darkTheme,
      themeMode: _themeMode,
      routerConfig: _router,
      builder: (context, child) {
        return AccessibilityAwareWidget(
          respectReducedMotion: true,
          respectHighContrast: true,
          respectTextScaling: true,
          child: child!,
        );
      },
>>>>>>> f478dc7 (Update all files to ensure clean structure)
    );
  }
}

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/authWelcomeScreen',
        builder: (context, state) => const AuthWelcomeScreenWidget(),
      ),
    ],
  );
}

String getCurrentRoute(BuildContext context) =>
    context.mounted ? MyApp.of(context).getRoute() : '';

List<String> getCurrentRouteStack(BuildContext context) =>
    context.mounted ? MyApp.of(context).getRouteStack() : [];
