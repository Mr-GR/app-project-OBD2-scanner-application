import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/services/deep_link_service.dart';
import '/auth/auth_util.dart';
import 'pages/onboarding_flow/auth_welcome/auth_welcome_screen_widget.dart';
import 'pages/onboarding_flow/auth_login/auth_login_widget.dart';
import 'pages/onboarding_flow/auth_create/auth_create_widget.dart';
import 'pages/onboarding_flow/auth_forgot_password/auth_forgot_password_widget.dart';
import 'pages/onboarding_flow/name_entry/name_entry_widget.dart';
import 'pages/chat/ai_chat_widget.dart';
import 'pages/chat/chat_test_widget.dart';
import 'pages/main_tab_navigator.dart';
import 'pages/settings/connection_settings_widget.dart';
import 'pages/settings/settings/settings_widget.dart';
import 'pages/profile/profile_settings_screen.dart';
import 'pages/profile/subscription_details_screen.dart';
import 'pages/diagnostic/scan_results_screen.dart';
import 'pages/vehicles/add_vehicle_widget.dart';
import 'pages/connection/connection_screen.dart';
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
  
  // Initialize authentication state
  await AuthUtil.authManager.initializeAuth();

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
    // Pass router to DeepLinkService for navigation
    DeepLinkService.setRouter(_router);
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
        return DeepLinkHandler(
          child: AccessibilityAwareWidget(
            respectReducedMotion: true,
            respectHighContrast: true,
            respectTextScaling: true,
            child: child!,
          ),
        );
      },
    );
  }
}

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/onboarding',
    redirect: (context, state) async {
      print('🚦 Router redirect check: ${state.fullPath}');
      
      // Check if user is already authenticated
      final isAuthenticated = await AuthUtil.isAuthenticated();
      print('🔐 Authentication status: $isAuthenticated');
      
      // If user is authenticated and trying to access onboarding/auth pages, redirect to home
      // (but allow name entry page for new users)
      if (isAuthenticated && (
          state.fullPath == '/onboarding' ||
          state.fullPath == '/authWelcomeScreen' ||
          state.fullPath == '/authLogin' ||
          state.fullPath == '/authCreate' ||
          state.fullPath == '/authForgotPassword'
        )) {
        print('✅ Authenticated user accessing auth page, redirecting to /home');
        return '/home';
      }
      
      // If user is not authenticated and trying to access protected pages, redirect to onboarding
      if (!isAuthenticated && (
          state.fullPath == '/home' ||
          state.fullPath == '/settings' ||
          state.fullPath == '/profile-settings' ||
          state.fullPath == '/subscription-details' ||
          state.fullPath == '/scan-results' ||
          state.fullPath == '/add-vehicle' ||
          state.fullPath == '/obd2-connection' ||
          state.fullPath == '/chat' ||
          state.fullPath == '/connection-settings' ||
          state.fullPath == '/nameEntry'
        )) {
        print('❌ Unauthenticated user accessing protected page, redirecting to /onboarding');
        return '/onboarding';
      }
      
      // No redirect needed
      print('➡️ No redirect needed for ${state.fullPath}');
      return null;
    },
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
      GoRoute(
        path: '/nameEntry',
        builder: (context, state) => const NameEntryWidget(),
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
        path: '/settings',
        builder: (context, state) => const SettingsWidget(),
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
      GoRoute(
        path: '/obd2-connection',
        builder: (context, state) => const ConnectionScreen(),
      ),
    ],
  );
}

String getCurrentRoute(BuildContext context) =>
    context.mounted ? MyApp.of(context).getRoute() : '';

List<String> getCurrentRouteStack(BuildContext context) =>
    context.mounted ? MyApp.of(context).getRouteStack() : [];
