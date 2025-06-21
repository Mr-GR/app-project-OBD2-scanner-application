import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

// Import all services
import 'profile_service.dart';
import 'location_service.dart';
import 'notification_service.dart';
import 'obd2_device_service.dart';
import 'data_storage_service.dart';
import 'privacy_security_service.dart';
import 'appearance_service.dart';
import 'support_service.dart';
import 'account_history_service.dart';
import 'subscription_service.dart';

class ServiceManager extends ChangeNotifier {
  static final ServiceManager _instance = ServiceManager._internal();
  factory ServiceManager() => _instance;
  ServiceManager._internal();

  // Service instances
  late IProfileService _profileService;
  late ILocationService _locationService;
  late INotificationService _notificationService;
  late IOBD2DeviceService _obd2DeviceService;
  late IDataStorageService _dataStorageService;
  late IPrivacySecurityService _privacySecurityService;
  late IAppearanceService _appearanceService;
  late ISupportService _supportService;
  late IAccountHistoryService _accountHistoryService;
  late ISubscriptionService _subscriptionService;

  // TODO: FIREBASE INTEGRATION
  // When ready to integrate Firebase Auth, uncomment:
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getters for services
  IProfileService get profileService => _profileService;
  ILocationService get locationService => _locationService;
  INotificationService get notificationService => _notificationService;
  IOBD2DeviceService get obd2DeviceService => _obd2DeviceService;
  IDataStorageService get dataStorageService => _dataStorageService;
  IPrivacySecurityService get privacySecurityService => _privacySecurityService;
  IAppearanceService get appearanceService => _appearanceService;
  ISupportService get supportService => _supportService;
  IAccountHistoryService get accountHistoryService => _accountHistoryService;
  ISubscriptionService get subscriptionService => _subscriptionService;

  // Initialize all services
  Future<void> initialize() async {
    _profileService = ProfileService();
    _locationService = LocationService();
    _notificationService = NotificationService();
    _obd2DeviceService = OBD2DeviceService();
    _dataStorageService = DataStorageService();
    _privacySecurityService = PrivacySecurityService();
    _appearanceService = AppearanceService();
    _supportService = SupportService();
    _accountHistoryService = AccountHistoryService();
    _subscriptionService = SubscriptionService();

    // Initialize each service
    await _profileService.initialize();
    await _locationService.initialize();
    await _notificationService.initialize();
    await _obd2DeviceService.initialize();
    await _dataStorageService.initialize();
    await _privacySecurityService.initialize();
    await _appearanceService.initialize();
    await _supportService.initialize();
    await _accountHistoryService.initialize();
    await _subscriptionService.initialize();

    notifyListeners();
  }

  // Get current user ID (mock data for now)
  String getCurrentUserId() {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase Auth, replace with:
    // final user = _auth.currentUser;
    // return user?.uid ?? 'mock_user_id';
    return 'mock_user_id';
  }

  // Check if user is authenticated (mock data for now)
  bool get isAuthenticated {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase Auth, replace with:
    // return _auth.currentUser != null;
    return true; // Mock authenticated state
  }

  // Get current user (mock data for now)
  // TODO: FIREBASE INTEGRATION
  // When ready to integrate Firebase Auth, replace with:
  // User? get currentUser => _auth.currentUser;
  dynamic get currentUser => null; // Mock user

  // Sign out (mock data for now)
  Future<void> signOut() async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase Auth, replace with:
    // await _auth.signOut();
    print('Mock sign out - no Firebase integration yet');
    notifyListeners();
  }
}

// Provider for ServiceManager
class ServiceManagerProvider extends StatelessWidget {
  final bool useMockServices;
  final Widget child;

  const ServiceManagerProvider({
    super.key,
    required this.useMockServices,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiceManager(),
      child: child,
    );
  }
}

// Extension for easy access to services from context
extension ServiceManagerExtension on BuildContext {
  ServiceManager get serviceManager => Provider.of<ServiceManager>(this, listen: false);
  
  IProfileService get profileService => serviceManager.profileService;
  ILocationService get locationService => serviceManager.locationService;
  INotificationService get notificationService => serviceManager.notificationService;
  IOBD2DeviceService get obd2DeviceService => serviceManager.obd2DeviceService;
  IDataStorageService get dataStorageService => serviceManager.dataStorageService;
  IPrivacySecurityService get privacySecurityService => serviceManager.privacySecurityService;
  IAppearanceService get appearanceService => serviceManager.appearanceService;
  ISupportService get supportService => serviceManager.supportService;
  IAccountHistoryService get accountHistoryService => serviceManager.accountHistoryService;
  ISubscriptionService get subscriptionService => serviceManager.subscriptionService;
} 