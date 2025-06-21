// API Configuration for OBD2 Scanner App

class ApiConfig {
  // GPT API Configuration
  static const String gptApiKey = 'your-openai-api-key-here';
  static const String gptBaseUrl = 'https://api.openai.com/v1';
  
  // NHTSA API Configuration
  static const String nhtsaBaseUrl = 'https://vpic.nhtsa.dot.gov/api';
  
  // App Configuration
  static const String appName = 'Auto Fix';
  static const String appVersion = '1.0.0';
  
  // OBD2 Configuration
  static const int obd2TimeoutSeconds = 5;
  static const int maxRetries = 3;
  static const Duration scanTimeout = Duration(seconds: 30);
  
  // Bluetooth Configuration
  static const String obd2DevicePrefix = 'OBD';
  static const String elm327DevicePrefix = 'ELM327';
  
  // Feature Flags
  static const bool enableAIAnalysis = true;
  static const bool enableLiveData = true;
  static const bool enableEmissionsMonitoring = true;
  static const bool enableVehicleRecalls = true;
  
  // Mock Data Configuration (for development)
  static const bool useMockData = true;
  static const bool enableMockOBD2Responses = true;
  static const bool enableMockNHTSAResponses = true;
  static const bool enableMockGPTResponses = true;
} 