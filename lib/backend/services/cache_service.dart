import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

/// Cache entry with expiration
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration expiration;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.expiration,
  });

  bool get isExpired {
    return DateTime.now().isAfter(timestamp.add(expiration));
  }

  Duration get timeUntilExpiration {
    final expirationTime = timestamp.add(expiration);
    final now = DateTime.now();
    
    if (now.isAfter(expirationTime)) {
      return Duration.zero;
    }
    
    return expirationTime.difference(now);
  }
}

/// Centralized caching service for the OBD2 Scanner app
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _cacheDirName = 'obd2_cache';
  static const Duration _defaultExpiration = Duration(hours: 24);
  
  Directory? _cacheDir;
  final Map<String, CacheEntry> _memoryCache = {};
  static const int _maxMemoryEntries = 100;

  /// Initialize the cache service
  Future<void> initialize() async {
    if (_cacheDir != null) return;
    
    // Skip disk initialization on web platform
    if (kIsWeb) {
      print('CacheService: Running on web, using memory-only cache');
      _cacheDir = null; // Ensure no disk cache is used
      return;
    }
    
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDir.path}/$_cacheDirName');
      
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }
    } catch (e) {
      print('CacheService: Error initializing disk cache: $e');
      // Continue with memory-only cache
      _cacheDir = null;
    }
  }

  /// Store data in cache
  Future<void> set<T>(
    String key,
    T data, {
    Duration? expiration,
    bool persistToDisk = true,
  }) async {
    await initialize();
    
    final entry = CacheEntry<T>(
      data: data,
      timestamp: DateTime.now(),
      expiration: expiration ?? _defaultExpiration,
    );

    // Store in memory
    _memoryCache[key] = entry;
    
    // Limit memory cache size
    if (_memoryCache.length > _maxMemoryEntries) {
      final oldestKey = _memoryCache.keys.first;
      _memoryCache.remove(oldestKey);
    }

    // Store on disk if requested and not on web
    if (persistToDisk && !kIsWeb && _cacheDir != null) {
      await _writeToDisk(key, entry);
    }
  }

  /// Retrieve data from cache
  T? get<T>(String key) {
    final entry = _memoryCache[key] as CacheEntry<T>?;
    
    if (entry == null || entry.isExpired) {
      _memoryCache.remove(key);
      return null;
    }
    
    return entry.data;
  }

  /// Retrieve data from cache asynchronously (checks disk)
  Future<T?> getAsync<T>(String key) async {
    await initialize();
    
    // Check memory first
    final memoryEntry = _memoryCache[key] as CacheEntry<T>?;
    if (memoryEntry != null && !memoryEntry.isExpired) {
      return memoryEntry.data;
    }

    // Check disk only if not on web
    if (!kIsWeb && _cacheDir != null) {
      final diskEntry = await _readFromDisk<T>(key);
      if (diskEntry != null && !diskEntry.isExpired) {
        // Restore to memory
        _memoryCache[key] = diskEntry;
        return diskEntry.data;
      }
    }

    // Remove expired entries
    _memoryCache.remove(key);
    if (!kIsWeb && _cacheDir != null) {
      await _removeFromDisk(key);
    }
    
    return null;
  }

  /// Check if key exists and is not expired
  Future<bool> has(String key) async {
    return await getAsync(key) != null;
  }

  /// Remove item from cache
  Future<void> remove(String key) async {
    await initialize();
    
    _memoryCache.remove(key);
    if (!kIsWeb && _cacheDir != null) {
      await _removeFromDisk(key);
    }
  }

  /// Clear all cache
  Future<void> clear() async {
    await initialize();
    
    _memoryCache.clear();
    
    if (!kIsWeb && _cacheDir != null && await _cacheDir!.exists()) {
      await _cacheDir!.delete(recursive: true);
      await _cacheDir!.create();
    }
  }

  /// Get cache statistics
  Future<CacheStats> getStats() async {
    await initialize();
    
    int diskSize = 0;
    int diskFiles = 0;
    
    if (!kIsWeb && _cacheDir != null && await _cacheDir!.exists()) {
      final files = await _cacheDir!.list().toList();
      diskFiles = files.length;
      
      for (final file in files) {
        if (file is File) {
          diskSize += await file.length();
        }
      }
    }
    
    return CacheStats(
      memoryEntries: _memoryCache.length,
      diskFiles: diskFiles,
      diskSizeBytes: diskSize,
    );
  }

  /// Generate cache key from multiple parameters
  static String generateKey(String base, Map<String, dynamic> params) {
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
    
    final paramString = jsonEncode(sortedParams);
    final combined = '$base:$paramString';
    
    return sha256.convert(utf8.encode(combined)).toString();
  }

  /// Write entry to disk
  Future<void> _writeToDisk<T>(String key, CacheEntry<T> entry) async {
    if (kIsWeb || _cacheDir == null) return; // Never write to disk on web
    
    final file = File('${_cacheDir!.path}/${_sanitizeKey(key)}.cache');
    final data = {
      'data': entry.data,
      'timestamp': entry.timestamp.toIso8601String(),
      'expiration': entry.expiration.inMilliseconds,
      'type': T.toString(),
    };
    
    await file.writeAsString(jsonEncode(data));
  }

  /// Read entry from disk
  Future<CacheEntry<T>?> _readFromDisk<T>(String key) async {
    if (_cacheDir == null) return null;
    
    final file = File('${_cacheDir!.path}/${_sanitizeKey(key)}.cache');
    
    if (!await file.exists()) return null;
    
    try {
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      
      return CacheEntry<T>(
        data: data['data'] as T,
        timestamp: DateTime.parse(data['timestamp']),
        expiration: Duration(milliseconds: data['expiration']),
      );
    } catch (e) {
      // Corrupted cache file, remove it
      await file.delete();
      return null;
    }
  }

  /// Remove entry from disk
  Future<void> _removeFromDisk(String key) async {
    if (_cacheDir == null) return;
    
    final file = File('${_cacheDir!.path}/${_sanitizeKey(key)}.cache');
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Sanitize key for file system
  String _sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }
}

/// Cache statistics
class CacheStats {
  final int memoryEntries;
  final int diskFiles;
  final int diskSizeBytes;

  CacheStats({
    required this.memoryEntries,
    required this.diskFiles,
    required this.diskSizeBytes,
  });

  String get diskSizeFormatted {
    if (diskSizeBytes < 1024) return '${diskSizeBytes}B';
    if (diskSizeBytes < 1024 * 1024) return '${(diskSizeBytes / 1024).toStringAsFixed(1)}KB';
    return '${(diskSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// Cache keys for common data types
class CacheKeys {
  static const String vehicleList = 'vehicle_list';
  static const String diagnosticReport = 'diagnostic_report';
  static const String chatHistory = 'chat_history';
  static const String userProfile = 'user_profile';
  static const String obd2Devices = 'obd2_devices';
  static const String nhtsaData = 'nhtsa_data';
  
  static String vehicleData(String vin) => 'vehicle_data_$vin';
  static String diagnosticData(String vin) => 'diagnostic_data_$vin';
  static String chatSession(String sessionId) => 'chat_session_$sessionId';
} 