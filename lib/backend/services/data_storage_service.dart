import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class DataUsageStats {
  final String userId;
  final int cacheSize;
  final int cloudStorageUsed;
  final int totalScans;
  final DateTime lastCleanup;

  DataUsageStats({
    required this.userId,
    this.cacheSize = 0,
    this.cloudStorageUsed = 0,
    this.totalScans = 0,
    required this.lastCleanup,
  });

  factory DataUsageStats.fromMap(String userId, Map<String, dynamic> data) {
    return DataUsageStats(
      userId: userId,
      cacheSize: data['cacheSize'] ?? 0,
      cloudStorageUsed: data['cloudStorageUsed'] ?? 0,
      totalScans: data['totalScans'] ?? 0,
      lastCleanup: DateTime.parse(data['lastCleanup']),
    );
  }

  Map<String, dynamic> toMap() => {
    'cacheSize': cacheSize,
    'cloudStorageUsed': cloudStorageUsed,
    'totalScans': totalScans,
    'lastCleanup': lastCleanup.toIso8601String(),
  };
}

class StorageSettings {
  final String userId;
  final bool autoBackup;
  final bool autoCleanup;
  final int maxCacheSize; // in MB
  final bool compressData;

  StorageSettings({
    required this.userId,
    this.autoBackup = true,
    this.autoCleanup = true,
    this.maxCacheSize = 100, // 100MB default
    this.compressData = true,
  });

