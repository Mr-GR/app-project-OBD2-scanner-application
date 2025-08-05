import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_links/app_links.dart';
import '../auth/auth_util.dart';

class DeepLinkService {
  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _linkSubscription;
  static bool _isInitialized = false;
  static GoRouter? _router;
  
  // Initialize deep link handling
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      print('🔗 Initializing deep link service...');
      
      // Listen for incoming links when app is already running
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          print('🔗 Received app link while running: $uri');
          _handleDeepLink(uri.toString());
        },
        onError: (err) {
          print('❌ Deep link stream error: $err');
        },
      );
      
      _isInitialized = true;
      print('✅ Deep link service initialized');
    } catch (e) {
      print('❌ Error initializing deep link service: $e');
    }
  }
  
  // Set router for navigation
  static void setRouter(GoRouter router) {
    _router = router;
  }
  
  // Handle initial link when app starts
  static Future<void> handleInitialLink(BuildContext context) async {
    try {
      print('🔗 Checking for initial link...');
      
      // Get initial link when app is launched from closed state
      final Uri? initialUri = await _appLinks.getInitialLink();
      
      if (initialUri != null) {
        print('🔗 Found initial link: $initialUri');
        await _handleDeepLink(initialUri.toString());
      } else {
        print('🔗 No initial link found');
      }
    } catch (e) {
      print('❌ Error getting initial link: $e');
    }
  }
  
  // Extract token from various magic link formats
  static String? _extractToken(String link) {
    try {
      final uri = Uri.parse(link);
      
      // Check query parameters first (for http://example.com/auth/callback?token=xyz)
      String? token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        return token;
      }
      
      // Check fragment (after #)
      if (uri.fragment.isNotEmpty) {
        final fragmentUri = Uri.parse('?${uri.fragment}');
        token = fragmentUri.queryParameters['token'];
        if (token != null && token.isNotEmpty) {
          return token;
        }
      }
      
      // Check path segments for token
      final pathSegments = uri.pathSegments;
      for (int i = 0; i < pathSegments.length - 1; i++) {
        if (pathSegments[i] == 'verify' || pathSegments[i] == 'auth' || pathSegments[i] == 'magic' || pathSegments[i] == 'callback') {
          final nextSegment = pathSegments[i + 1];
          if (nextSegment.isNotEmpty && nextSegment.length > 10) {
            return nextSegment;
          }
        }
      }
      
      // Check if the last path segment is a token
      if (pathSegments.isNotEmpty) {
        final lastSegment = pathSegments.last;
        if (lastSegment.length > 20) { // Tokens are typically longer
          return lastSegment;
        }
      }
      
      print('❌ No token found in link: $link');
      return null;
    } catch (e) {
      print('❌ Error extracting token from link: $e');
      return null;
    }
  }
  
  // Handle deep link processing
  static Future<void> _handleDeepLink(String link) async {
    try {
      print('🔗 Processing deep link: $link');
      print('🔍 Link analysis:');
      final uri = Uri.parse(link);
      print('  - Scheme: ${uri.scheme}');
      print('  - Host: ${uri.host}');
      print('  - Port: ${uri.port}');
      print('  - Path: ${uri.path}');
      print('  - Query params: ${uri.queryParameters}');
      print('  - Fragment: ${uri.fragment}');
      
      // Extract token from the link
      final token = _extractToken(link);
      if (token == null) {
        print('❌ No valid token found in deep link');
        return;
      }
      
      print('✅ Extracted token: ${token.substring(0, 10)}...');
      
      // Verify the token with the backend
      final result = await AuthUtil.verifyMagicToken(token);
      
      if (result.success) {
        print('🎉 Magic link verification successful');
        
        // Navigate to home page using router
        if (_router != null) {
          print('🏠 Navigating to home page...');
          _router!.go('/home');
          print('✅ Navigation to /home completed');
        } else {
          print('⚠️ No router available, magic link verified but cannot navigate');
        }
      } else {
        print('❌ Magic link verification failed: ${result.message}');
        
        // Navigate back to login if verification fails
        if (_router != null) {
          print('🔄 Navigating back to login...');
          _router!.go('/authLogin');
        }
      }
    } catch (e) {
      print('❌ Error handling deep link: $e');
      
      // Navigate back to login on error
      if (_router != null) {
        _router!.go('/authLogin');
      }
    }
  }
  
  // Show success message
  static void _showSuccess(BuildContext? context, String message) {
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  // Manual deep link handling for testing
  static Future<void> handleTestLink(BuildContext context, String link) async {
    await _handleDeepLink(link);
  }
  
  // Check if a link is a magic link
  static bool isMagicLink(String link) {
    try {
      final uri = Uri.parse(link);
      
      // Check for magic link patterns including various schemes
      return uri.queryParameters.containsKey('token') ||
             uri.fragment.contains('token=') ||
             uri.pathSegments.contains('verify') ||
             uri.pathSegments.contains('auth') ||
             uri.pathSegments.contains('magic') ||
             uri.pathSegments.contains('callback') ||
             (uri.scheme == 'obd2scanner' && uri.host == 'auth') ||
             (uri.host == 'localhost' && uri.port == 3000 && uri.path.startsWith('/auth/callback')) ||
             (uri.host == '192.168.1.48' && uri.port == 3000 && uri.path.startsWith('/auth/callback'));
    } catch (e) {
      return false;
    }
  }
  
  // Cleanup
  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _isInitialized = false;
    _router = null;
  }
}

// Widget for handling deep links in the app
class DeepLinkHandler extends StatefulWidget {
  final Widget child;
  
  const DeepLinkHandler({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  @override
  void initState() {
    super.initState();
    _initializeDeepLinks();
  }
  
  Future<void> _initializeDeepLinks() async {
    await DeepLinkService.initialize();
    
    // Handle initial link after a short delay to ensure UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        await DeepLinkService.handleInitialLink(context);
      }
    });
  }
  
  @override
  void dispose() {
    DeepLinkService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}