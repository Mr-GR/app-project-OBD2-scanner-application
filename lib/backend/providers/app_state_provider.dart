import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class AppStateProvider extends ChangeNotifier {
  // Connection States
  bool _isConnectedToOBD2 = false;
  bool _isConnectedToInternet = true;
  bool _isAuthenticated = false;
  bool _hasValidApiKeys = false;
  
  // Mock Data Flags
  bool _useMockData = ApiConfig.useMockData;
  bool _enableMockOBD2Responses = ApiConfig.enableMockOBD2Responses;
  bool _enableMockNHTSAResponses = ApiConfig.enableMockNHTSAResponses;
  bool _enableMockGPTResponses = ApiConfig.enableMockGPTResponses;
  
  // App State
  bool _isInitialized = false;
  String _currentVehicleVin = '';
  String _lastError = '';
  
  // Getters
  bool get isConnectedToOBD2 => _isConnectedToOBD2;
  bool get isConnectedToInternet => _isConnectedToInternet;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasValidApiKeys => _hasValidApiKeys;
  bool get useMockData => _useMockData;
  bool get enableMockOBD2Responses => _enableMockOBD2Responses;
  bool get enableMockNHTSAResponses => _enableMockNHTSAResponses;
  bool get enableMockGPTResponses => _enableMockGPTResponses;
  bool get isInitialized => _isInitialized;
  String get currentVehicleVin => _currentVehicleVin;
  String get lastError => _lastError;
  
  // Computed Properties
  bool get isProductionMode => !_useMockData && _hasValidApiKeys;
  bool get isDevelopmentMode => _useMockData || !_hasValidApiKeys;
  bool get canPerformScans => _isConnectedToOBD2 || _enableMockOBD2Responses;
  bool get canUseAI => _hasValidApiKeys || _enableMockGPTResponses;
  bool get canFetchVehicleData => _isConnectedToInternet || _enableMockNHTSAResponses;
  
  // Initialize App State
  Future<void> initialize() async {
    try {
      // Check API keys
      await _validateApiKeys();
      
      // Check internet connection
      await _checkInternetConnection();
      
      // Check authentication status
      await _checkAuthenticationStatus();
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _lastError = 'Failed to initialize app: $e';
      notifyListeners();
    }
  }
  
  // Validate API Keys
  Future<void> _validateApiKeys() async {
    try {
      // Check if API keys are configured
      final hasOpenAIKey = ApiConfig.gptApiKey.isNotEmpty && 
                          ApiConfig.gptApiKey != 'your-openai-api-key-here';
      
      _hasValidApiKeys = hasOpenAIKey;
      
      if (!_hasValidApiKeys) {
        _lastError = 'API keys not configured. Using mock data.';
      }
    } catch (e) {
      _hasValidApiKeys = false;
      _lastError = 'Failed to validate API keys: $e';
    }
  }
  
  // Check Internet Connection
  Future<void> _checkInternetConnection() async {
    try {
      // Simple internet connectivity check
      // In production, use a more robust method
      _isConnectedToInternet = true; // Placeholder
    } catch (e) {
      _isConnectedToInternet = false;
      _lastError = 'No internet connection available';
    }
  }
  
  // Check Authentication Status
  Future<void> _checkAuthenticationStatus() async {
    try {
      // Check if user is authenticated
      // In production, check Firebase Auth or other auth service
      _isAuthenticated = false; // Placeholder for now
    } catch (e) {
      _isAuthenticated = false;
      _lastError = 'Authentication check failed: $e';
    }
  }
  
  // Update OBD2 Connection Status
  void updateOBD2ConnectionStatus(bool connected) {
    _isConnectedToOBD2 = connected;
    notifyListeners();
  }
  
  // Update Internet Connection Status
  void updateInternetConnectionStatus(bool connected) {
    _isConnectedToInternet = connected;
    notifyListeners();
  }
  
  // Update Authentication Status
  void updateAuthenticationStatus(bool authenticated) {
    _isAuthenticated = authenticated;
    notifyListeners();
  }
  
  // Update Current Vehicle
  void updateCurrentVehicle(String vin) {
    _currentVehicleVin = vin;
    notifyListeners();
  }
  
  // Toggle Mock Data (for development)
  void toggleMockData(bool useMock) {
    _useMockData = useMock;
    notifyListeners();
  }
  
  // Toggle Mock OBD2 Responses
  void toggleMockOBD2Responses(bool enable) {
    _enableMockOBD2Responses = enable;
    notifyListeners();
  }
  
  // Toggle Mock NHTSA Responses
  void toggleMockNHTSAResponses(bool enable) {
    _enableMockNHTSAResponses = enable;
    notifyListeners();
  }
  
  // Toggle Mock GPT Responses
  void toggleMockGPTResponses(bool enable) {
    _enableMockGPTResponses = enable;
    notifyListeners();
  }
  
  // Clear Error
  void clearError() {
    _lastError = '';
    notifyListeners();
  }
  
  // Set Error
  void setError(String error) {
    _lastError = error;
    notifyListeners();
  }
  
  // Get App Status Summary
  Map<String, dynamic> getAppStatus() {
    return {
      'isProductionMode': isProductionMode,
      'isDevelopmentMode': isDevelopmentMode,
      'canPerformScans': canPerformScans,
      'canUseAI': canUseAI,
      'canFetchVehicleData': canFetchVehicleData,
      'isConnectedToOBD2': _isConnectedToOBD2,
      'isConnectedToInternet': _isConnectedToInternet,
      'isAuthenticated': _isAuthenticated,
      'hasValidApiKeys': _hasValidApiKeys,
      'useMockData': _useMockData,
      'lastError': _lastError,
    };
  }
  
  // Reset to Default State
  void reset() {
    _isConnectedToOBD2 = false;
    _isConnectedToInternet = true;
    _isAuthenticated = false;
    _hasValidApiKeys = false;
    _useMockData = ApiConfig.useMockData;
    _enableMockOBD2Responses = ApiConfig.enableMockOBD2Responses;
    _enableMockNHTSAResponses = ApiConfig.enableMockNHTSAResponses;
    _enableMockGPTResponses = ApiConfig.enableMockGPTResponses;
    _isInitialized = false;
    _currentVehicleVin = '';
    _lastError = '';
    notifyListeners();
  }
} 