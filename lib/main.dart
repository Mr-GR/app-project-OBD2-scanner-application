import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
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

import '/flutter_flow/flutter_flow_theme.dart';
import 'pages/onboarding_flow/auth_welcome/auth_welcome_screen_widget.dart';
import 'test/test_widget.dart';

// AppStateNotifier for managing app state
class AppStateNotifier extends ChangeNotifier {
  static final AppStateNotifier _instance = AppStateNotifier._internal();
  static AppStateNotifier get instance => _instance;
  AppStateNotifier._internal();

  bool _showSplashImage = true;
  bool get showSplashImage => _showSplashImage;

  void stopShowingSplashImage() {
    _showSplashImage = false;
    notifyListeners();
  }
}

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

  String getRoute() {
    return _router.routerDelegate.currentConfiguration.uri.toString();
  }

  List<String> getRouteStack() {
    return [_router.routerDelegate.currentConfiguration.uri.toString()];
  }

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
      GoRoute(
        path: '/test',
        builder: (context, state) => const TestWidget(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreenWidget(),
      ),
      GoRoute(
        path: '/chat-test',
        builder: (context, state) => const ChatTestWidget(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainTabScaffold(),
      ),
      GoRoute(
        path: '/connection-settings',
        builder: (context, state) => const ConnectionSettingsWidget(),
      ),
      GoRoute(
        path: '/profile-settings',
        builder: (context, state) => const ProfileSettingsScreen(),
      ),
      GoRoute(
        path: '/subscription-details',
        builder: (context, state) => const SubscriptionDetailsScreen(),
      ),
      GoRoute(
        path: '/payment-methods',
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: '/account-history',
        builder: (context, state) => const AccountHistoryScreen(),
      ),
      GoRoute(
        path: '/personal-information',
        builder: (context, state) => const PersonalInformationScreen(),
      ),
      GoRoute(
        path: '/notification-settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/obd2-devices',
        builder: (context, state) => const OBD2DevicesScreen(),
      ),
      GoRoute(
        path: '/appearance-settings',
        builder: (context, state) => const AppearanceSettingsScreen(),
      ),
      GoRoute(
        path: '/data-storage-settings',
        builder: (context, state) => const DataStorageSettingsScreen(),
      ),
      GoRoute(
        path: '/security-settings',
        builder: (context, state) => const SecuritySettingsScreen(),
      ),
      GoRoute(
        path: '/data-management',
        builder: (context, state) => const DataManagementScreen(),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: '/upgrade-pro',
        builder: (context, state) => const UpgradeProScreen(),
      ),
      GoRoute(
        path: '/scan-results',
        builder: (context, state) {
          // Extract scan result from state parameters
          final scanResult = state.extra as ScanResult?;
          if (scanResult != null) {
            return ScanResultsScreen(scanResult: scanResult);
          }
          // Fallback to a default scan result if none provided
          return ScanResultsScreen(
            scanResult: ScanResult(
              id: 'default',
              type: 'Default Scan',
              timestamp: 'Now',
              vehicleVin: 'default',
              vehicleName: 'Default Vehicle',
              results: {'System': 'OK'},
              overallHealth: '85% Health',
              issues: [],
              recommendations: [],
            ),
          );
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/enhanced-features-demo',
        builder: (context, state) => const IntegrationExample(),
      ),
    ],
  );
}

String getCurrentRoute(BuildContext context) =>
    context.mounted ? MyApp.of(context).getRoute() : '';

List<String> getCurrentRouteStack(BuildContext context) =>
    context.mounted ? MyApp.of(context).getRouteStack() : [];
