import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;

class OBD2BluetoothService extends ChangeNotifier {
  // Bluetooth connection to OBD2 scanner
  BluetoothDevice? _obdDevice;
  BluetoothCharacteristic? _obdCharacteristic;
  BluetoothCharacteristic? _obdWriteCharacteristic;
  StreamSubscription<List<int>>? _dataSubscription;
  
  // Connection state
  bool _isConnected = false;
  bool _isScanning = false;
  String _connectionStatus = 'Disconnected';
  
  // Device discovery
  final List<BluetoothDevice> _availableDevices = [];
  BluetoothDevice? _selectedDevice;
  
  // Data storage
  final Map<String, dynamic> _liveData = {};
  
  // OBD2 Commands for common PIDs
  static const Map<String, String> obdCommands = {
    'rpm': '010C',
    'speed': '010D',
    'engine_temp': '0105',
    'fuel_level': '012F',
    'throttle_position': '0111',
    'intake_air_temp': '010F',
    'coolant_temp': '0105',
    'fuel_pressure': '010A',
    'dtc_count': '0101',
    'dtc_codes': '03',
  };
  
  // Getters
  bool get isConnected => _isConnected;
  bool get isScanning => _isScanning;
  String get connectionStatus => _connectionStatus;
  List<BluetoothDevice> get availableDevices => List.from(_availableDevices);
  BluetoothDevice? get selectedDevice => _selectedDevice;
  Map<String, dynamic> get liveData => Map.from(_liveData);
  
  @override
  void dispose() {
    disconnectFromOBD2();
    super.dispose();
  }
  
