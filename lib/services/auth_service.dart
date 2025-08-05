import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Request magic link
  Future<AuthResult> requestMagicLink(String email, {String? name}) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/auth/request-magic-link'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          if (name != null && name.isNotEmpty) 'name': name,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return AuthResult.success(data['message']);
      } else {
        return AuthResult.error(data['message'] ?? 'Failed to send magic link');
      }
    } catch (e) {
      return AuthResult.error('Network error: Unable to send magic link');
    }
  }

  // Verify token and get JWT
  Future<AuthResult> verifyToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/auth/verify-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        // Store JWT token
        await _storage.write(key: _tokenKey, value: data['access_token']);
        
        // Store user data
        if (data['user'] != null) {
          await _storage.write(key: _userKey, value: jsonEncode(data['user']));
        }
        
        return AuthResult.success('Authentication successful', userData: data['user']);
      } else {
        return AuthResult.error(data['message'] ?? 'Invalid or expired token');
      }
    } catch (e) {
      return AuthResult.error('Network error: Unable to verify token');
    }
  }

  // Get current user info
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await getStoredToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        // Update stored user data
        await _storage.write(key: _userKey, value: jsonEncode(userData));
        return userData;
      } else if (response.statusCode == 401) {
        // Token expired, clear stored data
        await logout();
        return null;
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
    return null;
  }

  // Check authentication status
  Future<bool> isAuthenticated() async {
    try {
      final token = await getStoredToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/auth/status'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['authenticated'] == true;
      } else if (response.statusCode == 401) {
        // Token expired, clear stored data
        await logout();
        return false;
      }
    } catch (e) {
      print('Error checking auth status: $e');
    }
    return false;
  }

  // Logout
  Future<void> logout() async {
    try {
      final token = await getStoredToken();
      if (token != null) {
        // Call logout endpoint
        await http.post(
          Uri.parse('${Config.baseUrl}/api/auth/logout'),
          headers: {'Authorization': 'Bearer $token'},
        );
      }
    } catch (e) {
      print('Error during logout: $e');
    } finally {
      // Always clear local storage
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
    }
  }

  // Get stored token
  Future<String?> getStoredToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Get stored user data
  Future<Map<String, dynamic>?> getStoredUser() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson != null) {
        return jsonDecode(userJson);
      }
    } catch (e) {
      print('Error reading stored user: $e');
    }
    return null;
  }

  // Make authenticated HTTP requests
  Future<http.Response?> authenticatedRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    final token = await getStoredToken();
    if (token == null) return null;

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      ...?additionalHeaders,
    };

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          return await http.get(Uri.parse('${Config.baseUrl}$endpoint'), headers: headers);
        case 'POST':
          return await http.post(
            Uri.parse('${Config.baseUrl}$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
        case 'PUT':
          return await http.put(
            Uri.parse('${Config.baseUrl}$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
        case 'DELETE':
          return await http.delete(Uri.parse('${Config.baseUrl}$endpoint'), headers: headers);
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }
    } catch (e) {
      print('Authenticated request error: $e');
      return null;
    }
  }
}

// Result class for auth operations
class AuthResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? userData;

  AuthResult._(this.success, this.message, this.userData);

  factory AuthResult.success(String message, {Map<String, dynamic>? userData}) {
    return AuthResult._(true, message, userData);
  }

  factory AuthResult.error(String message) {
    return AuthResult._(false, message, null);
  }
}