  factory StorageSettings.fromMap(String userId, Map<String, dynamic> data) {
    return StorageSettings(
      userId: userId,
      autoBackup: data['autoBackup'] ?? true,
      autoCleanup: data['autoCleanup'] ?? true,
      maxCacheSize: data['maxCacheSize'] ?? 100,
      compressData: data['compressData'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'autoBackup': autoBackup,
    'autoCleanup': autoCleanup,
    'maxCacheSize': maxCacheSize,
    'compressData': compressData,
  };
}

abstract class IDataStorageService {
  Future<void> initialize();
  Future<DataUsageStats> getDataUsageStats(String userId);
  Future<void> clearCache(String userId);
  Future<void> clearAllData(String userId);
  Future<StorageSettings> getStorageSettings(String userId);
  Future<void> updateStorageSettings(String userId, Map<String, dynamic> settings);
  Future<void> backupData(String userId);
  Future<void> restoreData(String userId);
  Future<int> getCacheSize();
  Future<void> cleanupOldData(String userId);
}

class DataStorageService implements IDataStorageService {
  // final _firestore = FirebaseFirestore.instance;
  // final _storage = FirebaseStorage.instance;

  @override
  Future<void> initialize() async {
    // Implementation needed
  }

  @override
  Future<DataUsageStats> getDataUsageStats(String userId) async {
    // final doc = await _firestore.collection('data_usage').doc(userId).get();
    // if (!doc.exists) {
    //   return DataUsageStats(userId: userId, lastCleanup: DateTime.now());
    // }
    // return DataUsageStats.fromMap(userId, doc.data()!);
    return DataUsageStats(userId: userId, lastCleanup: DateTime.now()); // Temporary mock implementation
  }

  @override
  Future<void> clearCache(String userId) async {
    // Clear local cache directory
    if (!kIsWeb) {
      final cacheDir = await getTemporaryDirectory();
      final appCacheDir = Directory('${cacheDir.path}/app_cache');
      if (await appCacheDir.exists()) {
        await appCacheDir.delete(recursive: true);
      }
    } else {
      // On web, nothing to clear (memory-only cache)
    }

    // Update stats
    // await _firestore.collection('data_usage').doc(userId).update({
    //   'cacheSize': 0,
    //   'lastCleanup': DateTime.now().toIso8601String(),
    // });
    // Temporary mock implementation
  }

  @override
  Future<void> clearAllData(String userId) async {
    // Clear cache
    await clearCache(userId);

    // Clear cloud storage
    // final userStorageRef = _storage.ref().child('user_data/$userId');
    // try {
    //   await userStorageRef.delete();
    // } catch (e) {
    //   // Ignore if no data exists
    // }

    // Clear Firestore data (except user profile)
    // final collections = ['vehicles', 'diagnostic_reports', 'chat_history'];
    // for (final collection in collections) {
    //   final query = await _firestore.collection(collection).where('userId', isEqualTo: userId).get();
    //   for (final doc in query.docs) {
    //     await doc.reference.delete();
    //   }
    // }

    // Reset usage stats
    // await _firestore.collection('data_usage').doc(userId).set({
    //   'cacheSize': 0,
    //   'cloudStorageUsed': 0,
    //   'totalScans': 0,
    //   'lastCleanup': DateTime.now().toIso8601String(),
    // });
    // Temporary mock implementation
  }

  @override
  Future<StorageSettings> getStorageSettings(String userId) async {
    // final doc = await _firestore.collection('storage_settings').doc(userId).get();
    // if (!doc.exists) {
    //   return StorageSettings(userId: userId);
    // }
    // return StorageSettings.fromMap(userId, doc.data()!);
    return StorageSettings(userId: userId); // Temporary mock implementation
  }

  @override
  Future<void> updateStorageSettings(String userId, Map<String, dynamic> settings) async {
    // await _firestore.collection('storage_settings').doc(userId).set(settings, SetOptions(merge: true));
    // Temporary mock implementation
  }

  @override
  Future<void> backupData(String userId) async {
    // Get all user data
    // final vehicles = await _firestore.collection('vehicles').where('userId', isEqualTo: userId).get();
    // final reports = await _firestore.collection('diagnostic_reports').where('userId', isEqualTo: userId).get();
    // final chats = await _firestore.collection('chat_history').where('userId', isEqualTo: userId).get();

    // Create backup document
    // final backupData = {
    //   'userId': userId,
    //   'timestamp': DateTime.now().toIso8601String(),
    //   'vehicles': vehicles.docs.map((doc) => doc.data()).toList(),
    //   'reports': reports.docs.map((doc) => doc.data()).toList(),
    //   'chats': chats.docs.map((doc) => doc.data()).toList(),
    // };

    // await _firestore.collection('backups').add(backupData);
    // Temporary mock implementation
  }

  @override
  Future<void> restoreData(String userId) async {
    // Get latest backup
    // final backups = await _firestore.collection('backups')
    //     .where('userId', isEqualTo: userId)
    //     .orderBy('timestamp', descending: true)
    //     .limit(1)
    //     .get();

    // if (backups.docs.isEmpty) {
    //   throw Exception('No backup found for user');
    // }

    // final backup = backups.docs.first.data();

    // Restore data (this would need careful implementation to avoid conflicts)
    // For now, just log the backup
    // print('Restoring backup: ${backup['timestamp']}');
    // Temporary mock implementation
  }

  @override
  Future<int> getCacheSize() async {
    if (kIsWeb) {
      // On web, disk cache is not used
      return 0;
    }
    final cacheDir = await getTemporaryDirectory();
    final appCacheDir = Directory('${cacheDir.path}/app_cache');
    
    if (!await appCacheDir.exists()) {
      return 0;
    }

    int totalSize = 0;
    await for (final file in appCacheDir.list(recursive: true)) {
      if (file is File) {
        totalSize += await file.length();
      }
    }

    return totalSize;
  }

  @override
  Future<void> cleanupOldData(String userId) async {
    final settings = await getStorageSettings(userId);
    if (!settings.autoCleanup) return;

    // Clean up old diagnostic reports (keep last 30 days)
    // final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    // final oldReports = await _firestore.collection('diagnostic_reports')
    //     .where('userId', isEqualTo: userId)
    //     .where('createdAt', isLessThan: thirtyDaysAgo.toIso8601String())
    //     .get();

    // for (final doc in oldReports.docs) {
    //   await doc.reference.delete();
    // }

    // Clean up old chat history (keep last 7 days)
    // final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    // final oldChats = await _firestore.collection('chat_history')
    //     .where('userId', isEqualTo: userId)
    //     .where('timestamp', isLessThan: sevenDaysAgo.toIso8601String())
    //     .get();

    // for (final doc in oldChats.docs) {
    //   await doc.reference.delete();
    // }

    // Update last cleanup time
    // await _firestore.collection('data_usage').doc(userId).update({
    //   'lastCleanup': DateTime.now().toIso8601String(),
    // });
    // Temporary mock implementation
  }
}

class MockDataStorageService implements IDataStorageService {
  final Map<String, DataUsageStats> _mockStats = {};
  final Map<String, StorageSettings> _mockSettings = {};

  @override
  Future<void> initialize() async {
    // Implementation needed
  }

  @override
  Future<DataUsageStats> getDataUsageStats(String userId) async {
    return _mockStats[userId] ?? DataUsageStats(
      userId: userId,
      cacheSize: 50,
      cloudStorageUsed: 25,
      totalScans: 15,
      lastCleanup: DateTime.now().subtract(const Duration(days: 5)),
    );
  }

  @override
  Future<void> clearCache(String userId) async {
    final stats = _mockStats[userId] ?? DataUsageStats(userId: userId, lastCleanup: DateTime.now());
    _mockStats[userId] = DataUsageStats(
      userId: userId,
      cacheSize: 0,
      cloudStorageUsed: stats.cloudStorageUsed,
      totalScans: stats.totalScans,
      lastCleanup: DateTime.now(),
    );
  }

  @override
  Future<void> clearAllData(String userId) async {
    _mockStats[userId] = DataUsageStats(
      userId: userId,
      cacheSize: 0,
      cloudStorageUsed: 0,
      totalScans: 0,
      lastCleanup: DateTime.now(),
    );
  }

  @override
  Future<StorageSettings> getStorageSettings(String userId) async {
    return _mockSettings[userId] ?? StorageSettings(userId: userId);
  }

  @override
  Future<void> updateStorageSettings(String userId, Map<String, dynamic> settings) async {
    final existing = _mockSettings[userId] ?? StorageSettings(userId: userId);
    _mockSettings[userId] = StorageSettings(
      userId: userId,
      autoBackup: settings['autoBackup'] ?? existing.autoBackup,
      autoCleanup: settings['autoCleanup'] ?? existing.autoCleanup,
      maxCacheSize: settings['maxCacheSize'] ?? existing.maxCacheSize,
      compressData: settings['compressData'] ?? existing.compressData,
    );
  }

  @override
  Future<void> backupData(String userId) async {
    // Mock backup
    print('Backing up data for user: $userId');
  }

  @override
  Future<void> restoreData(String userId) async {
    // Mock restore
    print('Restoring data for user: $userId');
  }

  @override
  Future<int> getCacheSize() async {
    return 50 * 1024 * 1024; // 50MB mock cache size
  }

  @override
  Future<void> cleanupOldData(String userId) async {
    final stats = _mockStats[userId];
    if (stats != null) {
      _mockStats[userId] = DataUsageStats(
        userId: userId,
        cacheSize: stats.cacheSize,
        cloudStorageUsed: stats.cloudStorageUsed,
        totalScans: stats.totalScans,
        lastCleanup: DateTime.now(),
      );
    }
  }
} 