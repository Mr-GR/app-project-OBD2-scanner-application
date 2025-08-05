// Authentication utility with magic link integration
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthUtil {
  static final _authService = AuthService();
  static final authManager = _AuthManager();
  
  // Navigation helper
  static void navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/home');
  }
  
  // Magic link login - sends magic link to email
  static Future<AuthResult> sendMagicLink(String email, {String? name}) async {
    return await _authService.requestMagicLink(email, name: name);
  }
  
  // Verify magic link token
  static Future<AuthResult> verifyMagicToken(String token) async {
    final result = await _authService.verifyToken(token);
    if (result.success) {
      // Notify auth manager of login state change
      authManager._notifyStateChange();
    }
    return result;
  }
  
  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    return await _authService.isAuthenticated();
  }
  
  // Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    return await _authService.getCurrentUser();
  }
  
  // Get stored user data
  static Future<Map<String, dynamic>?> getStoredUser() async {
    return await _authService.getStoredUser();
  }
  
  // Logout
  static Future<void> signOut() async {
    await _authService.logout();
    authManager._notifyStateChange();
  }
  
  // Legacy methods for backward compatibility (deprecated)
  @deprecated
  static Future<bool> signInWithEmailAndPassword(String email, String password) async {
    // For backward compatibility, send magic link instead
    final result = await sendMagicLink(email);
    return result.success;
  }
  
  @deprecated
  static Future<bool> createAccountWithEmailAndPassword(String email, String password) async {
    // For backward compatibility, send magic link instead
    final result = await sendMagicLink(email);
    return result.success;
  }
  
  @deprecated
  static Future<bool> sendPasswordResetEmail(String email) async {
    // For backward compatibility, send magic link instead
    final result = await sendMagicLink(email);
    return result.success;
  }
}

class _AuthManager extends ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _currentUser;
  
  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserEmail => _currentUser?['email'];
  String? get currentUserName => _currentUser?['name'];
  Map<String, dynamic>? get currentUser => _currentUser;
  
  // Initialize auth state
  Future<void> initializeAuth() async {
    try {
      _isLoggedIn = await AuthService().isAuthenticated();
      if (_isLoggedIn) {
        _currentUser = await AuthService().getStoredUser();
      }
      notifyListeners();
    } catch (e) {
      print('Error initializing auth: $e');
      _isLoggedIn = false;
      _currentUser = null;
      notifyListeners();
    }
  }
  
  // Internal method to notify state changes
  void _notifyStateChange() async {
    await initializeAuth();
  }
  
  Future<void> signOut() async {
    await AuthUtil.signOut();
  }
} 