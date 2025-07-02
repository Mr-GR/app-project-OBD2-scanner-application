import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'pages/onboarding_flow/auth_welcome/auth_welcome_screen_widget.dart';
import 'pages/onboarding_flow/auth_login/auth_login_widget.dart';
import 'pages/onboarding_flow/auth_create/auth_create_widget.dart';
import 'pages/onboarding_flow/auth_forgot_password/auth_forgot_password_widget.dart';
import 'pages/chat/chat_screen_widget.dart';
import 'pages/chat/ai_chat_widget.dart';
import 'pages/chat/chat_test_widget.dart';
import 'pages/main_tab_navigator.dart';
import 'pages/settings/connection_settings_widget.dart';
import 'pages/profile/profile_settings_screen.dart';
import 'pages/profile/subscription_details_screen.dart';
import 'pages/diagnostic/scan_results_screen.dart';
import 'pages/vehicles/add_vehicle_widget.dart';
import 'widgets/integration_example.dart';
import 'widgets/accessibility_widgets.dart';
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
      // Onboarding routes
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const AuthWelcomeScreenWidget(),
      ),
      GoRoute(
        path: '/authWelcomeScreen',
        builder: (context, state) => const AuthWelcomeScreenWidget(),
      ),
      GoRoute(
        path: '/authLogin',
        builder: (context, state) => const AuthLoginWidget(),
      ),
      GoRoute(
        path: '/authCreate',
        builder: (context, state) => const AuthCreateWidget(),
      ),
      GoRoute(
        path: '/authForgotPassword',
        builder: (context, state) => const AuthForgotPasswordWidget(),
      ),
      // Main app routes
      GoRoute(
        path: '/test',
        builder: (context, state) => const TestWidget(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const AiChatWidget(),
      ),
      GoRoute(
        path: '/chat-test',
        builder: (context, state) => const ChatTestWidget(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainTabNavigator(),
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
        path: '/scan-results',
        builder: (context, state) => const ScanResultsScreen(),
      ),
      GoRoute(
        path: '/add-vehicle',
        builder: (context, state) => const AddVehicleWidget(),
      ),
    ],
  );
}

String getCurrentRoute(BuildContext context) =>
    context.mounted ? MyApp.of(context).getRoute() : '';

List<String> getCurrentRouteStack(BuildContext context) =>
    context.mounted ? MyApp.of(context).getRouteStack() : [];
