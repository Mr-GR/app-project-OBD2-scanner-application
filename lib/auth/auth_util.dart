// Simple auth utility for UI-only onboarding flow
// This provides placeholder functions for the UI without actual Firebase auth

import 'package:flutter/material.dart';

class AuthUtil {
  // Placeholder auth manager for UI
  static final authManager = _AuthManager();
  
  // Simple navigation helper
  static void navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/home');
  }
  
  // Placeholder login function
  static Future<bool> signInWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // Always return true for UI demo
    return true;
  }
  
  // Placeholder signup function
  static Future<bool> createAccountWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // Always return true for UI demo
    return true;
  }
  
  // Placeholder password reset function
  static Future<bool> sendPasswordResetEmail(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // Always return true for UI demo
    return true;
  }
}

class _AuthManager {
  bool get isLoggedIn => false; // Always false for UI demo
  String? get currentUserEmail => null;
  
  Future<void> signOut() async {
    // Placeholder signout
  }
} 