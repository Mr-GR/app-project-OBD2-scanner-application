// TODO: FIREBASE INTEGRATION
// When ready to integrate Firebase, uncomment:
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class OBD2Device {
  final String id;
  final String name;
  final String address;
  final bool isDefault;
  final DateTime lastConnected;
  final String? userId;

  OBD2Device({
    required this.id,
    required this.name,
    required this.address,
    this.isDefault = false,
    required this.lastConnected,
    this.userId,
  });

  factory OBD2Device.fromMap(String id, Map<String, dynamic> data) {
    return OBD2Device(
      id: id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      isDefault: data['isDefault'] ?? false,
      lastConnected: DateTime.parse(data['lastConnected']),
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'address': address,
    'isDefault': isDefault,
    'lastConnected': lastConnected.toIso8601String(),
    'userId': userId,
  };

  factory OBD2Device.fromBluetoothDevice(BluetoothDevice device, {String? userId}) {
    return OBD2Device(
      id: device.address,
      name: device.name ?? 'Unknown Device',
      address: device.address,
      lastConnected: DateTime.now(),
      userId: userId,
    );
  }
}

class OBD2DeviceSettings {
  final String userId;
  final bool autoConnect;
  final String? defaultDeviceId;
  final int connectionTimeout;

  OBD2DeviceSettings({
    required this.userId,
    this.autoConnect = true,
    this.defaultDeviceId,
    this.connectionTimeout = 30,
  });

  factory OBD2DeviceSettings.fromMap(String userId, Map<String, dynamic> data) {
    return OBD2DeviceSettings(
      userId: userId,
      autoConnect: data['autoConnect'] ?? true,
      defaultDeviceId: data['defaultDeviceId'],
      connectionTimeout: data['connectionTimeout'] ?? 30,
    );
  }

  Map<String, dynamic> toMap() => {
    'autoConnect': autoConnect,
    'defaultDeviceId': defaultDeviceId,
    'connectionTimeout': connectionTimeout,
  };
}

abstract class IOBD2DeviceService {
  Future<void> initialize();
  Future<List<OBD2Device>> getPairedDevices(String userId);
  Future<void> addDevice(String userId, OBD2Device device);
  Future<void> removeDevice(String userId, String deviceId);
  Future<void> setDefaultDevice(String userId, String deviceId);
  Future<OBD2DeviceSettings> getDeviceSettings(String userId);
  Future<void> updateDeviceSettings(String userId, Map<String, dynamic> settings);
  Future<void> updateLastConnected(String userId, String deviceId);
}

class OBD2DeviceService implements IOBD2DeviceService {
  // TODO: FIREBASE INTEGRATION
  // When ready to integrate Firebase, uncomment:
  // final _firestore = FirebaseFirestore.instance;

  // Mock data storage
  final List<OBD2Device> _mockDevices = [];
  final Map<String, OBD2DeviceSettings> _mockSettings = {};

  @override
  Future<void> initialize() async {
    // TODO: Implement initialization logic
  }

  @override
  Future<List<OBD2Device>> getPairedDevices(String userId) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final query = await _firestore
    //     .collection('obd2_devices')
    //     .where('userId', isEqualTo: userId)
    //     .orderBy('lastConnected', descending: true)
    //     .get();
    // return query.docs.map((doc) => OBD2Device.fromMap(doc.id, doc.data())).toList();

    return _mockDevices.where((device) => device.userId == userId).toList();
  }

  @override
  Future<void> addDevice(String userId, OBD2Device device) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final deviceData = device.toMap();
    // deviceData['userId'] = userId;
    // await _firestore.collection('obd2_devices').doc(device.id).set(deviceData);

    _mockDevices.add(device);
  }

  @override
  Future<void> removeDevice(String userId, String deviceId) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // await _firestore.collection('obd2_devices').doc(deviceId).delete();
    // final settings = await getDeviceSettings(userId);
    // if (settings.defaultDeviceId == deviceId) {
    //   await updateDeviceSettings(userId, {'defaultDeviceId': null});
    // }

    _mockDevices.removeWhere((device) => device.id == deviceId && device.userId == userId);
  }

  @override
  Future<void> setDefaultDevice(String userId, String deviceId) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final devices = await getPairedDevices(userId);
    // for (final device in devices) {
    //   if (device.isDefault) {
    //     await _firestore.collection('obd2_devices').doc(device.id).update({'isDefault': false});
    //   }
    // }
    // await _firestore.collection('obd2_devices').doc(deviceId).update({'isDefault': true});
    // await updateDeviceSettings(userId, {'defaultDeviceId': deviceId});

    // Clear existing defaults
    for (final device in _mockDevices) {
      if (device.userId == userId && device.isDefault) {
        _mockDevices[_mockDevices.indexOf(device)] = OBD2Device(
          id: device.id,
          name: device.name,
          address: device.address,
          isDefault: false,
          lastConnected: device.lastConnected,
          userId: device.userId,
        );
      }
    }
    
    // Set new default
    final deviceIndex = _mockDevices.indexWhere((device) => device.id == deviceId);
    if (deviceIndex != -1) {
      final device = _mockDevices[deviceIndex];
      _mockDevices[deviceIndex] = OBD2Device(
        id: device.id,
        name: device.name,
        address: device.address,
        isDefault: true,
        lastConnected: device.lastConnected,
        userId: device.userId,
      );
    }
  }

  @override
  Future<OBD2DeviceSettings> getDeviceSettings(String userId) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final doc = await _firestore.collection('obd2_settings').doc(userId).get();
    // if (!doc.exists) {
    //   return OBD2DeviceSettings(userId: userId);
    // }
    // return OBD2DeviceSettings.fromMap(userId, doc.data()!);

    return _mockSettings[userId] ?? OBD2DeviceSettings(userId: userId);
  }

  @override
  Future<void> updateDeviceSettings(String userId, Map<String, dynamic> settings) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // await _firestore.collection('obd2_settings').doc(userId).set(settings, SetOptions(merge: true));

    final existing = _mockSettings[userId] ?? OBD2DeviceSettings(userId: userId);
    _mockSettings[userId] = OBD2DeviceSettings(
      userId: userId,
      autoConnect: settings['autoConnect'] ?? existing.autoConnect,
      defaultDeviceId: settings['defaultDeviceId'] ?? existing.defaultDeviceId,
      connectionTimeout: settings['connectionTimeout'] ?? existing.connectionTimeout,
    );
  }

  @override
  Future<void> updateLastConnected(String userId, String deviceId) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // await _firestore.collection('obd2_devices').doc(deviceId).update({
    //   'lastConnected': DateTime.now().toIso8601String(),
    // });

    final deviceIndex = _mockDevices.indexWhere((device) => device.id == deviceId);
    if (deviceIndex != -1) {
      final device = _mockDevices[deviceIndex];
      _mockDevices[deviceIndex] = OBD2Device(
        id: device.id,
        name: device.name,
        address: device.address,
        isDefault: device.isDefault,
        lastConnected: DateTime.now(),
        userId: device.userId,
      );
    }
  }
}

