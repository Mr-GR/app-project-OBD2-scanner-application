import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;

class SmartCacheService {
  static final SmartCacheService _instance = SmartCacheService._internal();
  factory SmartCacheService() => _instance;
  SmartCacheService._internal();

  late Database _database;
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Cache configuration
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration cacheExpiry = Duration(days: 7);
  static const Duration syncInterval = Duration(minutes: 15);

  Future<void> initialize() async {
    if (kIsWeb) {
      print('SmartCacheService: Running on web, using memory-only cache');
      // No disk cache on web
      return;
    }
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    await _initializeDatabase();
    await cleanupExpiredData();
    _isInitialized = true;
  }

  Future<void> _initializeDatabase() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(documentsDir.path, 'smart_cache.db');

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cached_data (
            key TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            version INTEGER NOT NULL,
            sync_status TEXT NOT NULL,
            data_type TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            operation TEXT NOT NULL,
            data TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            retry_count INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE data_versions (
            key TEXT PRIMARY KEY,
            local_version INTEGER NOT NULL,
            remote_version INTEGER NOT NULL,
            last_sync INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // Cache vehicle data with versioning
  Future<void> cacheVehicleData(String userId, Map<String, dynamic> vehicleData) async {
    await _ensureInitialized();
    
    final key = 'vehicle_${vehicleData['vin']}_$userId';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final version = await _getNextVersion(key);
    
    await _database.insert(
      'cached_data',
      {
        'key': key,
        'data': jsonEncode(vehicleData),
        'timestamp': timestamp,
        'version': version,
        'sync_status': 'cached',
        'data_type': 'vehicle',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await _updateDataVersion(key, version, version);
  }

  // Get cached vehicle data if fresh
  Future<Map<String, dynamic>?> getCachedVehicleData(String vin, String userId) async {
    await _ensureInitialized();
    
    final key = 'vehicle_${vin}_$userId';
    final result = await _database.query(
      'cached_data',
      where: 'key = ? AND data_type = ?',
      whereArgs: [key, 'vehicle'],
    );

    if (result.isEmpty) return null;

    final data = result.first;
    final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int);
    
    // Check if data is still fresh
    if (DateTime.now().difference(timestamp) > cacheExpiry) {
      await _removeCachedData(key);
      return null;
    }

    return jsonDecode(data['data'] as String);
  }

  // Cache diagnostic reports
  Future<void> cacheDiagnosticReport(String userId, Map<String, dynamic> report) async {
    await _ensureInitialized();
    
    final key = 'diagnostic_${report['id']}_$userId';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final version = await _getNextVersion(key);
    
    await _database.insert(
      'cached_data',
      {
        'key': key,
        'data': jsonEncode(report),
        'timestamp': timestamp,
        'version': version,
        'sync_status': 'cached',
        'data_type': 'diagnostic',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get cached diagnostic report
  Future<Map<String, dynamic>?> getCachedDiagnosticReport(String reportId, String userId) async {
    await _ensureInitialized();
    
    final key = 'diagnostic_${reportId}_$userId';
    final result = await _database.query(
      'cached_data',
      where: 'key = ? AND data_type = ?',
      whereArgs: [key, 'diagnostic'],
    );

    if (result.isEmpty) return null;

    final data = result.first;
    final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int);
    
    if (DateTime.now().difference(timestamp) > cacheExpiry) {
      await _removeCachedData(key);
      return null;
    }

    return jsonDecode(data['data'] as String);
  }

  // Cache chat sessions
  Future<void> cacheChatSession(String userId, Map<String, dynamic> chatData) async {
    await _ensureInitialized();
    
    final key = 'chat_${chatData['id']}_$userId';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final version = await _getNextVersion(key);
    
    await _database.insert(
      'cached_data',
      {
        'key': key,
        'data': jsonEncode(chatData),
        'timestamp': timestamp,
        'version': version,
        'sync_status': 'cached',
        'data_type': 'chat',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get cached chat sessions
  Future<List<Map<String, dynamic>>> getCachedChatSessions(String userId) async {
    await _ensureInitialized();
    
    final result = await _database.query(
      'cached_data',
      where: 'data_type = ? AND key LIKE ?',
      whereArgs: ['chat', 'chat_%_$userId'],
      orderBy: 'timestamp DESC',
    );

    final sessions = <Map<String, dynamic>>[];
    for (final data in result) {
      final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int);
      
      if (DateTime.now().difference(timestamp) <= cacheExpiry) {
        sessions.add(jsonDecode(data['data'] as String));
      } else {
        await _removeCachedData(data['key'] as String);
      }
    }

    return sessions;
  }

  // Add to sync queue for offline changes
  Future<void> addToSyncQueue(String operation, Map<String, dynamic> data) async {
    await _ensureInitialized();
    
    await _database.insert(
      'sync_queue',
      {
        'operation': operation,
        'data': jsonEncode(data),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'retry_count': 0,
      },
    );
  }

  // Sync when online
  Future<void> syncWhenOnline() async {
    await _ensureInitialized();
    
    final queue = await _database.query(
      'sync_queue',
      orderBy: 'timestamp ASC',
    );

    for (final item in queue) {
      try {
        final operation = item['operation'] as String;
        final data = jsonDecode(item['data'] as String);
        
        // Simulate sync operation (replace with real API calls)
        await _performSyncOperation(operation, data);
        
        // Remove from queue after successful sync
        await _database.delete(
          'sync_queue',
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      } catch (e) {
        // Increment retry count
        final retryCount = (item['retry_count'] as int) + 1;
        if (retryCount >= 3) {
          // Remove after max retries
          await _database.delete(
            'sync_queue',
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } else {
          await _database.update(
            'sync_queue',
            {'retry_count': retryCount},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        }
      }
    }
  }

  // Perform sync operation (mock implementation)
  Future<void> _performSyncOperation(String operation, Map<String, dynamic> data) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    switch (operation) {
      case 'create_vehicle':
        print('Syncing vehicle creation: ${data['vin']}');
        break;
      case 'update_vehicle':
        print('Syncing vehicle update: ${data['vin']}');
        break;
      case 'create_diagnostic':
        print('Syncing diagnostic report: ${data['id']}');
        break;
      case 'create_chat':
        print('Syncing chat session: ${data['id']}');
        break;
      default:
        print('Unknown sync operation: $operation');
    }
  }

  // Get cache statistics
  Future<CacheStats> getCacheStats() async {
    await _ensureInitialized();
    
    final dataCount = await _database.rawQuery('SELECT COUNT(*) as count FROM cached_data');
    final queueCount = await _database.rawQuery('SELECT COUNT(*) as count FROM sync_queue');
    final cacheSize = await _getCacheSize();
    
    return CacheStats(
      totalItems: dataCount.first['count'] as int,
      pendingSync: queueCount.first['count'] as int,
      cacheSize: cacheSize,
      lastCleanup: DateTime.fromMillisecondsSinceEpoch(
        _prefs.getInt('last_cleanup') ?? 0,
      ),
    );
  }

  // Cleanup expired data
  Future<void> cleanupExpiredData() async {
    await _ensureInitialized();
    
    final expiryTimestamp = DateTime.now().subtract(cacheExpiry).millisecondsSinceEpoch;
    
    await _database.delete(
      'cached_data',
      where: 'timestamp < ?',
      whereArgs: [expiryTimestamp],
    );

    await _prefs.setInt('last_cleanup', DateTime.now().millisecondsSinceEpoch);
  }

  // Export data
  Future<String> exportData(String userId) async {
    await _ensureInitialized();
    
    final result = await _database.query(
      'cached_data',
      where: 'key LIKE ?',
      whereArgs: ['%_$userId'],
    );

    final exportData = {
      'export_date': DateTime.now().toIso8601String(),
      'user_id': userId,
      'data': result.map((row) => {
        'key': row['key'],
        'data': row['data'],
        'timestamp': row['timestamp'],
        'version': row['version'],
        'data_type': row['data_type'],
      }).toList(),
    };

    return jsonEncode(exportData);
  }

  // Import data
  Future<void> importData(String jsonData) async {
    await _ensureInitialized();
    
    final importData = jsonDecode(jsonData) as Map<String, dynamic>;
    final data = importData['data'] as List<dynamic>;
    
    for (final item in data) {
      await _database.insert(
        'cached_data',
        {
          'key': item['key'],
          'data': item['data'],
          'timestamp': item['timestamp'],
          'version': item['version'],
          'sync_status': 'imported',
          'data_type': item['data_type'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Helper methods
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<int> _getNextVersion(String key) async {
    final result = await _database.query(
      'data_versions',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isEmpty) {
      await _database.insert('data_versions', {
        'key': key,
        'local_version': 1,
        'remote_version': 0,
        'last_sync': DateTime.now().millisecondsSinceEpoch,
      });
      return 1;
    }

    final currentVersion = result.first['local_version'] as int;
    final newVersion = currentVersion + 1;
    
    await _database.update(
      'data_versions',
      {'local_version': newVersion},
      where: 'key = ?',
      whereArgs: [key],
    );

    return newVersion;
  }

  Future<void> _updateDataVersion(String key, int localVersion, int remoteVersion) async {
    await _database.insert(
      'data_versions',
      {
        'key': key,
        'local_version': localVersion,
        'remote_version': remoteVersion,
        'last_sync': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _removeCachedData(String key) async {
    await _database.delete(
      'cached_data',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  Future<int> _getCacheSize() async {
    final result = await _database.rawQuery('''
      SELECT SUM(LENGTH(data)) as size FROM cached_data
    ''');
    
    return result.first['size'] as int? ?? 0;
  }
}

class CacheStats {
  final int totalItems;
  final int pendingSync;
  final int cacheSize;
  final DateTime lastCleanup;

  CacheStats({
    required this.totalItems,
    required this.pendingSync,
    required this.cacheSize,
    required this.lastCleanup,
  });

  String get formattedCacheSize {
    if (cacheSize < 1024) return '${cacheSize}B';
    if (cacheSize < 1024 * 1024) return '${(cacheSize / 1024).toStringAsFixed(1)}KB';
    return '${(cacheSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
} 