import 'dart:io';
// TODO: FIREBASE INTEGRATION
// When ready to integrate Firebase, uncomment:
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';

enum SubscriptionType {
  free,
  pro,
  premium,
}

class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final SubscriptionType subscriptionType;
  final Map<String, dynamic> preferences;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    required this.createdAt,
    required this.lastUpdated,
    this.subscriptionType = SubscriptionType.free,
    this.preferences = const {},
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(), // Mock: using ISO string instead of Timestamp
      'lastUpdated': lastUpdated.toIso8601String(),
      'subscriptionType': subscriptionType.name,
      'preferences': preferences,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
    };
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      avatarUrl: map['avatarUrl'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      lastUpdated: DateTime.parse(map['lastUpdated'] ?? DateTime.now().toIso8601String()),
      subscriptionType: SubscriptionType.values.firstWhere(
        (e) => e.name == map['subscriptionType'],
        orElse: () => SubscriptionType.free,
      ),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      isEmailVerified: map['isEmailVerified'] ?? false,
      isPhoneVerified: map['isPhoneVerified'] ?? false,
    );
  }

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    DateTime? lastUpdated,
    SubscriptionType? subscriptionType,
    Map<String, dynamic>? preferences,
    bool? isEmailVerified,
    bool? isPhoneVerified,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      preferences: preferences ?? this.preferences,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    );
  }
}

abstract class IProfileService {
  Future<UserProfile?> getProfile(String uid);
  Future<UserProfile> getUserProfile(String uid);
  Future<void> updateProfile(String uid, UserProfile profile);
  Future<void> updateAvatar(String uid, File imageFile);
  Future<void> deleteAvatar(String uid);
  Future<void> updateSubscription(String uid, SubscriptionType type);
  Future<void> updatePreferences(String uid, Map<String, dynamic> preferences);
  Future<void> deleteProfile(String uid);
  Future<void> initialize();
}

class ProfileService implements IProfileService {
  // TODO: FIREBASE INTEGRATION
  // When ready to integrate Firebase, uncomment:
  // final _firestore = FirebaseFirestore.instance;
  // final _storage = FirebaseStorage.instance;

  // Mock data storage
  final Map<String, UserProfile> _mockProfiles = {};

  @override
  Future<UserProfile?> getProfile(String uid) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final doc = await _firestore.collection('users').doc(uid).get();
    // if (!doc.exists) return null;
    // return UserProfile.fromMap(uid, doc.data()!);

    return _mockProfiles[uid];
  }

  @override
  Future<UserProfile> getUserProfile(String uid) async {
    final profile = await getProfile(uid);
    if (profile != null) return profile;
    
    // Create default profile if doesn't exist
    final defaultProfile = UserProfile(
      uid: uid,
      displayName: 'User',
      email: 'user@example.com',
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
    );
    
    await updateProfile(uid, defaultProfile);
    return defaultProfile;
  }

  @override
  Future<void> updateProfile(String uid, UserProfile profile) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final updatedProfile = profile.copyWith(lastUpdated: DateTime.now());
    // await _firestore.collection('users').doc(uid).set(updatedProfile.toMap());

    final updatedProfile = profile.copyWith(lastUpdated: DateTime.now());
    _mockProfiles[uid] = updatedProfile;
  }

  @override
  Future<void> updateAvatar(String uid, File imageFile) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final ref = _storage.ref().child('avatars/$uid.jpg');
    // await ref.putFile(imageFile);
    // final url = await ref.getDownloadURL();
    // final profile = await getProfile(uid);
    // if (profile != null) {
    //   await updateProfile(uid, profile.copyWith(avatarUrl: url));
    // }

    // Mock implementation - just update the profile with a mock URL
    final profile = await getProfile(uid);
    if (profile != null) {
      await updateProfile(uid, profile.copyWith(avatarUrl: 'https://example.com/avatar.jpg'));
    }
  }

  @override
  Future<void> deleteAvatar(String uid) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final profile = await getProfile(uid);
    // if (profile?.avatarUrl != null) {
    //   final ref = _storage.refFromURL(profile!.avatarUrl!);
    //   await ref.delete();
    //   await updateProfile(uid, profile.copyWith(avatarUrl: null));
    // }

    final profile = await getProfile(uid);
    if (profile != null) {
      await updateProfile(uid, profile.copyWith(avatarUrl: null));
    }
  }

  @override
  Future<void> updateSubscription(String uid, SubscriptionType type) async {
    final profile = await getProfile(uid);
    if (profile != null) {
      await updateProfile(uid, profile.copyWith(subscriptionType: type));
    }
  }

  @override
  Future<void> updatePreferences(String uid, Map<String, dynamic> preferences) async {
    final profile = await getProfile(uid);
    if (profile != null) {
      final updatedPreferences = Map<String, dynamic>.from(profile.preferences);
      updatedPreferences.addAll(preferences);
      await updateProfile(uid, profile.copyWith(preferences: updatedPreferences));
    }
  }

  @override
  Future<void> deleteProfile(String uid) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // await _firestore.collection('users').doc(uid).delete();
    // await deleteAvatar(uid);

    _mockProfiles.remove(uid);
  }

  @override
  Future<void> initialize() async {
    // Initialize any required resources
  }
}

// Mock implementation for testing
class MockProfileService implements IProfileService {
  @override
  Future<UserProfile?> getProfile(String uid) async {
    return UserProfile(
      uid: uid,
      displayName: 'Mock User',
      email: 'mock@example.com',
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Future<UserProfile> getUserProfile(String uid) async {
    return await getProfile(uid) ?? UserProfile(
      uid: uid,
      displayName: 'Mock User',
      email: 'mock@example.com',
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Future<void> updateProfile(String uid, UserProfile profile) async {
    // Mock implementation
  }

  @override
  Future<void> updateAvatar(String uid, File imageFile) async {
    // Mock implementation
  }

  @override
  Future<void> deleteAvatar(String uid) async {
    // Mock implementation
  }

  @override
  Future<void> updateSubscription(String uid, SubscriptionType type) async {
    // Mock implementation
  }

  @override
  Future<void> updatePreferences(String uid, Map<String, dynamic> preferences) async {
    // Mock implementation
  }

  @override
  Future<void> deleteProfile(String uid) async {
    // Mock implementation
  }

  @override
  Future<void> initialize() async {
    // Mock implementation
  }
} 