class MockOBD2DeviceService implements IOBD2DeviceService {
  final List<OBD2Device> _mockDevices = [];
  final Map<String, OBD2DeviceSettings> _mockSettings = {};

  @override
  Future<void> initialize() async {
    // TODO: Implement initialization logic
  }

  @override
  Future<List<OBD2Device>> getPairedDevices(String userId) async {
    return _mockDevices.where((device) => device.userId == userId).toList();
  }

  @override
  Future<void> addDevice(String userId, OBD2Device device) async {
    _mockDevices.add(device);
  }

  @override
  Future<void> removeDevice(String userId, String deviceId) async {
    _mockDevices.removeWhere((device) => device.id == deviceId && device.userId == userId);
  }

  @override
  Future<void> setDefaultDevice(String userId, String deviceId) async {
    // Clear existing defaults
    for (final device in _mockDevices) {
      if (device.userId == userId && device.isDefault) {
        _mockDevices[_mockDevices.indexOf(device)] = OBD2Device(
          id: device.id,
          name: device.name,
          address: device.address,
          isDefault: false,
          lastConnected: device.lastConnected,
          userId: device.userId,
        );
      }
    }
    
    // Set new default
    final deviceIndex = _mockDevices.indexWhere((device) => device.id == deviceId);
    if (deviceIndex != -1) {
      final device = _mockDevices[deviceIndex];
      _mockDevices[deviceIndex] = OBD2Device(
        id: device.id,
        name: device.name,
        address: device.address,
        isDefault: true,
        lastConnected: device.lastConnected,
        userId: device.userId,
      );
    }
  }

  @override
  Future<OBD2DeviceSettings> getDeviceSettings(String userId) async {
    return _mockSettings[userId] ?? OBD2DeviceSettings(userId: userId);
  }

  @override
  Future<void> updateDeviceSettings(String userId, Map<String, dynamic> settings) async {
    final existing = _mockSettings[userId] ?? OBD2DeviceSettings(userId: userId);
    _mockSettings[userId] = OBD2DeviceSettings(
      userId: userId,
      autoConnect: settings['autoConnect'] ?? existing.autoConnect,
      defaultDeviceId: settings['defaultDeviceId'] ?? existing.defaultDeviceId,
      connectionTimeout: settings['connectionTimeout'] ?? existing.connectionTimeout,
    );
  }

  @override
  Future<void> updateLastConnected(String userId, String deviceId) async {
    final deviceIndex = _mockDevices.indexWhere((device) => device.id == deviceId);
    if (deviceIndex != -1) {
      final device = _mockDevices[deviceIndex];
      _mockDevices[deviceIndex] = OBD2Device(
        id: device.id,
        name: device.name,
        address: device.address,
        isDefault: device.isDefault,
        lastConnected: DateTime.now(),
        userId: device.userId,
      );
    }
  }
} 