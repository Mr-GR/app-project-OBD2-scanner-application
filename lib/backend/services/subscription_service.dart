import 'dart:async';
import 'package:flutter/foundation.dart';

enum SubscriptionStatus {
  free,
  pro,
  trial,
  expired,
}

enum SubscriptionTier {
  free,
  pro,
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String billingPeriod;
  final List<String> features;
  final bool isPopular;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.billingPeriod,
    required this.features,
    this.isPopular = false,
  });
}

abstract class ISubscriptionService {
  Future<void> initialize();
  SubscriptionStatus get currentStatus;
  SubscriptionTier get currentTier;
  DateTime? get trialEndDate;
  DateTime? get subscriptionEndDate;
  String? get subscriptionId;
  bool get isLoading;
  bool get isPro;
  bool get isTrialActive;
  Stream<SubscriptionStatus> get statusStream;
  Stream<bool> get loadingStream;
  List<SubscriptionPlan> get availablePlans;
  Future<bool> startFreeTrial();
  Future<bool> subscribeToPro(String planId);
  Future<bool> cancelSubscription();
  Future<bool> restoreSubscription();
  Future<void> checkSubscriptionStatus();
}

class SubscriptionService extends ChangeNotifier implements ISubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  SubscriptionStatus _currentStatus = SubscriptionStatus.free;
  SubscriptionTier _currentTier = SubscriptionTier.free;
  DateTime? _trialEndDate;
  DateTime? _subscriptionEndDate;
  String? _subscriptionId;
  bool _isLoading = false;

  // Getters
  SubscriptionStatus get currentStatus => _currentStatus;
  SubscriptionTier get currentTier => _currentTier;
  DateTime? get trialEndDate => _trialEndDate;
  DateTime? get subscriptionEndDate => _subscriptionEndDate;
  String? get subscriptionId => _subscriptionId;
  bool get isLoading => _isLoading;
  bool get isPro => _currentTier == SubscriptionTier.pro;
  bool get isTrialActive => _currentStatus == SubscriptionStatus.trial;

  // Stream controllers
  final StreamController<SubscriptionStatus> _statusController = 
      StreamController<SubscriptionStatus>.broadcast();
  final StreamController<bool> _loadingController = 
      StreamController<bool>.broadcast();

  // Streams
  Stream<SubscriptionStatus> get statusStream => _statusController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;

  // Available subscription plans
  static final List<SubscriptionPlan> _availablePlans = [
    SubscriptionPlan(
      id: 'pro_monthly',
      name: 'Pro Monthly',
      description: 'Full access to all features',
      price: 9.99,
      currency: 'USD',
      billingPeriod: 'month',
      features: [
        'Unlimited vehicle scans',
        'Advanced diagnostic reports',
        'Priority customer support',
        'Export data to PDF',
        'Cloud backup & sync',
        'No advertisements',
        'Real-time monitoring',
        'Custom alerts',
      ],
    ),
    SubscriptionPlan(
      id: 'pro_yearly',
      name: 'Pro Yearly',
      description: 'Save 40% with annual billing',
      price: 59.99,
      currency: 'USD',
      billingPeriod: 'year',
      features: [
        'Unlimited vehicle scans',
        'Advanced diagnostic reports',
        'Priority customer support',
        'Export data to PDF',
        'Cloud backup & sync',
        'No advertisements',
        'Real-time monitoring',
        'Custom alerts',
        'Early access to new features',
      ],
      isPopular: true,
    ),
  ];

  @override
  List<SubscriptionPlan> get availablePlans => _availablePlans;

  // Initialize subscription service
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      // TODO: Load subscription status from backend/database
      await _loadSubscriptionStatus();
      
      // Check if trial has expired
      if (_currentStatus == SubscriptionStatus.trial && _trialEndDate != null) {
        if (DateTime.now().isAfter(_trialEndDate!)) {
          _currentStatus = SubscriptionStatus.expired;
          _currentTier = SubscriptionTier.free;
          await _updateSubscriptionStatus();
        }
      }
      
      // Check if subscription has expired
      if (_currentStatus == SubscriptionStatus.pro && _subscriptionEndDate != null) {
        if (DateTime.now().isAfter(_subscriptionEndDate!)) {
          _currentStatus = SubscriptionStatus.expired;
          _currentTier = SubscriptionTier.free;
          await _updateSubscriptionStatus();
        }
      }
      
    } catch (e) {
      debugPrint('Error initializing subscription service: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load subscription status from storage
  Future<void> _loadSubscriptionStatus() async {
    // TODO: Load from SharedPreferences, Firebase, or backend
    // For now, using mock data
    _currentStatus = SubscriptionStatus.free;
    _currentTier = SubscriptionTier.free;
    _trialEndDate = null;
    _subscriptionEndDate = null;
    _subscriptionId = null;
  }

  // Update subscription status
  Future<void> _updateSubscriptionStatus() async {
    // TODO: Save to SharedPreferences, Firebase, or backend
    _statusController.add(_currentStatus);
    notifyListeners();
  }

  // Start free trial
  Future<bool> startFreeTrial() async {
    _setLoading(true);
    
    try {
      // TODO: Implement actual trial start logic with backend
      _currentStatus = SubscriptionStatus.trial;
      _currentTier = SubscriptionTier.pro;
      _trialEndDate = DateTime.now().add(const Duration(days: 30));
      _subscriptionId = 'trial_${DateTime.now().millisecondsSinceEpoch}';
      
      await _updateSubscriptionStatus();
      
      debugPrint('Free trial started successfully');
      return true;
    } catch (e) {
      debugPrint('Error starting free trial: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Subscribe to pro plan
  Future<bool> subscribeToPro(String planId) async {
    _setLoading(true);
    
    try {
      // TODO: Implement actual subscription logic with payment processor
      final plan = _availablePlans.firstWhere((plan) => plan.id == planId);
      
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      _currentStatus = SubscriptionStatus.pro;
      _currentTier = SubscriptionTier.pro;
      _subscriptionEndDate = DateTime.now().add(
        plan.billingPeriod == 'month' 
            ? const Duration(days: 30) 
            : const Duration(days: 365)
      );
      _subscriptionId = 'sub_${DateTime.now().millisecondsSinceEpoch}';
      
      await _updateSubscriptionStatus();
      
      debugPrint('Successfully subscribed to Pro plan: $planId');
      return true;
    } catch (e) {
      debugPrint('Error subscribing to Pro: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel subscription
  Future<bool> cancelSubscription() async {
    _setLoading(true);
    
    try {
      // TODO: Implement actual cancellation logic with payment processor
      await Future.delayed(const Duration(seconds: 1));
      
      _currentStatus = SubscriptionStatus.expired;
      _currentTier = SubscriptionTier.free;
      _subscriptionEndDate = DateTime.now();
      
      await _updateSubscriptionStatus();
      
      debugPrint('Subscription cancelled successfully');
      return true;
    } catch (e) {
      debugPrint('Error cancelling subscription: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Restore purchases (for mobile platforms)
  Future<bool> restoreSubscription() async {
    _setLoading(true);
    
    try {
      // TODO: Implement actual restore logic with payment processor
      await Future.delayed(const Duration(seconds: 2));
      
      // For now, just check if user has an active subscription
      // This would typically check with the payment processor
      debugPrint('Subscription restored successfully');
      return true;
    } catch (e) {
      debugPrint('Error restoring subscription: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check subscription status
  Future<void> checkSubscriptionStatus() async {
    _setLoading(true);
    
    try {
      // TODO: Implement actual status check with payment processor
      await Future.delayed(const Duration(seconds: 1));
      
      // Check if trial has expired
      if (_currentStatus == SubscriptionStatus.trial && _trialEndDate != null) {
        if (DateTime.now().isAfter(_trialEndDate!)) {
          _currentStatus = SubscriptionStatus.expired;
          _currentTier = SubscriptionTier.free;
          await _updateSubscriptionStatus();
        }
      }
      
      // Check if subscription has expired
      if (_currentStatus == SubscriptionStatus.pro && _subscriptionEndDate != null) {
        if (DateTime.now().isAfter(_subscriptionEndDate!)) {
          _currentStatus = SubscriptionStatus.expired;
          _currentTier = SubscriptionTier.free;
          await _updateSubscriptionStatus();
        }
      }
      
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Check if feature is available
  bool isFeatureAvailable(String feature) {
    switch (feature) {
      case 'unlimited_scans':
        return isPro || isTrialActive;
      case 'advanced_reports':
        return isPro || isTrialActive;
      case 'priority_support':
        return isPro || isTrialActive;
      case 'export_pdf':
        return isPro || isTrialActive;
      case 'cloud_backup':
        return isPro || isTrialActive;
      case 'no_ads':
        return isPro || isTrialActive;
      case 'real_time_monitoring':
        return isPro || isTrialActive;
      case 'custom_alerts':
        return isPro || isTrialActive;
      default:
        return true; // Free features
    }
  }

  // Get remaining trial days
  int get remainingTrialDays {
    if (_trialEndDate == null) return 0;
    final remaining = _trialEndDate!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  // Get remaining subscription days
  int get remainingSubscriptionDays {
    if (_subscriptionEndDate == null) return 0;
    final remaining = _subscriptionEndDate!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    _loadingController.add(loading);
    notifyListeners();
  }

  // Get subscription plan by ID
  SubscriptionPlan? getPlanById(String planId) {
    try {
      return availablePlans.firstWhere((plan) => plan.id == planId);
    } catch (e) {
      return null;
    }
  }

  // Get popular plan
  SubscriptionPlan? get popularPlan {
    try {
      return availablePlans.firstWhere((plan) => plan.isPopular);
    } catch (e) {
      return availablePlans.isNotEmpty ? availablePlans.first : null;
    }
  }

  // Get current plan
  SubscriptionPlan? get currentPlan {
    if (_currentStatus == SubscriptionStatus.free) {
      return null;
    }
    
    // For trial users, return the popular plan or first available plan
    if (_currentStatus == SubscriptionStatus.trial) {
      return popularPlan ?? (availablePlans.isNotEmpty ? availablePlans.first : null);
    }
    
    // For pro users, return the popular plan or first available plan
    if (_currentStatus == SubscriptionStatus.pro) {
      return popularPlan ?? (availablePlans.isNotEmpty ? availablePlans.first : null);
    }
    
    return null;
  }

  // Get next billing date
  String? get nextBillingDate {
    if (_currentStatus == SubscriptionStatus.free) {
      return null;
    }
    
    DateTime? nextBilling;
    
    if (_currentStatus == SubscriptionStatus.trial && _trialEndDate != null) {
      nextBilling = _trialEndDate;
    } else if (_currentStatus == SubscriptionStatus.pro && _subscriptionEndDate != null) {
      nextBilling = _subscriptionEndDate;
    }
    
    if (nextBilling != null) {
      return '${nextBilling.month}/${nextBilling.day}/${nextBilling.year}';
    }
    
    return null;
  }

  // Get auto-renewal status
  bool get autoRenewal {
    // For trial users, auto-renewal is typically enabled
    if (_currentStatus == SubscriptionStatus.trial) {
      return true;
    }
    
    // For pro users, check if subscription is active
    if (_currentStatus == SubscriptionStatus.pro && _subscriptionEndDate != null) {
      return DateTime.now().isBefore(_subscriptionEndDate!);
    }
    
    return false;
  }

  @override
  void dispose() {
    _statusController.close();
    _loadingController.close();
    super.dispose();
  }
} 