  /// Open device settings for permission management
  Future<void> openSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('Error opening settings: $e');
    }
  }
  
  /// Force Bluetooth permission request by attempting to access Bluetooth
  Future<bool> forceBluetoothPermissionRequest() async {
    try {
      debugPrint('🔵 Forcing Bluetooth permission request...');
      
      // Check adapter state first
      final adapterState = await FlutterBluePlus.adapterState.first;
      debugPrint('Adapter state before permission: $adapterState');
      
      // Try to get connected devices - this should trigger permission on iOS
      final connectedDevices = FlutterBluePlus.connectedDevices;
      debugPrint('Connected devices: ${connectedDevices.length}');
      
      // Try a quick scan - this should trigger permission
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 1));
      await Future.delayed(const Duration(milliseconds: 500));
      await FlutterBluePlus.stopScan();
      
      debugPrint('✅ Bluetooth access attempted - permission should have been requested');
      return true;
    } catch (e) {
      debugPrint('❌ Bluetooth access failed: $e');
      return false;
    }
  }
  
  /// Force Location permission request using location package
  Future<bool> forceLocationPermissionRequest() async {
    try {
      debugPrint('📍 Forcing Location permission request using location package...');
      
      final location = loc.Location();
      
      // Check if location service is enabled
      bool serviceEnabled = await location.serviceEnabled();
      debugPrint('Location service enabled: $serviceEnabled');
      
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        debugPrint('Location service enabled after request: $serviceEnabled');
        if (!serviceEnabled) {
          debugPrint('❌ Location service not enabled');
          return false;
        }
      }
      
      // Check permission status
      loc.PermissionStatus permissionGranted = await location.hasPermission();
      debugPrint('Current location permission: $permissionGranted');
      
      if (permissionGranted == loc.PermissionStatus.denied) {
        debugPrint('Requesting location permission...');
        permissionGranted = await location.requestPermission();
        debugPrint('Location permission after request: $permissionGranted');
      }
      
      if (permissionGranted == loc.PermissionStatus.granted || 
          permissionGranted == loc.PermissionStatus.grantedLimited) {
        debugPrint('✅ Location permission granted via location package');
        
        // Also try with permission_handler as backup
        final permissionHandlerStatus = await Permission.locationWhenInUse.status;
        debugPrint('Permission handler status: $permissionHandlerStatus');
        
        return true;
      } else {
        debugPrint('❌ Location permission not granted: $permissionGranted');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Location permission request failed: $e');
      return false;
    }
  }
  
  /// Request permissions again (useful for retry)
  Future<bool> requestPermissionsAgain() async {
    return await checkPermissions();
  }
  
  /// Check and request necessary permissions
  Future<bool> checkPermissions() async {
    try {
      if (Platform.isIOS) {
        return await _checkIOSPermissions();
      } else if (Platform.isAndroid) {
        return await _checkAndroidPermissions();
      }
      return false;
    } catch (e) {
      debugPrint('Permission check error: $e');
      return false;
    }
  }
  
  /// Check iOS permissions
  Future<bool> _checkIOSPermissions() async {
    debugPrint('Checking iOS permissions...');
    
    try {
      // Use location package for iOS as it's more reliable
      final location = loc.Location();
      
      // Check if location service is enabled
      bool serviceEnabled = await location.serviceEnabled();
      debugPrint('Location service enabled: $serviceEnabled');
      
      if (!serviceEnabled) {
        debugPrint('Location service not enabled');
        return false;
      }
      
      // Check permission status using location package
      loc.PermissionStatus permissionGranted = await location.hasPermission();
      debugPrint('Location permission (location package): $permissionGranted');
      
      if (permissionGranted == loc.PermissionStatus.granted || 
          permissionGranted == loc.PermissionStatus.grantedLimited) {
        debugPrint('✅ iOS permissions ready - Location granted via location package');
        return true;
      } else {
        debugPrint('❌ Location permission not granted: $permissionGranted');
        return false;
      }
    } catch (e) {
      debugPrint('Error checking iOS permissions: $e');
      return false;
    }
  }
  
  /// Check Android permissions
  Future<bool> _checkAndroidPermissions() async {
    debugPrint('Checking Android permissions...');
    
    // Check current permission status
    var bluetoothStatus = await Permission.bluetooth.status;
    var bluetoothScanStatus = await Permission.bluetoothScan.status;
    var bluetoothConnectStatus = await Permission.bluetoothConnect.status;
    var locationStatus = await Permission.location.status;
    
    debugPrint('Current Android permissions:');
    debugPrint('- Bluetooth: $bluetoothStatus');
    debugPrint('- Bluetooth Scan: $bluetoothScanStatus');
    debugPrint('- Bluetooth Connect: $bluetoothConnectStatus');
    debugPrint('- Location: $locationStatus');
    
    // Request permissions if not granted
    if (!bluetoothStatus.isGranted) {
      bluetoothStatus = await Permission.bluetooth.request();
      debugPrint('Bluetooth permission after request: $bluetoothStatus');
    }
    
    if (!bluetoothScanStatus.isGranted) {
      bluetoothScanStatus = await Permission.bluetoothScan.request();
      debugPrint('Bluetooth scan permission after request: $bluetoothScanStatus');
    }
    
    if (!bluetoothConnectStatus.isGranted) {
      bluetoothConnectStatus = await Permission.bluetoothConnect.request();
      debugPrint('Bluetooth connect permission after request: $bluetoothConnectStatus');
    }
    
    if (!locationStatus.isGranted) {
      locationStatus = await Permission.location.request();
      debugPrint('Location permission after request: $locationStatus');
    }
    
    final allGranted = bluetoothStatus.isGranted && 
                      bluetoothScanStatus.isGranted && 
                      bluetoothConnectStatus.isGranted &&
                      locationStatus.isGranted;
    
    debugPrint('Android permissions granted: $allGranted');
    
    if (!allGranted) {
      // Check if any permission is permanently denied
      if (bluetoothStatus.isPermanentlyDenied || 
          bluetoothScanStatus.isPermanentlyDenied || 
          bluetoothConnectStatus.isPermanentlyDenied ||
          locationStatus.isPermanentlyDenied) {
        debugPrint('⚠️  Some permissions are permanently denied. Please enable them in device settings.');
      }
    }
    
    return allGranted;
  }
  
  /// Scan for available OBD2 devices
  Future<bool> scanForDevices() async {
    if (_isScanning) return false;
    
    try {
      _isScanning = true;
      _availableDevices.clear();
      _updateStatus('Checking permissions...');
      
      // Check permissions first
      if (!await checkPermissions()) {
        _updateStatus('Permissions not granted');
        _isScanning = false;
        return false;
      }
      
      _updateStatus('Scanning for OBD2 devices...');
      
      // Check if Bluetooth is on
      final adapterState = await FlutterBluePlus.adapterState.first;
      debugPrint('Bluetooth adapter state: $adapterState');
      
      if (adapterState != BluetoothAdapterState.on) {
        _updateStatus('Bluetooth is off - please enable Bluetooth in device settings');
        _isScanning = false;
        return false;
      }
      
      debugPrint('Bluetooth is on, starting scan...');
      
      // Start scanning for devices - this should trigger Bluetooth permission on iOS
      debugPrint('Attempting to start Bluetooth scan...');
      try {
        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
        debugPrint('✅ Bluetooth scan started successfully');
      } catch (e) {
        debugPrint('❌ Bluetooth scan failed: $e');
        _updateStatus('Bluetooth scan failed: $e');
        _isScanning = false;
        return false;
      }
      
      // Listen for scan results
      final completer = Completer<bool>();
      late StreamSubscription subscription;
      
      subscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          final device = result.device;
          final deviceName = device.platformName.toLowerCase();
          
          // Look for OBD2 device names
          if (deviceName.contains('obd') || 
              deviceName.contains('elm327') ||
              deviceName.contains('obdii')) {
            
            // Check if device is already in the list
            if (!_availableDevices.any((d) => d.remoteId == device.remoteId)) {
              _availableDevices.add(device);
              debugPrint('Found OBD2 device: ${device.platformName} (${device.remoteId})');
              notifyListeners();
            }
          }
        }
      });
      
      // Timeout handling
      Timer(const Duration(seconds: 20), () {
        if (!completer.isCompleted) {
          subscription.cancel();
          FlutterBluePlus.stopScan();
          _updateStatus(_availableDevices.isEmpty 
              ? 'No OBD2 devices found' 
              : 'Found ${_availableDevices.length} OBD2 device(s)');
          _isScanning = false;
          notifyListeners();
          completer.complete(_availableDevices.isNotEmpty);
        }
      });
      
      return await completer.future;
      
    } catch (e) {
      _updateStatus('Scan error: $e');
      debugPrint('Device scan error: $e');
      _isScanning = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Select a device for connection
  void selectDevice(BluetoothDevice device) {
    _selectedDevice = device;
    _updateStatus('Selected: ${device.platformName}');
    notifyListeners();
  }
  
  /// Connect to the selected OBD2 device
  Future<bool> connectToSelectedDevice() async {
    if (_selectedDevice == null) {
      _updateStatus('No device selected');
      return false;
    }
    
    return await _connectToDevice(_selectedDevice!);
  }
  
  /// Internal method to connect to a specific device
  Future<bool> _connectToDevice(BluetoothDevice device) async {
    try {
      _updateStatus('Connecting to ${device.platformName}...');
      
      // Connect to device
      await device.connect();
      
      // Discover services
      final services = await device.discoverServices();
      
      // Look for UART service (commonly used by OBD2 adapters)
      for (BluetoothService service in services) {
        debugPrint('Found service: ${service.uuid.toString().toLowerCase()}');
        
        if (service.uuid.toString().toLowerCase().contains('ffe0') ||
            service.uuid.toString().toLowerCase().contains('1101') ||
            service.uuid.toString().toLowerCase().contains('fff0')) {
          
          debugPrint('Found compatible service: ${service.uuid}');
          
          BluetoothCharacteristic? writeChar;
          BluetoothCharacteristic? notifyChar;
          BluetoothCharacteristic? dualChar;
          
          // Look for characteristics
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            debugPrint('Found characteristic: ${characteristic.uuid} - write: ${characteristic.properties.write}, notify: ${characteristic.properties.notify}');
            
            // Check for dual-purpose characteristic (write AND notify)
            if (characteristic.properties.write && characteristic.properties.notify) {
              dualChar = characteristic;
            }
            // Check for write-only characteristic
            else if (characteristic.properties.write && !characteristic.properties.notify) {
              writeChar = characteristic;
            }
            // Check for notify-only characteristic
            else if (!characteristic.properties.write && characteristic.properties.notify) {
              notifyChar = characteristic;
            }
          }
          
          // Setup connection based on available characteristics
          if (dualChar != null) {
            // Single characteristic for both read and write (Scanner 2 pattern)
            debugPrint('Using dual-purpose characteristic: ${dualChar.uuid}');
            _obdDevice = device;
            _obdCharacteristic = dualChar;
            _obdWriteCharacteristic = dualChar;
            
            await dualChar.setNotifyValue(true);
            _dataSubscription = dualChar.onValueReceived.listen(_handleOBD2Data);
            
          } else if (writeChar != null && notifyChar != null) {
            // Separate characteristics for read and write (Scanner 1 pattern)
            debugPrint('Using separate characteristics - Write: ${writeChar.uuid}, Notify: ${notifyChar.uuid}');
            _obdDevice = device;
            _obdCharacteristic = notifyChar;
            _obdWriteCharacteristic = writeChar;
            
            await notifyChar.setNotifyValue(true);
            _dataSubscription = notifyChar.onValueReceived.listen(_handleOBD2Data);
            
          } else {
            debugPrint('No compatible characteristic combination found');
            continue;
          }
          
          _isConnected = true;
          _updateStatus('Connected to ${device.platformName}');
          
          // Initialize OBD2 connection
          await _initializeOBD2();
          
          notifyListeners();
          return true;
        }
      }
      
      _updateStatus('No compatible OBD2 service found');
      return false;
      
    } catch (e) {
      _updateStatus('Connection error: $e');
      debugPrint('Device connection error: $e');
      return false;
    }
  }
  
  /// Scan for and connect to OBD2 scanner via Bluetooth (legacy method)
  Future<bool> connectToOBD2Scanner() async {
    // Use the new scan method and auto-connect to first device found
    if (await scanForDevices() && _availableDevices.isNotEmpty) {
      selectDevice(_availableDevices.first);
      return await connectToSelectedDevice();
    }
    return false;
  }
  
  /// Initialize OBD2 connection with AT commands
  Future<void> _initializeOBD2() async {
    try {
      // Send initialization commands
      await sendOBD2Command('ATZ'); // Reset
      await Future.delayed(const Duration(milliseconds: 500));
      
      await sendOBD2Command('ATE0'); // Echo off
      await Future.delayed(const Duration(milliseconds: 100));
      
      await sendOBD2Command('ATL0'); // Linefeeds off
      await Future.delayed(const Duration(milliseconds: 100));
      
      await sendOBD2Command('ATS0'); // Spaces off
      await Future.delayed(const Duration(milliseconds: 100));
      
      await sendOBD2Command('ATSP0'); // Auto protocol
      await Future.delayed(const Duration(milliseconds: 100));
      
      debugPrint('OBD2 initialization complete');
    } catch (e) {
      debugPrint('OBD2 initialization error: $e');
    }
  }
  
  /// Send OBD2 command and get response
  Future<String> sendOBD2Command(String command) async {
    if (_obdCharacteristic == null || _obdWriteCharacteristic == null || !_isConnected) {
      throw Exception('OBD2 not connected');
    }
    
    try {
      final completer = Completer<String>();
      String responseBuffer = '';
      
      // Set up temporary listener for this command (always listen on the read characteristic)
      late StreamSubscription tempSubscription;
      tempSubscription = _obdCharacteristic!.onValueReceived.listen((data) {
        final response = String.fromCharCodes(data).trim();
        responseBuffer += response;
        
        // Check if response is complete (ends with > or contains ERROR)
        if (response.contains('>') || response.contains('ERROR') || response.contains('NO DATA')) {
          tempSubscription.cancel();
          if (!completer.isCompleted) {
            completer.complete(responseBuffer.replaceAll('>', '').trim());
          }
        }
      });
      
      // Send command using the write characteristic
      final commandBytes = '${command}\r'.codeUnits;
      await _obdWriteCharacteristic!.write(commandBytes);
      
      // Wait for response with timeout
      final response = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          tempSubscription.cancel();
          return 'TIMEOUT';
        },
      );
      
      return response;
    } catch (e) {
      debugPrint('OBD2 command error: $e');
      return 'ERROR';
    }
  }
  
  /// Handle incoming OBD2 data
  void _handleOBD2Data(List<int> data) {
    try {
      final response = String.fromCharCodes(data).trim();
      debugPrint('OBD2 Data received: $response');
      
      // Parse and store the data
      _parseOBD2Response(response);
      notifyListeners();
    } catch (e) {
      debugPrint('Data handling error: $e');
    }
  }
  
  /// Parse OBD2 response and update live data
  void _parseOBD2Response(String response) {
    try {
      // Remove spaces and normalize
      final cleanResponse = response.replaceAll(' ', '').toUpperCase();
      
      if (cleanResponse.length >= 6) {
        final pid = cleanResponse.substring(2, 4);
        final data = cleanResponse.substring(4);
        
        switch (pid) {
          case '0C': // RPM
            if (data.length >= 4) {
              final rpm = (int.parse(data.substring(0, 2), radix: 16) * 256 + 
                          int.parse(data.substring(2, 4), radix: 16)) / 4;
              _liveData['rpm'] = rpm.round();
            }
            break;
            
          case '0D': // Speed
            if (data.length >= 2) {
              _liveData['speed'] = int.parse(data.substring(0, 2), radix: 16);
            }
            break;
            
          case '05': // Engine temperature
            if (data.length >= 2) {
              _liveData['engine_temp'] = int.parse(data.substring(0, 2), radix: 16) - 40;
            }
            break;
            
          case '2F': // Fuel level
            if (data.length >= 2) {
              _liveData['fuel_level'] = (int.parse(data.substring(0, 2), radix: 16) * 100 / 255).round();
            }
            break;
            
          case '11': // Throttle position
            if (data.length >= 2) {
              _liveData['throttle_position'] = (int.parse(data.substring(0, 2), radix: 16) * 100 / 255).round();
            }
            break;
        }
      }
    } catch (e) {
      debugPrint('Response parsing error: $e');
    }
  }
  
  /// Read diagnostic trouble codes
  Future<List<String>> readDTCodes() async {
    try {
      final response = await sendOBD2Command('03');
      return _parseDTCodes(response);
    } catch (e) {
      debugPrint('DTC read error: $e');
      return [];
    }
  }
  
  /// Parse DTC codes from response
  List<String> _parseDTCodes(String response) {
    final codes = <String>[];
    try {
      final cleanResponse = response.replaceAll(' ', '').toUpperCase();
      
      // Parse DTC codes (simplified)
      for (int i = 0; i < cleanResponse.length - 4; i += 4) {
        final codeHex = cleanResponse.substring(i, i + 4);
        if (codeHex != '0000') {
          // Convert hex to DTC format (P0XXX, etc.)
          final code = _hexToDTC(codeHex);
          if (code.isNotEmpty) codes.add(code);
        }
      }
    } catch (e) {
      debugPrint('DTC parsing error: $e');
    }
    return codes;
  }
  
  /// Convert hex code to DTC format
  String _hexToDTC(String hex) {
    try {
      final code = int.parse(hex, radix: 16);
      final first = (code >> 14) & 0x03;
      final second = (code >> 12) & 0x03;
      final third = (code >> 8) & 0x0F;
      final fourth = code & 0xFF;
      
      String prefix;
      switch (first) {
        case 0: prefix = 'P0'; break;
        case 1: prefix = 'P1'; break;
        case 2: prefix = 'P2'; break;
        case 3: prefix = 'P3'; break;
        default: return '';
      }
      
      return '$prefix${second.toRadixString(16).toUpperCase()}${third.toRadixString(16).toUpperCase()}${fourth.toRadixString(16).padLeft(2, '0').toUpperCase()}';
    } catch (e) {
      return '';
    }
  }
  
  /// Request specific OBD2 data
  Future<void> requestData(String dataType) async {
    if (!_isConnected) return;
    
    final command = obdCommands[dataType];
    if (command != null) {
      try {
        await sendOBD2Command(command);
      } catch (e) {
        debugPrint('Data request error: $e');
      }
    }
  }
  
  /// Disconnect from OBD2 scanner
  Future<void> disconnectFromOBD2() async {
    try {
      _dataSubscription?.cancel();
      _dataSubscription = null;
      
      if (_obdDevice != null) {
        await _obdDevice!.disconnect();
        _obdDevice = null;
      }
      
      _obdCharacteristic = null;
      _obdWriteCharacteristic = null;
      _isConnected = false;
      _selectedDevice = null;
      _availableDevices.clear();
      _liveData.clear();
      _updateStatus('Disconnected from OBD2');
      
      notifyListeners();
    } catch (e) {
      debugPrint('Disconnect error: $e');
    }
  }
  
  /// Update connection status
  void _updateStatus(String status) {
    _connectionStatus = status;
    debugPrint('OBD2 Status: $status');
    notifyListeners();
  }
}