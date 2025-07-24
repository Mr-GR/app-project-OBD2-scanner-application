import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import '../config.dart';

class OBD2BluetoothService extends ChangeNotifier {
  // Singleton instance
  static OBD2BluetoothService? _instance;
  
  // Private constructor
  OBD2BluetoothService._internal();
  
  // Factory constructor to return singleton instance
  factory OBD2BluetoothService() {
    _instance ??= OBD2BluetoothService._internal();
    return _instance!;
  }
  
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
  int? _lastBackendUpdate;
  
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
    'vin': '0902',  // VIN number request
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
      
      // Check if Bluetooth is on with retry for timing issues
      BluetoothAdapterState adapterState = await FlutterBluePlus.adapterState.first;
      debugPrint('Bluetooth adapter state: $adapterState');
      
      // Retry if adapter state is unknown (common on app start)
      if (adapterState == BluetoothAdapterState.unknown) {
        debugPrint('Bluetooth adapter state unknown, waiting for update...');
        await Future.delayed(const Duration(milliseconds: 1000));
        adapterState = await FlutterBluePlus.adapterState.first;
        debugPrint('Bluetooth adapter state after retry: $adapterState');
      }
      
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
          
          // 🔥 BACKEND INTEGRATION - Update backend connection status
          await _updateBackendConnectionStatus(true);
          
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
      debugPrint('🔧 Starting OBD2 initialization sequence...');
      
      // Method 1: Standard initialization
      await _tryStandardInitialization();
      
      // Test if standard initialization worked
      await Future.delayed(const Duration(milliseconds: 1000));
      final testResponse = await sendOBD2Command('0100');
      debugPrint('🔧 Test response after standard init: $testResponse');
      
      if (testResponse.contains('STOPPED') || testResponse.contains('ERROR')) {
        debugPrint('🔧 Standard init failed, trying alternative sequence...');
        await _tryAlternativeInitialization();
      }
      
      debugPrint('✅ OBD2 initialization complete');
    } catch (e) {
      debugPrint('❌ OBD2 initialization error: $e');
    }
  }
  
  /// Try standard ELM327 initialization
  Future<void> _tryStandardInitialization() async {
    debugPrint('🔧 Trying standard ELM327 initialization...');
    
    await sendOBD2Command('ATZ'); // Reset
    await Future.delayed(const Duration(milliseconds: 1000));
    
    await sendOBD2Command('ATE0'); // Echo off
    await Future.delayed(const Duration(milliseconds: 200));
    
    await sendOBD2Command('ATL0'); // Linefeeds off
    await Future.delayed(const Duration(milliseconds: 200));
    
    await sendOBD2Command('ATS0'); // Spaces off
    await Future.delayed(const Duration(milliseconds: 200));
    
    await sendOBD2Command('ATSP0'); // Auto protocol
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  /// Try alternative initialization sequence
  Future<void> _tryAlternativeInitialization() async {
    debugPrint('🔧 Trying alternative initialization sequence...');
    
    // Reset again
    await sendOBD2Command('ATZ');
    await Future.delayed(const Duration(milliseconds: 2000)); // Longer delay
    
    // Try with different settings
    await sendOBD2Command('ATE0'); // Echo off
    await Future.delayed(const Duration(milliseconds: 300));
    
    await sendOBD2Command('ATL1'); // Linefeeds on (sometimes needed)
    await Future.delayed(const Duration(milliseconds: 300));
    
    await sendOBD2Command('ATS1'); // Spaces on (sometimes needed)
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Try specific protocol instead of auto
    await sendOBD2Command('ATSP6'); // ISO 15765-4 CAN (most common)
    await Future.delayed(const Duration(milliseconds: 500));
    
    // If that fails, try ISO 9141
    final testResponse = await sendOBD2Command('0100');
    if (testResponse.contains('STOPPED') || testResponse.contains('ERROR')) {
      debugPrint('🔧 CAN protocol failed, trying ISO 9141...');
      await sendOBD2Command('ATSP3'); // ISO 9141-2
      await Future.delayed(const Duration(milliseconds: 500));
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
  
  /// Parse OBD2 response following SAE J1979 and ISO 15031-5 standards
  void _parseOBD2Response(String response) {
    try {
      debugPrint('🔍 Raw OBD2 response: "$response"');
      
      // Clean response for analysis
      final cleanResponse = response.replaceAll(' ', '').replaceAll('\n', '').replaceAll('\r', '').toUpperCase();
      
      // 1. Skip empty responses and terminators
      if (cleanResponse.isEmpty || cleanResponse == '>') {
        return;
      }
      
      // 2. Handle ELM327 AT command responses (initialization)
      if (_isATCommandResponse(response)) {
        debugPrint('✅ AT command response: "${response.trim()}"');
        return;
      }
      
      // 3. Handle error responses
      if (_isErrorResponse(response)) {
        debugPrint('❌ Error response: "${response.trim()}"');
        return;
      }
      
      // 4. Handle multi-frame responses (contains colons)
      if (response.contains(':')) {
        // Multi-frame response - check for Service 09 (VIN)
        if (response.contains('49 02')) {
          _parseService09Response(response);
          return;
        }
        // Multi-frame response - check for Service 03 (DTC)
        if (response.contains('43 03') || response.contains('43 00')) {
          debugPrint('🔍 Multi-frame DTC response detected, will be handled by readDTCodes method');
          return;
        }
      }
      
      // 5. Handle OBD2 data responses by service mode
      if (cleanResponse.length >= 2) {
        final serviceMode = cleanResponse.substring(0, 2);
        
        switch (serviceMode) {
          case '41': // Service 01 response (current data)
            _parseService01Response(cleanResponse);
            break;
            
          case '43': // Service 03 response (DTCs)
            debugPrint('🔍 DTC response detected, will be handled by readDTCodes method');
            break;
            
          case '49': // Service 09 response (vehicle info)
            _parseService09Response(cleanResponse);
            break;
            
          default:
            debugPrint('🔍 Unknown service mode: $serviceMode in response: $cleanResponse');
            break;
        }
      }
      
      // 5. Backend integration - throttled updates
      _handleBackendUpdate();
      
    } catch (e) {
      debugPrint('❌ Response parsing error: $e');
    }
  }
  
  /// Check if response is an AT command response
  bool _isATCommandResponse(String response) {
    return response.contains('ELM327') ||
           response.contains('OK') ||
           response.contains('ATE0') ||
           response.contains('ATL') ||
           response.contains('ATS') ||
           response.contains('ATSP') ||
           response.contains('ATZ') ||
           response.contains('BUS INIT') ||
           response.contains('v2.') ||
           response.contains('v1.');
  }
  
  /// Check if response is an error response
  bool _isErrorResponse(String response) {
    return response.contains('UNABLE TO') || 
           response.contains('CONNECT') || 
           response.contains('SEARCHING') ||
           response.contains('STOPPED') ||
           response.contains('ERROR') ||
           response.contains('NO DATA') ||
           response.contains('?');
  }
  
  /// Parse Service 01 responses (current data) following SAE J1979
  void _parseService01Response(String response) {
    try {
      // Service 01 format: 41 PID DATA
      if (response.length < 4) return;
      
      final pid = response.substring(2, 4);
      final data = response.substring(4);
      
      debugPrint('🔍 Service 01 - PID: $pid, Data: $data');
      
      switch (pid) {
        case '00': // Supported PIDs 01-20
          debugPrint('✅ Supported PIDs 01-20: $data');
          break;
          
        case '0C': // Engine RPM
          if (data.length >= 4) {
            final rpm = (int.parse(data.substring(0, 2), radix: 16) * 256 + 
                        int.parse(data.substring(2, 4), radix: 16)) / 4;
            _liveData['rpm'] = rpm.round();
            debugPrint('✅ Engine RPM: ${_liveData['rpm']}');
          }
          break;
          
        case '0D': // Vehicle Speed
          if (data.length >= 2) {
            _liveData['speed'] = int.parse(data.substring(0, 2), radix: 16);
            debugPrint('✅ Vehicle Speed: ${_liveData['speed']} km/h');
          }
          break;
          
        case '05': // Engine Coolant Temperature
          if (data.length >= 2) {
            _liveData['engine_temp'] = int.parse(data.substring(0, 2), radix: 16) - 40;
            debugPrint('✅ Engine Coolant Temp: ${_liveData['engine_temp']}°C');
          }
          break;
          
        case '2F': // Fuel Level Input
          if (data.length >= 2) {
            _liveData['fuel_level'] = (int.parse(data.substring(0, 2), radix: 16) * 100 / 255).round();
            debugPrint('✅ Fuel Level: ${_liveData['fuel_level']}%');
          }
          break;
          
        case '11': // Throttle Position
          if (data.length >= 2) {
            _liveData['throttle_position'] = (int.parse(data.substring(0, 2), radix: 16) * 100 / 255).round();
            debugPrint('✅ Throttle Position: ${_liveData['throttle_position']}%');
          }
          break;
          
        case '0F': // Intake Air Temperature
          if (data.length >= 2) {
            _liveData['intake_air_temp'] = int.parse(data.substring(0, 2), radix: 16) - 40;
            debugPrint('✅ Intake Air Temp: ${_liveData['intake_air_temp']}°C');
          }
          break;
          
        case '0A': // Fuel Pressure
          if (data.length >= 2) {
            _liveData['fuel_pressure'] = int.parse(data.substring(0, 2), radix: 16) * 3;
            debugPrint('✅ Fuel Pressure: ${_liveData['fuel_pressure']} kPa');
          }
          break;
          
        case '01': // Monitor status since DTCs cleared
          debugPrint('✅ Monitor status: $data');
          break;
          
        case '20': // Supported PIDs 21-40
        case '40': // Supported PIDs 41-60
        case '60': // Supported PIDs 61-80
        case '80': // Supported PIDs 81-A0
        case 'A0': // Supported PIDs A1-C0
        case 'C0': // Supported PIDs C1-E0
          debugPrint('✅ Supported PIDs: $data');
          break;
          
        default:
          debugPrint('🔍 Unknown PID $pid: $data');
          break;
      }
    } catch (e) {
      debugPrint('❌ Service 01 parsing error: $e');
    }
  }
  
  /// Parse Service 09 responses (vehicle information)
  void _parseService09Response(String response) {
    try {
      // For multi-frame responses, we need to handle the full response
      if (response.contains(':')) {
        // Multi-frame response (VIN)
        _parseVINResponse(response);
        return;
      }
      
      if (response.length < 4) return;
      
      final pid = response.substring(2, 4);
      final data = response.substring(4);
      
      debugPrint('🔍 Service 09 - PID: $pid, Data: $data');
      
      switch (pid) {
        case '02': // VIN
          _parseVINResponse(response);
          break;
          
        case '04': // Calibration ID
          debugPrint('✅ Calibration ID: $data');
          break;
          
        case '0A': // ECU Name
          debugPrint('✅ ECU Name: $data');
          break;
          
        default:
          debugPrint('🔍 Unknown Service 09 PID $pid: $data');
          break;
      }
    } catch (e) {
      debugPrint('❌ Service 09 parsing error: $e');
    }
  }
  
  /// Handle backend updates with throttling
  void _handleBackendUpdate() {
    if (_liveData.isNotEmpty && _liveData.length >= 2) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (_lastBackendUpdate == null || now - _lastBackendUpdate! > 5000) { // 5 seconds
        _sendLiveDataToBackend(_liveData);
        _lastBackendUpdate = now;
      }
    }
  }
  
  /// Parse VIN response (multi-frame response handling)
  void _parseVINResponse(String response) {
    try {
      debugPrint('🔍 Parsing VIN response: $response');
      
      // VIN response is typically multi-frame with ISO-TP format
      // Example: "0: 49 02 01 31 43 34 \n1: 52 4A 45 4247 58 45 \n2: 43 3335 38 38 38 35"
      
      // Extract frames using pattern matching for frame numbers
      final hexData = <String>[];
      
      // Split response into lines using multiple delimiters
      final lines = response.split(RegExp(r'[\n\r]+'));
      
      for (String line in lines) {
        line = line.trim();
        debugPrint('🔍 Processing line: "$line"');
        
        if (line.isEmpty || line.startsWith('>') || line == '014') continue;
        
        // Look for frame pattern: digit followed by colon
        final frameMatch = RegExp(r'^(\d+):(.+)$').firstMatch(line);
        if (frameMatch != null) {
          final frameData = frameMatch.group(2)?.trim().replaceAll(' ', '');
          if (frameData != null && frameData.isNotEmpty) {
            hexData.add(frameData);
            debugPrint('🔍 Added frame ${frameMatch.group(1)} data: $frameData');
          }
        }
      }
      
      if (hexData.isEmpty) {
        debugPrint('❌ No VIN hex data found in response');
        return;
      }
      
      // Join all hex data and remove spaces
      final allHexData = hexData.join(' ').replaceAll('  ', ' ').trim().toUpperCase();
      debugPrint('🔍 Combined VIN hex data: $allHexData');
      
      // Also try to join without spaces for parsing
      final allHexDataNoSpaces = allHexData.replaceAll(' ', '');
      debugPrint('🔍 Combined VIN hex data (no spaces): $allHexDataNoSpaces');
      
      // Handle multi-frame VIN parsing specifically
      String vinData = '';
      
      // Process each frame separately for VIN data
      for (int i = 0; i < hexData.length; i++) {
        String frameData = hexData[i].replaceAll(' ', '').toUpperCase();
        debugPrint('🔍 Processing frame $i: $frameData');
        
        if (i == 0) {
          // First frame: should contain 4902 + length + first VIN bytes
          if (frameData.startsWith('4902')) {
            // Skip service identifier (4902) and length byte (usually 01)
            if (frameData.length > 6) { // 4902 + 01 + data
              vinData += frameData.substring(6);
              debugPrint('🔍 Frame 0 VIN data: ${frameData.substring(6)}');
            }
          }
        } else {
          // Subsequent frames: all data is VIN
          vinData += frameData;
          debugPrint('🔍 Frame $i VIN data: $frameData');
        }
      }
      
      debugPrint('🔍 VIN data after processing: $vinData');
      
      // Convert hex to ASCII characters
      final vinChars = <String>[];
      for (int i = 0; i < vinData.length - 1; i += 2) {
        final hexByte = vinData.substring(i, i + 2);
        try {
          final charCode = int.parse(hexByte, radix: 16);
          // Valid VIN characters: A-Z, 0-9 (printable ASCII)
          if ((charCode >= 48 && charCode <= 57) || // 0-9
              (charCode >= 65 && charCode <= 90)) { // A-Z
            vinChars.add(String.fromCharCode(charCode));
          }
          debugPrint('🔍 VIN hex byte: $hexByte -> char code: $charCode -> char: ${String.fromCharCode(charCode)}');
        } catch (e) {
          debugPrint('❌ Failed to parse VIN hex byte: $hexByte, error: $e');
          continue;
        }
      }
      
      debugPrint('🔍 VIN characters found: ${vinChars.join()} (${vinChars.length} chars)');
      
      if (vinChars.length >= 8) { // Accept partial VIN (minimum 8 characters)
        final vin = vinChars.join();
        _liveData['vin'] = vin;
        debugPrint('✅ VIN parsed successfully: $vin (${vinChars.length} characters)');
        notifyListeners();
      } else {
        debugPrint('❌ VIN parsing failed: insufficient data. Chars found: ${vinChars.length}');
        debugPrint('   VIN data: $vinData');
        debugPrint('   Chars: ${vinChars.join()}');
        
        // Let's try a different approach - parse all hex data as ASCII
        debugPrint('🔍 Attempting alternative VIN parsing...');
        final allVinChars = <String>[];
        final cleanHexData = allHexDataNoSpaces.replaceAll('4902', '').replaceAll('01', '');
        
        for (int i = 0; i < cleanHexData.length - 1; i += 2) {
          final hexByte = cleanHexData.substring(i, i + 2);
          try {
            final charCode = int.parse(hexByte, radix: 16);
            // Valid VIN characters: A-Z, 0-9 (printable ASCII)
            if ((charCode >= 48 && charCode <= 57) || // 0-9
                (charCode >= 65 && charCode <= 90)) { // A-Z
              allVinChars.add(String.fromCharCode(charCode));
            }
            debugPrint('🔍 Alt VIN hex byte: $hexByte -> char code: $charCode -> char: ${String.fromCharCode(charCode)}');
          } catch (e) {
            continue;
          }
        }
        
        debugPrint('🔍 Alternative parsing found: ${allVinChars.join()} (${allVinChars.length} chars)');
        
        if (allVinChars.length >= 8) {
          final altVin = allVinChars.join();
          _liveData['vin'] = altVin;
          debugPrint('✅ VIN parsed successfully with alternative method: $altVin');
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('❌ VIN parsing error: $e');
    }
  }
  
  /// Send live data to backend after parsing OBD2 response
  Future<void> _sendLiveDataToBackend(Map<String, dynamic> liveData) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/scanner/live-data'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rpm': liveData['rpm'],
          'vin': liveData['vin'],
          'engine_temp': liveData['engine_temp'],
          'fuel_level': liveData['fuel_level'],
          'throttle_position': liveData['throttle_position'],
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200) {
        debugPrint('✅ Live data sent to backend successfully');
      } else {
        debugPrint('❌ Backend responded with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Backend relay error: $e');
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
      debugPrint('🔍 Parsing DTC response: "$response"');
      
      // Handle multi-frame responses (contains colons)
      if (response.contains(':')) {
        return _parseMultiFrameDTCodes(response);
      }
      
      // Clean response and handle single-frame responses
      final cleanResponse = response.replaceAll(' ', '').replaceAll('\n', '').replaceAll('\r', '').toUpperCase();
      debugPrint('🔍 Cleaned DTC response: "$cleanResponse"');
      
      // DTC response format: 43XXYYZZ where XX YY ZZ are DTC codes
      // Skip the first 2 characters (43 = service response)
      if (cleanResponse.length >= 4 && cleanResponse.startsWith('43')) {
        String dtcData = cleanResponse.substring(2);
        
        // Remove any trailing response indicators
        dtcData = dtcData.replaceAll('4300', ''); // Remove end-of-response indicator
        dtcData = dtcData.replaceAll('>', '');
        
        debugPrint('🔍 DTC data to parse: "$dtcData"');
        
        // Parse DTC codes in pairs of 4 hex characters
        for (int i = 0; i < dtcData.length - 3; i += 4) {
          if (i + 4 <= dtcData.length) {
            final codeHex = dtcData.substring(i, i + 4);
            if (codeHex != '0000' && codeHex.length == 4) {
              // Convert hex to DTC format (P0XXX, etc.)
              final code = _hexToDTC(codeHex);
              if (code.isNotEmpty) {
                codes.add(code);
                debugPrint('✅ Parsed DTC code: $codeHex -> $code');
              }
            }
          }
        }
      }
      
      debugPrint('🔍 Total DTC codes parsed: ${codes.length}');
    } catch (e) {
      debugPrint('DTC parsing error: $e');
    }
    return codes;
  }
  
  /// Parse multi-frame DTC codes (ISO-TP format)
  List<String> _parseMultiFrameDTCodes(String response) {
    final codes = <String>[];
    try {
      debugPrint('🔍 Parsing multi-frame DTC response: "$response"');
      
      // Extract hex data from each frame
      final lines = response.split('\n');
      final hexData = <String>[];
      
      for (final line in lines) {
        // Skip empty lines
        if (line.trim().isEmpty) continue;
        
        // Look for lines with frame data (contains colons)
        if (line.contains(':')) {
          final parts = line.split(':');
          if (parts.length >= 2) {
            // Extract hex data after the colon
            final hexPart = parts[1].trim();
            if (hexPart.isNotEmpty) {
              hexData.add(hexPart);
            }
          }
        } else {
          // Single line format - just hex data
          final trimmed = line.trim();
          if (trimmed.isNotEmpty && !trimmed.startsWith('>')) {
            hexData.add(trimmed);
          }
        }
      }
      
      if (hexData.isEmpty) {
        debugPrint('❌ No DTC hex data found in multi-frame response');
        return codes;
      }
      
      // Join all hex data and remove spaces
      final allHexData = hexData.join(' ').replaceAll(' ', '').toUpperCase();
      debugPrint('🔍 Combined DTC hex data: $allHexData');
      
      // Look for Service 03 response (43)
      int startIndex = allHexData.indexOf('43');
      if (startIndex == -1) {
        debugPrint('❌ DTC service mode 43 not found in response');
        return codes;
      }
      
      // Extract DTC data after 43
      String dtcData = allHexData.substring(startIndex + 2);
      
      // Remove end-of-response indicators
      dtcData = dtcData.replaceAll('4300', ''); // Remove end-of-response indicator
      dtcData = dtcData.replaceAll('>', '');
      
      debugPrint('🔍 Multi-frame DTC data to parse: "$dtcData"');
      
      // Parse DTC codes in pairs of 4 hex characters
      for (int i = 0; i < dtcData.length - 3; i += 4) {
        if (i + 4 <= dtcData.length) {
          final codeHex = dtcData.substring(i, i + 4);
          if (codeHex != '0000' && codeHex.length == 4) {
            // Convert hex to DTC format (P0XXX, etc.)
            final code = _hexToDTC(codeHex);
            if (code.isNotEmpty) {
              codes.add(code);
              debugPrint('✅ Parsed multi-frame DTC code: $codeHex -> $code');
            }
          }
        }
      }
      
      debugPrint('🔍 Total multi-frame DTC codes parsed: ${codes.length}');
    } catch (e) {
      debugPrint('❌ Multi-frame DTC parsing error: $e');
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
  
  /// Get DTC description from code
  String getDTCDescription(String code) {
    final dtcDescriptions = {
      'P0000': 'No diagnostic trouble codes stored',
      'P0001': 'Fuel Volume Regulator Control Circuit/Open',
      'P0002': 'Fuel Volume Regulator Control Circuit Range/Performance',
      'P0003': 'Fuel Volume Regulator Control Circuit Low',
      'P0004': 'Fuel Volume Regulator Control Circuit High',
      'P0005': 'Fuel Shutoff Valve A Control Circuit/Open',
      'P0006': 'Fuel Shutoff Valve A Control Circuit Low',
      'P0007': 'Fuel Shutoff Valve A Control Circuit High',
      'P0008': 'Engine Position System Performance Bank 1',
      'P0009': 'Engine Position System Performance Bank 2',
      'P0010': 'A Camshaft Position Actuator Circuit (Bank 1)',
      'P0011': 'A Camshaft Position Timing Over-Advanced or System Performance (Bank 1)',
      'P0012': 'A Camshaft Position Timing Over-Retarded (Bank 1)',
      'P0013': 'B Camshaft Position Actuator Circuit (Bank 1)',
      'P0014': 'B Camshaft Position Timing Over-Advanced or System Performance (Bank 1)',
      'P0015': 'B Camshaft Position Timing Over-Retarded (Bank 1)',
      'P0016': 'Crankshaft Position Camshaft Position Correlation Bank 1 Sensor A',
      'P0017': 'Crankshaft Position Camshaft Position Correlation Bank 1 Sensor B',
      'P0018': 'Crankshaft Position Camshaft Position Correlation Bank 2 Sensor A',
      'P0019': 'Crankshaft Position Camshaft Position Correlation Bank 2 Sensor B',
      'P0020': 'A Camshaft Position Actuator Circuit (Bank 2)',
      'P0100': 'Mass or Volume Air Flow Circuit Malfunction',
      'P0101': 'Mass or Volume Air Flow Circuit Range/Performance Problem',
      'P0102': 'Mass or Volume Air Flow Circuit Low Input',
      'P0103': 'Mass or Volume Air Flow Circuit High Input',
      'P0104': 'Mass or Volume Air Flow Circuit Intermittent',
      'P0105': 'Manifold Absolute Pressure/Barometric Pressure Circuit Malfunction',
      'P0106': 'Manifold Absolute Pressure/Barometric Pressure Circuit Range/Performance Problem',
      'P0107': 'Manifold Absolute Pressure/Barometric Pressure Circuit Low Input',
      'P0108': 'Manifold Absolute Pressure/Barometric Pressure Circuit High Input',
      'P0109': 'Manifold Absolute Pressure/Barometric Pressure Circuit Intermittent',
      'P0110': 'Intake Air Temperature Circuit Malfunction',
      'P0111': 'Intake Air Temperature Circuit Range/Performance Problem',
      'P0112': 'Intake Air Temperature Circuit Low Input',
      'P0113': 'Intake Air Temperature Circuit High Input',
      'P0114': 'Intake Air Temperature Circuit Intermittent',
      'P0115': 'Engine Coolant Temperature Circuit Malfunction',
      'P0116': 'Engine Coolant Temperature Circuit Range/Performance Problem',
      'P0117': 'Engine Coolant Temperature Circuit Low Input',
      'P0118': 'Engine Coolant Temperature Circuit High Input',
      'P0119': 'Engine Coolant Temperature Circuit Intermittent',
      'P0120': 'Throttle/Pedal Position Sensor Switch A Circuit Malfunction',
      'P0121': 'Throttle/Pedal Position Sensor Switch A Circuit Range/Performance Problem',
      'P0122': 'Throttle/Pedal Position Sensor Switch A Circuit Low Input',
      'P0123': 'Throttle/Pedal Position Sensor Switch A Circuit High Input',
      'P0124': 'Throttle/Pedal Position Sensor Switch A Circuit Intermittent',
      'P0125': 'Insufficient Coolant Temperature for Closed Loop Fuel Control',
      'P0126': 'Insufficient Coolant Temperature for Stable Operation',
      'P0127': 'Intake Air Temperature Too High',
      'P0128': 'Coolant Thermostat (Coolant Temperature Below Thermostat Regulating Temperature)',
      'P0129': 'Intake Air Temperature Too Low',
      'P0130': 'O2 Sensor Circuit Malfunction (Bank 1 Sensor 1)',
      'P0131': 'O2 Sensor Circuit Low Voltage (Bank 1 Sensor 1)',
      'P0132': 'O2 Sensor Circuit High Voltage (Bank 1 Sensor 1)',
      'P0133': 'O2 Sensor Circuit Slow Response (Bank 1 Sensor 1)',
      'P0134': 'O2 Sensor Circuit No Activity Detected (Bank 1 Sensor 1)',
      'P0135': 'O2 Sensor Heater Circuit Malfunction (Bank 1 Sensor 1)',
      'P0136': 'O2 Sensor Circuit Malfunction (Bank 1 Sensor 2)',
      'P0137': 'O2 Sensor Circuit Low Voltage (Bank 1 Sensor 2)',
      'P0138': 'O2 Sensor Circuit High Voltage (Bank 1 Sensor 2)',
      'P0139': 'O2 Sensor Circuit Slow Response (Bank 1 Sensor 2)',
      'P0140': 'O2 Sensor Circuit No Activity Detected (Bank 1 Sensor 2)',
      'P0141': 'O2 Sensor Heater Circuit Malfunction (Bank 1 Sensor 2)',
      'P0142': 'O2 Sensor Circuit Malfunction (Bank 1 Sensor 3)',
      'P0143': 'O2 Sensor Circuit Low Voltage (Bank 1 Sensor 3)',
      'P0144': 'O2 Sensor Circuit High Voltage (Bank 1 Sensor 3)',
      'P0145': 'O2 Sensor Circuit Slow Response (Bank 1 Sensor 3)',
      'P0146': 'O2 Sensor Circuit No Activity Detected (Bank 1 Sensor 3)',
      'P0147': 'O2 Sensor Heater Circuit Malfunction (Bank 1 Sensor 3)',
      'P0148': 'Fuel Delivery Error',
      'P0149': 'Fuel Timing Error',
      'P0150': 'O2 Sensor Circuit Malfunction (Bank 2 Sensor 1)',
      'P0151': 'O2 Sensor Circuit Low Voltage (Bank 2 Sensor 1)',
      'P0152': 'O2 Sensor Circuit High Voltage (Bank 2 Sensor 1)',
      'P0153': 'O2 Sensor Circuit Slow Response (Bank 2 Sensor 1)',
      'P0154': 'O2 Sensor Circuit No Activity Detected (Bank 2 Sensor 1)',
      'P0155': 'O2 Sensor Heater Circuit Malfunction (Bank 2 Sensor 1)',
      'P0200': 'Injector Circuit Malfunction',
      'P0201': 'Injector Circuit Malfunction - Cylinder 1',
      'P0202': 'Injector Circuit Malfunction - Cylinder 2',
      'P0203': 'Injector Circuit Malfunction - Cylinder 3',
      'P0204': 'Injector Circuit Malfunction - Cylinder 4',
      'P0205': 'Injector Circuit Malfunction - Cylinder 5',
      'P0206': 'Injector Circuit Malfunction - Cylinder 6',
      'P0207': 'Injector Circuit Malfunction - Cylinder 7',
      'P0208': 'Injector Circuit Malfunction - Cylinder 8',
      'P0300': 'Random/Multiple Cylinder Misfire Detected',
      'P0301': 'Cylinder 1 Misfire Detected',
      'P0302': 'Cylinder 2 Misfire Detected',
      'P0303': 'Cylinder 3 Misfire Detected',
      'P0304': 'Cylinder 4 Misfire Detected',
      'P0305': 'Cylinder 5 Misfire Detected',
      'P0306': 'Cylinder 6 Misfire Detected',
      'P0307': 'Cylinder 7 Misfire Detected',
      'P0308': 'Cylinder 8 Misfire Detected',
      'P0309': 'Cylinder 9 Misfire Detected',
      'P0310': 'Cylinder 10 Misfire Detected',
      'P0311': 'Cylinder 11 Misfire Detected',
      'P0312': 'Cylinder 12 Misfire Detected',
      'P0320': 'Ignition/Distributor Engine Speed Input Circuit Malfunction',
      'P0321': 'Ignition/Distributor Engine Speed Input Circuit Range/Performance',
      'P0322': 'Ignition/Distributor Engine Speed Input Circuit No Signal',
      'P0323': 'Ignition/Distributor Engine Speed Input Circuit Intermittent',
      'P0325': 'Knock Sensor 1 Circuit Malfunction (Bank 1 or Single Sensor)',
      'P0326': 'Knock Sensor 1 Circuit Range/Performance (Bank 1 or Single Sensor)',
      'P0327': 'Knock Sensor 1 Circuit Low Input (Bank 1 or Single Sensor)',
      'P0328': 'Knock Sensor 1 Circuit High Input (Bank 1 or Single Sensor)',
      'P0329': 'Knock Sensor 1 Circuit Input Intermittent (Bank 1 or Single Sensor)',
      'P0330': 'Knock Sensor 2 Circuit Malfunction (Bank 2)',
      'P0331': 'Knock Sensor 2 Circuit Range/Performance (Bank 2)',
      'P0332': 'Knock Sensor 2 Circuit Low Input (Bank 2)',
      'P0333': 'Knock Sensor 2 Circuit High Input (Bank 2)',
      'P0334': 'Knock Sensor 2 Circuit Input Intermittent (Bank 2)',
      'P0335': 'Crankshaft Position Sensor A Circuit Malfunction',
      'P0336': 'Crankshaft Position Sensor A Circuit Range/Performance',
      'P0337': 'Crankshaft Position Sensor A Circuit Low Input',
      'P0338': 'Crankshaft Position Sensor A Circuit High Input',
      'P0339': 'Crankshaft Position Sensor A Circuit Intermittent',
      'P0340': 'Camshaft Position Sensor Circuit Malfunction',
      'P0341': 'Camshaft Position Sensor Circuit Range/Performance',
      'P0342': 'Camshaft Position Sensor Circuit Low Input',
      'P0343': 'Camshaft Position Sensor Circuit High Input',
      'P0344': 'Camshaft Position Sensor Circuit Intermittent',
      'P0400': 'Exhaust Gas Recirculation Flow Malfunction',
      'P0401': 'Exhaust Gas Recirculation Flow Insufficient Detected',
      'P0402': 'Exhaust Gas Recirculation Flow Excessive Detected',
      'P0403': 'Exhaust Gas Recirculation Circuit Malfunction',
      'P0404': 'Exhaust Gas Recirculation Circuit Range/Performance',
      'P0405': 'Exhaust Gas Recirculation Sensor A Circuit Low',
      'P0406': 'Exhaust Gas Recirculation Sensor A Circuit High',
      'P0407': 'Exhaust Gas Recirculation Sensor B Circuit Low',
      'P0408': 'Exhaust Gas Recirculation Sensor B Circuit High',
      'P0410': 'Secondary Air Injection System Malfunction',
      'P0411': 'Secondary Air Injection System Incorrect Flow Detected',
      'P0412': 'Secondary Air Injection System Switching Valve A Circuit Malfunction',
      'P0413': 'Secondary Air Injection System Switching Valve A Circuit Open',
      'P0414': 'Secondary Air Injection System Switching Valve A Circuit Shorted',
      'P0415': 'Secondary Air Injection System Switching Valve B Circuit Malfunction',
      'P0416': 'Secondary Air Injection System Switching Valve B Circuit Open',
      'P0417': 'Secondary Air Injection System Switching Valve B Circuit Shorted',
      'P0418': 'Secondary Air Injection System Relay A Circuit Malfunction',
      'P0419': 'Secondary Air Injection System Relay B Circuit Malfunction',
      'P0420': 'Catalyst System Efficiency Below Threshold (Bank 1)',
      'P0421': 'Warm Up Catalyst Efficiency Below Threshold (Bank 1)',
      'P0422': 'Main Catalyst Efficiency Below Threshold (Bank 1)',
      'P0423': 'Heated Catalyst Efficiency Below Threshold (Bank 1)',
      'P0424': 'Heated Catalyst Temperature Below Threshold (Bank 1)',
      'P0430': 'Catalyst System Efficiency Below Threshold (Bank 2)',
      'P0431': 'Warm Up Catalyst Efficiency Below Threshold (Bank 2)',
      'P0432': 'Main Catalyst Efficiency Below Threshold (Bank 2)',
      'P0433': 'Heated Catalyst Efficiency Below Threshold (Bank 2)',
      'P0434': 'Heated Catalyst Temperature Below Threshold (Bank 2)',
      'P0440': 'Evaporative Emission Control System Malfunction',
      'P0441': 'Evaporative Emission Control System Incorrect Purge Flow',
      'P0442': 'Evaporative Emission Control System Leak Detected (Small Leak)',
      'P0443': 'Evaporative Emission Control System Purge Control Valve Circuit Malfunction',
      'P0444': 'Evaporative Emission Control System Purge Control Valve Circuit Open',
      'P0445': 'Evaporative Emission Control System Purge Control Valve Circuit Shorted',
      'P0446': 'Evaporative Emission Control System Vent Control Circuit Malfunction',
      'P0447': 'Evaporative Emission Control System Vent Control Circuit Open',
      'P0448': 'Evaporative Emission Control System Vent Control Circuit Shorted',
      'P0449': 'Evaporative Emission Control System Vent Valve/Solenoid Circuit Malfunction',
      'P0450': 'Evaporative Emission Control System Pressure Sensor Malfunction',
      'P0451': 'Evaporative Emission Control System Pressure Sensor Range/Performance',
      'P0452': 'Evaporative Emission Control System Pressure Sensor Low Input',
      'P0453': 'Evaporative Emission Control System Pressure Sensor High Input',
      'P0454': 'Evaporative Emission Control System Pressure Sensor Intermittent',
      'P0455': 'Evaporative Emission Control System Leak Detected (Gross Leak)',
      'P0500': 'Vehicle Speed Sensor Malfunction',
      'P0501': 'Vehicle Speed Sensor Range/Performance',
      'P0502': 'Vehicle Speed Sensor Circuit Low Input',
      'P0503': 'Vehicle Speed Sensor Intermittent/Erratic/High',
      'P0505': 'Idle Control System Malfunction',
      'P0506': 'Idle Control System RPM Lower Than Expected',
      'P0507': 'Idle Control System RPM Higher Than Expected',
      'P0508': 'Idle Control System Circuit Low',
      'P0509': 'Idle Control System Circuit High',
      'P0510': 'Closed Throttle Position Switch Malfunction',
      'P0511': 'Idle Control Circuit Malfunction',
      'P0512': 'Starter Request Circuit Malfunction',
      'P0513': 'Incorrect Immobilizer Key',
      'P0514': 'Battery Temperature Sensor Circuit High',
      'P0515': 'Battery Temperature Sensor Circuit Malfunction',
      'P0516': 'Battery Temperature Sensor Circuit Low',
      'P0517': 'Battery Temperature Sensor Circuit Intermittent/Erratic',
      'P0518': 'Idle Control Circuit Intermittent',
      'P0519': 'Idle Control System Performance',
      'P0520': 'Engine Oil Pressure Sensor/Switch Circuit Malfunction',
      'P0521': 'Engine Oil Pressure Sensor/Switch Range/Performance',
      'P0522': 'Engine Oil Pressure Sensor/Switch Low Voltage',
      'P0523': 'Engine Oil Pressure Sensor/Switch High Voltage',
      'P0524': 'Engine Oil Pressure Too Low',
      'P0525': 'Cruise Control Servo Control Circuit Range/Performance',
      'P0526': 'Fan Speed Sensor Circuit Malfunction',
      'P0527': 'Fan Speed Sensor Circuit Range/Performance',
      'P0528': 'Fan Speed Sensor Circuit No Signal',
      'P0529': 'Fan Speed Sensor Circuit Intermittent',
      'P0530': 'A/C Refrigerant Pressure Sensor Circuit Malfunction',
      'P0531': 'A/C Refrigerant Pressure Sensor Circuit Range/Performance',
      'P0532': 'A/C Refrigerant Pressure Sensor Circuit Low Input',
      'P0533': 'A/C Refrigerant Pressure Sensor Circuit High Input',
      'P0534': 'A/C Refrigerant Charge Loss',
      'P0550': 'Power Steering Pressure Sensor Circuit Malfunction',
      'P0551': 'Power Steering Pressure Sensor Circuit Range/Performance',
      'P0552': 'Power Steering Pressure Sensor Circuit Low Input',
      'P0553': 'Power Steering Pressure Sensor Circuit High Input',
      'P0554': 'Power Steering Pressure Sensor Circuit Intermittent',
      'P0560': 'System Voltage Malfunction',
      'P0561': 'System Voltage Unstable',
      'P0562': 'System Voltage Low',
      'P0563': 'System Voltage High',
      'P0565': 'Cruise Control On Signal Malfunction',
      'P0566': 'Cruise Control Off Signal Malfunction',
      'P0567': 'Cruise Control Resume Signal Malfunction',
      'P0568': 'Cruise Control Set Signal Malfunction',
      'P0569': 'Cruise Control Coast Signal Malfunction',
      'P0570': 'Cruise Control Accel Signal Malfunction',
      'P0571': 'Cruise Control/Brake Switch A Circuit Malfunction',
      'P0572': 'Cruise Control/Brake Switch A Circuit Low',
      'P0573': 'Cruise Control/Brake Switch A Circuit High',
      'P0574': 'Through P0580 Reserved for Future Codes',
      'P0600': 'Serial Communication Link Malfunction',
      'P0601': 'Internal Control Module Memory Check Sum Error',
      'P0602': 'Control Module Programming Error',
      'P0603': 'Internal Control Module Keep Alive Memory (KAM) Error',
      'P0604': 'Internal Control Module Random Access Memory (RAM) Error',
      'P0605': 'Internal Control Module Read Only Memory (ROM) Error',
      'P0606': 'PCM Processor Fault',
      'P0607': 'Control Module Performance',
      'P0608': 'Control Module VSS Output A Malfunction',
      'P0609': 'Control Module VSS Output B Malfunction',
      'P0610': 'Control Module Vehicle Options Error',
      'P0700': 'Transmission Control System Malfunction',
      'P0701': 'Transmission Control System Range/Performance',
      'P0702': 'Transmission Control System Electrical',
      'P0703': 'Torque Converter/Brake Switch B Circuit Malfunction',
      'P0704': 'Clutch Switch Input Circuit Malfunction',
      'P0705': 'Transmission Range Sensor Circuit Malfunction (PRNDL Input)',
      'P0706': 'Transmission Range Sensor Circuit Range/Performance',
      'P0707': 'Transmission Range Sensor Circuit Low Input',
      'P0708': 'Transmission Range Sensor Circuit High Input',
      'P0709': 'Transmission Range Sensor Circuit Intermittent',
      'P0710': 'Transmission Fluid Temperature Sensor Circuit Malfunction',
      'P0711': 'Transmission Fluid Temperature Sensor Circuit Range/Performance',
      'P0712': 'Transmission Fluid Temperature Sensor Circuit Low Input',
      'P0713': 'Transmission Fluid Temperature Sensor Circuit High Input',
      'P0714': 'Transmission Fluid Temperature Sensor Circuit Intermittent',
      'P0715': 'Input/Turbine Speed Sensor Circuit Malfunction',
      'P0716': 'Input/Turbine Speed Sensor Circuit Range/Performance',
      'P0717': 'Input/Turbine Speed Sensor Circuit No Signal',
      'P0718': 'Input/Turbine Speed Sensor Circuit Intermittent',
      'P0719': 'Torque Converter/Brake Switch B Circuit Low',
      'P0720': 'Output Speed Sensor Circuit Malfunction',
      'P0721': 'Output Speed Sensor Circuit Range/Performance',
      'P0722': 'Output Speed Sensor Circuit No Signal',
      'P0723': 'Output Speed Sensor Circuit Intermittent',
      'P0724': 'Torque Converter/Brake Switch B Circuit High',
      'P0725': 'Engine Speed Input Circuit Malfunction',
      'P0726': 'Engine Speed Input Circuit Range/Performance',
      'P0727': 'Engine Speed Input Circuit No Signal',
      'P0728': 'Engine Speed Input Circuit Intermittent',
      'P0729': 'Gear 6 Incorrect Ratio',
      'P0730': 'Incorrect Gear Ratio',
      'P0731': 'Gear 1 Incorrect Ratio',
      'P0732': 'Gear 2 Incorrect Ratio',
      'P0733': 'Gear 3 Incorrect Ratio',
      'P0734': 'Gear 4 Incorrect Ratio',
      'P0735': 'Gear 5 Incorrect Ratio',
      'P0736': 'Reverse Incorrect Ratio',
      'P0740': 'Torque Converter Clutch Circuit Malfunction',
      'P0741': 'Torque Converter Clutch Circuit Performance or Stuck Off',
      'P0742': 'Torque Converter Clutch Circuit Stuck On',
      'P0743': 'Torque Converter Clutch Circuit Electrical',
      'P0744': 'Torque Converter Clutch Circuit Intermittent',
      'P0745': 'Pressure Control Solenoid Malfunction',
      'P0746': 'Pressure Control Solenoid Performance or Stuck Off',
      'P0747': 'Pressure Control Solenoid Stuck On',
      'P0748': 'Pressure Control Solenoid Electrical',
      'P0749': 'Pressure Control Solenoid Intermittent',
      'P0750': 'Shift Solenoid A Malfunction',
      'P0751': 'Shift Solenoid A Performance or Stuck Off',
      'P0752': 'Shift Solenoid A Stuck On',
      'P0753': 'Shift Solenoid A Electrical',
      'P0754': 'Shift Solenoid A Intermittent',
      'P0755': 'Shift Solenoid B Malfunction',
      'P0756': 'Shift Solenoid B Performance or Stuck Off',
      'P0757': 'Shift Solenoid B Stuck On',
      'P0758': 'Shift Solenoid B Electrical',
      'P0759': 'Shift Solenoid B Intermittent',
      'P0760': 'Shift Solenoid C Malfunction',
      'P0761': 'Shift Solenoid C Performance or Stuck Off',
      'P0762': 'Shift Solenoid C Stuck On',
      'P0763': 'Shift Solenoid C Electrical',
      'P0764': 'Shift Solenoid C Intermittent',
      'P0765': 'Shift Solenoid D Malfunction',
      'P0766': 'Shift Solenoid D Performance or Stuck Off',
      'P0767': 'Shift Solenoid D Stuck On',
      'P0768': 'Shift Solenoid D Electrical',
      'P0769': 'Shift Solenoid D Intermittent',
      'P0770': 'Shift Solenoid E Malfunction',
      'P0771': 'Shift Solenoid E Performance or Stuck Off',
      'P0772': 'Shift Solenoid E Stuck On',
      'P0773': 'Shift Solenoid E Electrical',
      'P0774': 'Shift Solenoid E Intermittent',
      'P0780': 'Shift Malfunction',
      'P0781': '1-2 Shift Malfunction',
      'P0782': '2-3 Shift Malfunction',
      'P0783': '3-4 Shift Malfunction',
      'P0784': '4-5 Shift Malfunction',
      'P0785': 'Shift/Timing Solenoid Malfunction',
      'P0786': 'Shift/Timing Solenoid Range/Performance',
      'P0787': 'Shift/Timing Solenoid Low',
      'P0788': 'Shift/Timing Solenoid High',
      'P0789': 'Shift/Timing Solenoid Intermittent',
      'P0790': 'Normal/Performance Switch Circuit Malfunction',
      'P0791': 'Intermediate Shaft Speed Sensor Circuit Malfunction',
      'P0792': 'Intermediate Shaft Speed Sensor Circuit Range/Performance',
      'P0793': 'Intermediate Shaft Speed Sensor Circuit No Signal',
      'P0794': 'Intermediate Shaft Speed Sensor Circuit Intermittent',
      'P0795': 'Pressure Control Solenoid C Malfunction',
      'P0796': 'Pressure Control Solenoid C Performance or Stuck Off',
      'P0797': 'Pressure Control Solenoid C Stuck On',
      'P0798': 'Pressure Control Solenoid C Electrical',
      'P0799': 'Pressure Control Solenoid C Intermittent',
      'P1000': 'OBD System Readiness Test Not Complete',
      'P1001': 'KOER Test Cannot Be Completed',
      'P1100': 'Mass Air Flow Sensor Intermittent',
      'P1101': 'Mass Air Flow Sensor Out of Self-Test Range',
      'P1111': 'System Pass',
      'P1112': 'Intake Air Temperature Sensor Intermittent',
      'P1116': 'Engine Coolant Temperature Sensor Out of Self-Test Range',
      'P1117': 'Engine Coolant Temperature Sensor Intermittent',
      'P1120': 'Throttle Position Sensor Out of Range Low',
      'P1121': 'Throttle Position Sensor Inconsistent with MAF',
      'P1124': 'Throttle Position Sensor Out of Self-Test Range',
      'P1125': 'Throttle Position Sensor Circuit Intermittent',
      'P1130': 'Lack of HO2S Switch - Sensor Indicates Lean',
      'P1131': 'Lack of HO2S Switch - Sensor Indicates Rich',
      'P1132': 'Lack of HO2S Switch - Sensor Indicates Lean',
      'P1133': 'Lack of HO2S Switch - Sensor Indicates Rich',
      'P1134': 'Lack of HO2S Switch - Sensor Indicates Lean',
      'P1135': 'Lack of HO2S Switch - Sensor Indicates Rich',
      'P1137': 'Lack of HO2S Switch - Sensor Indicates Lean',
      'P1138': 'Lack of HO2S Switch - Sensor Indicates Rich',
      'P1150': 'Lack of HO2S Switch - Sensor Indicates Lean',
      'P1151': 'Lack of HO2S Switch - Sensor Indicates Rich',
      'P1152': 'Lack of HO2S Switch - Sensor Indicates Lean',
      'P1153': 'Lack of HO2S Switch - Sensor Indicates Rich',
      'P1154': 'Lack of HO2S Switch - Sensor Indicates Lean',
      'P1155': 'Lack of HO2S Switch - Sensor Indicates Rich',
      'P1157': 'Lack of HO2S Switch - Sensor Indicates Lean',
      'P1158': 'Lack of HO2S Switch - Sensor Indicates Rich',
      'P1200': 'Fuel System Malfunction',
      'P1201': 'Cylinder 1 Injector Circuit Malfunction',
      'P1202': 'Cylinder 2 Injector Circuit Malfunction',
      'P1203': 'Cylinder 3 Injector Circuit Malfunction',
      'P1204': 'Cylinder 4 Injector Circuit Malfunction',
      'P1205': 'Cylinder 5 Injector Circuit Malfunction',
      'P1206': 'Cylinder 6 Injector Circuit Malfunction',
      'P1207': 'Cylinder 7 Injector Circuit Malfunction',
      'P1208': 'Cylinder 8 Injector Circuit Malfunction',
      'P1209': 'Cylinder 9 Injector Circuit Malfunction',
      'P1210': 'Cylinder 10 Injector Circuit Malfunction',
      'P1220': 'Series Throttle Control Malfunction',
      'P1224': 'Throttle Position Sensor B Out of Self-Test Range',
      'P1233': 'Fuel System Disabled or Offline',
      'P1234': 'Fuel System Disabled or Offline',
      'P1235': 'Fuel Pump Control Out of Range',
      'P1236': 'Fuel Pump Control Out of Range',
      'P1237': 'Fuel Pump Secondary Circuit Malfunction',
      'P1238': 'Fuel Pump Secondary Circuit Malfunction',
      'P1260': 'Theft Detected - Vehicle Immobilized',
      'P1270': 'Engine RPM or Vehicle Speed Limiter Reached',
      'P1288': 'Cylinder Head Temperature Sensor Out of Self-Test Range',
      'P1289': 'Cylinder Head Temperature Sensor Circuit Low Input',
      'P1290': 'Cylinder Head Temperature Sensor Circuit High Input',
      'P1299': 'Cylinder Head Over Temperature Protection Active',
      'P1300': 'Ignition Coil A Primary Circuit Malfunction',
      'P1301': 'Ignition Coil A Secondary Circuit Malfunction',
      'P1302': 'Ignition Coil B Primary Circuit Malfunction',
      'P1303': 'Ignition Coil B Secondary Circuit Malfunction',
      'P1304': 'Ignition Coil C Primary Circuit Malfunction',
      'P1305': 'Ignition Coil C Secondary Circuit Malfunction',
      'P1306': 'Ignition Coil D Primary Circuit Malfunction',
      'P1307': 'Ignition Coil D Secondary Circuit Malfunction',
      'P1308': 'Ignition Coil E Primary Circuit Malfunction',
      'P1309': 'Ignition Coil E Secondary Circuit Malfunction',
      'P1310': 'Ignition Coil F Primary Circuit Malfunction',
      'P1311': 'Ignition Coil F Secondary Circuit Malfunction',
      'P1312': 'Ignition Coil G Primary Circuit Malfunction',
      'P1313': 'Ignition Coil G Secondary Circuit Malfunction',
      'P1314': 'Ignition Coil H Primary Circuit Malfunction',
      'P1315': 'Ignition Coil H Secondary Circuit Malfunction',
      'P1316': 'Ignition Coil I Primary Circuit Malfunction',
      'P1317': 'Ignition Coil I Secondary Circuit Malfunction',
      'P1318': 'Ignition Coil J Primary Circuit Malfunction',
      'P1319': 'Ignition Coil J Secondary Circuit Malfunction',
      'P1320': 'Ignition Coil K Primary Circuit Malfunction',
      'P1321': 'Ignition Coil K Secondary Circuit Malfunction',
      'P1322': 'Ignition Coil L Primary Circuit Malfunction',
      'P1323': 'Ignition Coil L Secondary Circuit Malfunction',
      'P1324': 'Knock Sensor Module Malfunction',
      'P1325': 'Knock Sensor 1 Circuit Malfunction',
      'P1326': 'Knock Sensor 2 Circuit Malfunction',
      'P1327': 'Knock Sensor 3 Circuit Malfunction',
      'P1328': 'Knock Sensor 4 Circuit Malfunction',
      'P1329': 'Knock Sensor 5 Circuit Malfunction',
      'P1330': 'Knock Sensor 6 Circuit Malfunction',
      'P1331': 'Knock Sensor 7 Circuit Malfunction',
      'P1332': 'Knock Sensor 8 Circuit Malfunction',
      'P1336': 'Crankshaft Position Sensor (PIP) Circuit Malfunction',
      'P1337': 'Crankshaft Position Sensor (PIP) Circuit Malfunction',
      'P1338': 'Crankshaft Position Sensor (PIP) Circuit Malfunction',
      'P1339': 'Crankshaft Position Sensor (PIP) Circuit Malfunction',
      'P1340': 'Camshaft Position Sensor (CMP) Circuit Malfunction',
      'P1341': 'Camshaft Position Sensor (CMP) Circuit Malfunction',
      'P1342': 'Camshaft Position Sensor (CMP) Circuit Malfunction',
      'P1343': 'Camshaft Position Sensor (CMP) Circuit Malfunction',
      'P1344': 'Camshaft Position Sensor (CMP) Circuit Malfunction',
      'P1345': 'Camshaft Position Sensor (CMP) Circuit Malfunction',
      'P1346': 'Camshaft Position Sensor (CMP) Circuit Malfunction',
      'P1347': 'Camshaft Position Sensor (CMP) Circuit Malfunction',
      'P1348': 'Camshaft Position Sensor (CMP) Circuit Malfunction',
      'P1349': 'Camshaft Position Sensor (CMP) Circuit Malfunction',
      'P1350': 'Ignition Control Module (ICM) Circuit Malfunction',
      'P1351': 'Ignition Control Module (ICM) Circuit Malfunction',
      'P1352': 'Ignition Control Module (ICM) Circuit Malfunction',
      'P1353': 'Ignition Control Module (ICM) Circuit Malfunction',
      'P1354': 'Ignition Control Module (ICM) Circuit Malfunction',
      'P1355': 'Ignition Control Module (ICM) Circuit Malfunction',
      'P1356': 'Ignition Control Module (ICM) Circuit Malfunction',
      'P1357': 'Ignition Control Module (ICM) Circuit Malfunction',
      'P1358': 'Ignition Control Module (ICM) Circuit Malfunction',
      'P1359': 'Ignition Control Module (ICM) Circuit Malfunction',
      'P1360': 'Ignition Coil A Secondary Circuit Malfunction',
      'P1361': 'Ignition Coil A Secondary Circuit Malfunction',
      'P1362': 'Ignition Coil B Secondary Circuit Malfunction',
      'P1363': 'Ignition Coil B Secondary Circuit Malfunction',
      'P1364': 'Ignition Coil C Secondary Circuit Malfunction',
      'P1365': 'Ignition Coil C Secondary Circuit Malfunction',
      'P1366': 'Ignition Coil D Secondary Circuit Malfunction',
      'P1367': 'Ignition Coil D Secondary Circuit Malfunction',
      'P1368': 'Ignition Coil E Secondary Circuit Malfunction',
      'P1369': 'Ignition Coil E Secondary Circuit Malfunction',
      'P1370': 'Ignition Coil F Secondary Circuit Malfunction',
      'P1371': 'Ignition Coil F Secondary Circuit Malfunction',
      'P1372': 'Ignition Coil G Secondary Circuit Malfunction',
      'P1373': 'Ignition Coil G Secondary Circuit Malfunction',
      'P1374': 'Ignition Coil H Secondary Circuit Malfunction',
      'P1375': 'Ignition Coil H Secondary Circuit Malfunction',
      'P1376': 'Ignition Coil I Secondary Circuit Malfunction',
      'P1377': 'Ignition Coil I Secondary Circuit Malfunction',
      'P1378': 'Ignition Coil J Secondary Circuit Malfunction',
      'P1379': 'Ignition Coil J Secondary Circuit Malfunction',
      'P1380': 'Ignition Coil K Secondary Circuit Malfunction',
      'P1381': 'Ignition Coil K Secondary Circuit Malfunction',
      'P1382': 'Ignition Coil L Secondary Circuit Malfunction',
      'P1383': 'Ignition Coil L Secondary Circuit Malfunction',
      'P1400': 'Differential Pressure Feedback EGR Sensor Circuit Malfunction',
      'P1401': 'Differential Pressure Feedback EGR Sensor Circuit Range/Performance',
      'P1402': 'EGR Valve Position Sensor Circuit Malfunction',
      'P1403': 'Differential Pressure Feedback EGR Sensor Hoses Reversed',
      'P1404': 'EGR Valve Position Sensor Circuit Range/Performance',
      'P1405': 'Differential Pressure Feedback EGR Sensor Upstream Hose Off or Plugged',
      'P1406': 'Differential Pressure Feedback EGR Sensor Downstream Hose Off or Plugged',
      'P1407': 'EGR No Flow Detected',
      'P1408': 'EGR Flow Out of Self-Test Range',
      'P1409': 'EGR Vacuum Regulator Solenoid Circuit Malfunction',
      'P1410': 'EGR Vacuum Regulator Solenoid Circuit Malfunction',
      'P1411': 'Secondary Air Injection System Downstream',
      'P1412': 'Secondary Air Injection System Coil',
      'P1413': 'Secondary Air Injection System Monitor',
      'P1414': 'Secondary Air Injection System Hr',
      'P1415': 'Secondary Air Injection System Bank 1',
      'P1416': 'Secondary Air Injection System Bank 2',
      'P1417': 'Secondary Air Injection System Bank 1',
      'P1418': 'Secondary Air Injection System Bank 2',
      'P1419': 'Secondary Air Injection System',
      'P1420': 'Secondary Air Injection System',
      'P1421': 'Secondary Air Injection System',
      'P1422': 'Secondary Air Injection System',
      'P1423': 'Secondary Air Injection System',
      'P1424': 'Secondary Air Injection System',
      'P1425': 'Secondary Air Injection System',
      'P1426': 'Secondary Air Injection System',
      'P1427': 'Secondary Air Injection System',
      'P1428': 'Secondary Air Injection System',
      'P1429': 'Secondary Air Injection System',
      'P1430': 'Secondary Air Injection System',
      'P1431': 'Secondary Air Injection System',
      'P1432': 'Secondary Air Injection System',
      'P1433': 'Secondary Air Injection System',
      'P1434': 'Secondary Air Injection System',
      'P1435': 'Secondary Air Injection System',
      'P1436': 'Secondary Air Injection System',
      'P1437': 'Secondary Air Injection System',
      'P1438': 'Secondary Air Injection System',
      'P1439': 'Secondary Air Injection System',
      'P1440': 'Secondary Air Injection System',
      'P1441': 'Secondary Air Injection System',
      'P1442': 'Secondary Air Injection System',
      'P1443': 'Secondary Air Injection System',
      'P1444': 'Secondary Air Injection System',
      'P1445': 'Secondary Air Injection System',
      'P1446': 'Secondary Air Injection System',
      'P1447': 'Secondary Air Injection System',
      'P1448': 'Secondary Air Injection System',
      'P1449': 'Secondary Air Injection System',
      'P1450': 'Unable to Bleed Up Fuel Tank Vacuum',
      'P1451': 'Evaporative Emission Control System Canister Vent Solenoid Circuit Malfunction',
      'P1452': 'Unable to Bleed Up Fuel Tank Vacuum',
      'P1453': 'Evaporative Emission Control System Canister Vent Solenoid Circuit Malfunction',
      'P1454': 'Evaporative Emission Control System Canister Vent Solenoid Circuit Malfunction',
      'P1455': 'Evaporative Emission Control System Canister Vent Solenoid Circuit Malfunction',
      'P1456': 'Evaporative Emission Control System Canister Vent Solenoid Circuit Malfunction',
      'P1457': 'Evaporative Emission Control System Canister Vent Solenoid Circuit Malfunction',
      'P1458': 'Air Conditioning Evaporator Temperature Circuit Low Input',
      'P1459': 'Air Conditioning Evaporator Temperature Circuit High Input',
      'P1460': 'Wide Open Throttle Air Conditioning Cut-off Circuit Malfunction',
      'P1461': 'Air Conditioning Pressure Sensor Circuit Malfunction',
      'P1462': 'Air Conditioning Pressure Sensor Circuit Range/Performance',
      'P1463': 'Air Conditioning Pressure Sensor Circuit Low Input',
      'P1464': 'Air Conditioning Pressure Sensor Circuit High Input',
      'P1465': 'Air Conditioning Clutch Circuit Malfunction',
      'P1466': 'Air Conditioning Clutch Circuit Malfunction',
      'P1467': 'Air Conditioning Clutch Circuit Malfunction',
      'P1468': 'Air Conditioning Clutch Circuit Malfunction',
      'P1469': 'Air Conditioning Clutch Circuit Malfunction',
      'P1470': 'Air Conditioning Clutch Circuit Malfunction',
      'P1471': 'Air Conditioning Clutch Circuit Malfunction',
      'P1472': 'Air Conditioning Clutch Circuit Malfunction',
      'P1473': 'Air Conditioning Clutch Circuit Malfunction',
      'P1474': 'Air Conditioning Clutch Circuit Malfunction',
      'P1475': 'Air Conditioning Clutch Circuit Malfunction',
      'P1476': 'Air Conditioning Clutch Circuit Malfunction',
      'P1477': 'Air Conditioning Clutch Circuit Malfunction',
      'P1478': 'Air Conditioning Clutch Circuit Malfunction',
      'P1479': 'Air Conditioning Clutch Circuit Malfunction',
      'P1480': 'Air Conditioning Clutch Circuit Malfunction',
      'P1481': 'Air Conditioning Clutch Circuit Malfunction',
      'P1482': 'Air Conditioning Clutch Circuit Malfunction',
      'P1483': 'Air Conditioning Clutch Circuit Malfunction',
      'P1484': 'Air Conditioning Clutch Circuit Malfunction',
      'P1485': 'EGR Control Solenoid Circuit Malfunction',
      'P1486': 'EGR Vent Solenoid Circuit Malfunction',
      'P1487': 'EGR Boost Check Solenoid Circuit Malfunction',
      'P1488': 'EGR Boost Check Solenoid Circuit Malfunction',
      'P1489': 'EGR Control Solenoid Circuit Malfunction',
      'P1490': 'EGR Control Solenoid Circuit Malfunction',
      'P1491': 'EGR Control Solenoid Circuit Malfunction',
      'P1492': 'EGR Control Solenoid Circuit Malfunction',
      'P1493': 'EGR Control Solenoid Circuit Malfunction',
      'P1494': 'EGR Control Solenoid Circuit Malfunction',
      'P1495': 'EGR Control Solenoid Circuit Malfunction',
      'P1496': 'EGR Control Solenoid Circuit Malfunction',
      'P1497': 'EGR Control Solenoid Circuit Malfunction',
      'P1498': 'EGR Control Solenoid Circuit Malfunction',
      'P1499': 'EGR Control Solenoid Circuit Malfunction',
      'P1500': 'Vehicle Speed Sensor Circuit Intermittent',
      'P1501': 'Vehicle Speed Sensor Out of Self-Test Range',
      'P1502': 'Invalid Self-Test - VSS Circuit Open',
      'P1503': 'Invalid Self-Test - VSS Circuit Open',
      'P1504': 'Idle Air Control Valve Circuit Malfunction',
      'P1505': 'Idle Air Control Valve Circuit Malfunction',
      'P1506': 'Idle Air Control Valve Circuit Malfunction',
      'P1507': 'Idle Air Control Valve Circuit Malfunction',
      'P1508': 'Idle Air Control Valve Circuit Malfunction',
      'P1509': 'Idle Air Control Valve Circuit Malfunction',
      'P1510': 'Idle Air Control Valve Circuit Malfunction',
      'P1511': 'Idle Air Control Valve Circuit Malfunction',
      'P1512': 'Intake Manifold Runner Control Stuck Open',
      'P1513': 'Intake Manifold Runner Control Stuck Closed',
      'P1514': 'Intake Manifold Runner Control Malfunction',
      'P1515': 'Intake Manifold Runner Control Malfunction',
      'P1516': 'Intake Manifold Runner Control Input Error',
      'P1517': 'Intake Manifold Runner Control Input Error',
      'P1518': 'Intake Manifold Runner Control Input Error',
      'P1519': 'Intake Manifold Runner Control Input Error',
      'P1520': 'Intake Manifold Runner Control Input Error',
      'P1521': 'Variable Resonance Induction System Malfunction',
      'P1522': 'Variable Resonance Induction System Malfunction',
      'P1523': 'High Speed Inlet Air (HSIA) Solenoid Circuit Malfunction',
      'P1524': 'Cam Timing Over-Retarded',
      'P1525': 'Cam Timing Over-Advanced',
      'P1526': 'Cam Timing Improperly Set',
      'P1527': 'Cam Timing Improperly Set',
      'P1528': 'Cam Timing Improperly Set',
      'P1529': 'Cam Timing Improperly Set',
      'P1530': 'Air Conditioning Clutch Circuit Malfunction',
      'P1531': 'Invalid Test - Accelerator Pedal Movement',
      'P1532': 'Intake Manifold Runner Control Malfunction',
      'P1533': 'Intake Manifold Runner Control Malfunction',
      'P1534': 'Intake Manifold Runner Control Malfunction',
      'P1535': 'Intake Manifold Runner Control Malfunction',
      'P1536': 'Intake Manifold Runner Control Malfunction',
      'P1537': 'Intake Manifold Runner Control Malfunction',
      'P1538': 'Intake Manifold Runner Control Malfunction',
      'P1539': 'Power to Air Conditioning Clutch Circuit Malfunction',
      'P1540': 'Air Conditioning Clutch Circuit Malfunction',
      'P1549': 'Problem in Intake Manifold Tuning Valve',
      'P1550': 'Power Steering Pressure Switch Circuit Malfunction',
      'P1601': 'Serial Communication Error',
      'P1602': 'Serial Communication Error',
      'P1603': 'Serial Communication Error',
      'P1604': 'Serial Communication Error',
      'P1605': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1606': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1607': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1608': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1609': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1610': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1611': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1612': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1613': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1614': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1615': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1616': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1617': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1618': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1619': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1620': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1621': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1622': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1623': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1624': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1625': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1626': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1627': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1628': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1629': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1630': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1631': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1632': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1633': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1634': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1635': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1636': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1637': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1638': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1639': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1640': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1641': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1642': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1643': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1644': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1645': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1646': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1647': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1648': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1649': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1650': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1651': 'Powertrain Control Module - Keep Alive Memory Test Error',
      'P1700': 'Transmission Control System Malfunction',
      'P2000': 'NOx Trap Efficiency Below Threshold Bank 1',
      'P2001': 'NOx Trap Efficiency Below Threshold Bank 2',
      'P2002': 'Particulate Filter Efficiency Below Threshold Bank 1',
      'P2003': 'Particulate Filter Efficiency Below Threshold Bank 2',
      'P2004': 'Intake Manifold Runner Control Stuck Open Bank 1',
      'P2005': 'Intake Manifold Runner Control Stuck Open Bank 2',
      'P2006': 'Intake Manifold Runner Control Stuck Closed Bank 1',
      'P2007': 'Intake Manifold Runner Control Stuck Closed Bank 2',
      'P2008': 'Intake Manifold Runner Control Circuit/Open Bank 1',
      'P2009': 'Intake Manifold Runner Control Circuit Low Bank 1',
      'P2010': 'Intake Manifold Runner Control Circuit High Bank 1',
      'P2011': 'Intake Manifold Runner Control Circuit/Open Bank 2',
      'P2012': 'Intake Manifold Runner Control Circuit Low Bank 2',
      'P2013': 'Intake Manifold Runner Control Circuit High Bank 2',
      'P2014': 'Intake Manifold Runner Position Sensor/Switch Circuit Bank 1',
      'P2015': 'Intake Manifold Runner Position Sensor/Switch Circuit Range/Performance Bank 1',
      'P2016': 'Intake Manifold Runner Position Sensor/Switch Circuit Low Bank 1',
      'P2017': 'Intake Manifold Runner Position Sensor/Switch Circuit High Bank 1',
      'P2018': 'Intake Manifold Runner Position Sensor/Switch Circuit Intermittent Bank 1',
      'P2019': 'Intake Manifold Runner Position Sensor/Switch Circuit Bank 2',
      'P2020': 'Intake Manifold Runner Position Sensor/Switch Circuit Range/Performance Bank 2',
      'P2021': 'Intake Manifold Runner Position Sensor/Switch Circuit Low Bank 2',
      'P2022': 'Intake Manifold Runner Position Sensor/Switch Circuit High Bank 2',
      'P2023': 'Intake Manifold Runner Position Sensor/Switch Circuit Intermittent Bank 2',
      'P2024': 'Evaporative Emission (EVAP) Fuel Vapor Temperature Sensor Circuit',
      'P2025': 'Evaporative Emission (EVAP) Fuel Vapor Temperature Sensor Circuit Range/Performance',
      'P2026': 'Evaporative Emission (EVAP) Fuel Vapor Temperature Sensor Circuit Low',
      'P2027': 'Evaporative Emission (EVAP) Fuel Vapor Temperature Sensor Circuit High',
      'P2028': 'Evaporative Emission (EVAP) Fuel Vapor Temperature Sensor Circuit Intermittent',
      'P2029': 'Fuel Fired Heater Circuit',
      'P2030': 'Fuel Fired Heater Circuit Range/Performance',
      'P2031': 'Fuel Fired Heater Circuit Low',
      'P2032': 'Fuel Fired Heater Circuit High',
      'P2033': 'Fuel Fired Heater Circuit Intermittent',
      'P2100': 'Throttle Actuator Control Motor Circuit/Open',
      'P2101': 'Throttle Actuator Control Motor Circuit Range/Performance',
      'P2102': 'Throttle Actuator Control Motor Circuit Low',
      'P2103': 'Throttle Actuator Control Motor Circuit High',
      'P2104': 'Throttle Actuator Control System - Forced Idle',
      'P2105': 'Throttle Actuator Control System - Forced Engine Shutdown',
      'P2106': 'Throttle Actuator Control System - Forced Limited Power',
      'P2107': 'Throttle Actuator Control Module Processor',
      'P2108': 'Throttle Actuator Control Module Performance',
      'P2109': 'Throttle/Pedal Position Sensor A Minimum Stop Performance',
      'P2110': 'Throttle Actuator Control System - Forced Limited RPM',
      'P2111': 'Throttle Actuator Control System - Stuck Open',
      'P2112': 'Throttle Actuator Control System - Stuck Closed',
      'P2113': 'Throttle/Pedal Position Sensor B Minimum Stop Performance',
      'P2114': 'Throttle/Pedal Position Sensor C Minimum Stop Performance',
      'P2115': 'Throttle/Pedal Position Sensor D Minimum Stop Performance',
      'P2116': 'Throttle/Pedal Position Sensor E Minimum Stop Performance',
      'P2117': 'Throttle/Pedal Position Sensor F Minimum Stop Performance',
      'P2118': 'Throttle Actuator Control Motor Current Range/Performance',
      'P2119': 'Throttle Actuator Control Throttle Body Range/Performance',
      'P2120': 'Throttle/Pedal Position Sensor/Switch D Circuit',
      'P2121': 'Throttle/Pedal Position Sensor/Switch D Circuit Range/Performance',
      'P2122': 'Throttle/Pedal Position Sensor/Switch D Circuit Low Input',
      'P2123': 'Throttle/Pedal Position Sensor/Switch D Circuit High Input',
      'P2124': 'Throttle/Pedal Position Sensor/Switch D Circuit Intermittent',
      'P2125': 'Throttle/Pedal Position Sensor/Switch E Circuit',
      'P2126': 'Throttle/Pedal Position Sensor/Switch E Circuit Range/Performance',
      'P2127': 'Throttle/Pedal Position Sensor/Switch E Circuit Low Input',
      'P2128': 'Throttle/Pedal Position Sensor/Switch E Circuit High Input',
      'P2129': 'Throttle/Pedal Position Sensor/Switch E Circuit Intermittent',
      'P2130': 'Throttle/Pedal Position Sensor/Switch F Circuit',
      'P2131': 'Throttle/Pedal Position Sensor/Switch F Circuit Range/Performance',
      'P2132': 'Throttle/Pedal Position Sensor/Switch F Circuit Low Input',
      'P2133': 'Throttle/Pedal Position Sensor/Switch F Circuit High Input',
      'P2134': 'Throttle/Pedal Position Sensor/Switch F Circuit Intermittent',
      'P2135': 'Throttle/Pedal Position Sensor/Switch A / B Voltage Correlation',
      'P2136': 'Throttle/Pedal Position Sensor/Switch A / C Voltage Correlation',
      'P2137': 'Throttle/Pedal Position Sensor/Switch B / C Voltage Correlation',
      'P2138': 'Throttle/Pedal Position Sensor/Switch D / E Voltage Correlation',
      'P2139': 'Throttle/Pedal Position Sensor/Switch D / F Voltage Correlation',
      'P2140': 'Throttle/Pedal Position Sensor/Switch E / F Voltage Correlation',
      'P2141': 'Exhaust Gas Recirculation Throttle Control Circuit Low',
      'P2142': 'Exhaust Gas Recirculation Throttle Control Circuit High',
      'P2143': 'Exhaust Gas Recirculation Vent Control Circuit/Open',
      'P2144': 'Exhaust Gas Recirculation Vent Control Circuit Low',
      'P2145': 'Exhaust Gas Recirculation Vent Control Circuit High',
      'P2146': 'Fuel Injector Group A Supply Voltage Circuit/Open',
      'P2147': 'Fuel Injector Group A Supply Voltage Circuit Low',
      'P2148': 'Fuel Injector Group A Supply Voltage Circuit High',
      'P2149': 'Fuel Injector Group B Supply Voltage Circuit/Open',
      'P2150': 'Fuel Injector Group B Supply Voltage Circuit Low',
      'P2151': 'Fuel Injector Group B Supply Voltage Circuit High',
      'P2152': 'Fuel Injector Group C Supply Voltage Circuit/Open',
      'P2153': 'Fuel Injector Group C Supply Voltage Circuit Low',
      'P2154': 'Fuel Injector Group C Supply Voltage Circuit High',
      'P2155': 'Fuel Injector Group D Supply Voltage Circuit/Open',
      'P2156': 'Fuel Injector Group D Supply Voltage Circuit Low',
      'P2157': 'Fuel Injector Group D Supply Voltage Circuit High',
      'P2158': 'Vehicle Speed Sensor B',
      'P2159': 'Vehicle Speed Sensor B Range/Performance',
      'P2160': 'Vehicle Speed Sensor B Circuit Low',
      'P2161': 'Vehicle Speed Sensor B Intermittent/Erratic',
      'P2162': 'Vehicle Speed Sensor A/B Correlation',
      'P2163': 'Throttle/Pedal Position Sensor A Maximum Stop Performance',
      'P2164': 'Throttle/Pedal Position Sensor B Maximum Stop Performance',
      'P2165': 'Throttle/Pedal Position Sensor C Maximum Stop Performance',
      'P2166': 'Throttle/Pedal Position Sensor D Maximum Stop Performance',
      'P2167': 'Throttle/Pedal Position Sensor E Maximum Stop Performance',
      'P2168': 'Throttle/Pedal Position Sensor F Maximum Stop Performance',
      'P2169': 'Exhaust Pressure Regulator Vent Solenoid Control Circuit/Open',
      'P2170': 'Exhaust Pressure Regulator Vent Solenoid Control Circuit Low',
      'P2171': 'Exhaust Pressure Regulator Vent Solenoid Control Circuit High',
      'P2172': 'Throttle Actuator Control System - Sudden High Airflow Detected',
      'P2173': 'Throttle Actuator Control System - High Airflow Detected',
      'P2174': 'Throttle Actuator Control System - Sudden Low Airflow Detected',
      'P2175': 'Throttle Actuator Control System - Low Airflow Detected',
      'P2176': 'Throttle Actuator Control System - Idle Position Not Learned',
      'P2177': 'System Too Lean Off Idle Bank 1',
      'P2178': 'System Too Rich Off Idle Bank 1',
      'P2179': 'System Too Lean Off Idle Bank 2',
      'P2180': 'System Too Rich Off Idle Bank 2',
      'P2181': 'Cooling System Performance',
      'P2182': 'Engine Coolant Temperature Sensor 2 Circuit',
      'P2183': 'Engine Coolant Temperature Sensor 2 Circuit Range/Performance',
      'P2184': 'Engine Coolant Temperature Sensor 2 Circuit Low',
      'P2185': 'Engine Coolant Temperature Sensor 2 Circuit High',
      'P2186': 'Engine Coolant Temperature Sensor 2 Circuit Intermittent/Erratic',
      'P2187': 'System Too Lean at Idle Bank 1',
      'P2188': 'System Too Rich at Idle Bank 1',
      'P2189': 'System Too Lean at Idle Bank 2',
      'P2190': 'System Too Rich at Idle Bank 2',
      'P2191': 'System Too Lean at Higher Load Bank 1',
      'P2192': 'System Too Rich at Higher Load Bank 1',
      'P2193': 'System Too Lean at Higher Load Bank 2',
      'P2194': 'System Too Rich at Higher Load Bank 2',
      'P2195': 'O2 Sensor Signal Biased/Stuck Lean Bank 1 Sensor 1',
      'P2196': 'O2 Sensor Signal Biased/Stuck Rich Bank 1 Sensor 1',
      'P2197': 'O2 Sensor Signal Biased/Stuck Lean Bank 2 Sensor 1',
      'P2198': 'O2 Sensor Signal Biased/Stuck Rich Bank 2 Sensor 1',
      'P2199': 'Intake Air Temperature Sensor 1/2 Correlation',
      'P2200': 'NOx Sensor Circuit Bank 1',
      'P2201': 'NOx Sensor Circuit Range/Performance Bank 1',
      'P2202': 'NOx Sensor Circuit Low Bank 1',
      'P2203': 'NOx Sensor Circuit High Bank 1',
      'P2204': 'NOx Sensor Circuit Intermittent Bank 1',
      'P2205': 'NOx Sensor Circuit Bank 2',
      'P2206': 'NOx Sensor Circuit Range/Performance Bank 2',
      'P2207': 'NOx Sensor Circuit Low Bank 2',
      'P2208': 'NOx Sensor Circuit High Bank 2',
      'P2209': 'NOx Sensor Circuit Intermittent Bank 2',
      'P2210': 'NOx Sensor Circuit Bank 1',
      'P2211': 'NOx Sensor Circuit Range/Performance Bank 1',
      'P2212': 'NOx Sensor Circuit Low Bank 1',
      'P2213': 'NOx Sensor Circuit High Bank 1',
      'P2214': 'NOx Sensor Circuit Intermittent Bank 1',
      'P2215': 'NOx Sensor Circuit Bank 2',
      'P2216': 'NOx Sensor Circuit Range/Performance Bank 2',
      'P2217': 'NOx Sensor Circuit Low Bank 2',
      'P2218': 'NOx Sensor Circuit High Bank 2',
      'P2219': 'NOx Sensor Circuit Intermittent Bank 2',
      'P2220': 'NOx Sensor Circuit Bank 1',
      'P2221': 'NOx Sensor Circuit Range/Performance Bank 1',
      'P2222': 'NOx Sensor Circuit Low Bank 1',
      'P2223': 'NOx Sensor Circuit High Bank 1',
      'P2224': 'NOx Sensor Circuit Intermittent Bank 1',
      'P2225': 'NOx Sensor Circuit Bank 2',
      'P2226': 'NOx Sensor Circuit Range/Performance Bank 2',
      'P2227': 'NOx Sensor Circuit Low Bank 2',
      'P2228': 'NOx Sensor Circuit High Bank 2',
      'P2229': 'NOx Sensor Circuit Intermittent Bank 2',
      'P2230': 'NOx Sensor Circuit Bank 1',
      'P2231': 'NOx Sensor Circuit Range/Performance Bank 1',
      'P2232': 'NOx Sensor Circuit Low Bank 1',
      'P2233': 'NOx Sensor Circuit High Bank 1',
      'P2234': 'NOx Sensor Circuit Intermittent Bank 1',
      'P2235': 'NOx Sensor Circuit Bank 2',
      'P2236': 'NOx Sensor Circuit Range/Performance Bank 2',
      'P2237': 'NOx Sensor Circuit Low Bank 2',
      'P2238': 'NOx Sensor Circuit High Bank 2',
      'P2239': 'NOx Sensor Circuit Intermittent Bank 2',
      'P2240': 'O2 Sensor Signal Biased/Stuck Lean Bank 1 Sensor 1',
      'P2241': 'O2 Sensor Signal Biased/Stuck Rich Bank 1 Sensor 1',
      'P2242': 'O2 Sensor Signal Biased/Stuck Lean Bank 2 Sensor 1',
      'P2243': 'O2 Sensor Signal Biased/Stuck Rich Bank 2 Sensor 1',
      'P2244': 'O2 Sensor Signal Biased/Stuck Lean Bank 1 Sensor 2',
      'P2245': 'O2 Sensor Signal Biased/Stuck Rich Bank 1 Sensor 2',
      'P2246': 'O2 Sensor Signal Biased/Stuck Lean Bank 2 Sensor 2',
      'P2247': 'O2 Sensor Signal Biased/Stuck Rich Bank 2 Sensor 2',
      'P2248': 'O2 Sensor Signal Biased/Stuck Lean Bank 1 Sensor 3',
      'P2249': 'O2 Sensor Signal Biased/Stuck Rich Bank 1 Sensor 3',
      'P2250': 'O2 Sensor Signal Biased/Stuck Lean Bank 2 Sensor 3',
      'P2251': 'O2 Sensor Signal Biased/Stuck Rich Bank 2 Sensor 3',
      'P2252': 'O2 Sensor Signal Biased/Stuck Lean Bank 1 Sensor 4',
      'P2253': 'O2 Sensor Signal Biased/Stuck Rich Bank 1 Sensor 4',
      'P2254': 'O2 Sensor Signal Biased/Stuck Lean Bank 2 Sensor 4',
      'P2255': 'O2 Sensor Signal Biased/Stuck Rich Bank 2 Sensor 4',
      'P2256': 'O2 Sensor Signal Biased/Stuck Lean Bank 1 Sensor 5',
      'P2257': 'O2 Sensor Signal Biased/Stuck Rich Bank 1 Sensor 5',
      'P2258': 'O2 Sensor Signal Biased/Stuck Lean Bank 2 Sensor 5',
      'P2259': 'O2 Sensor Signal Biased/Stuck Rich Bank 2 Sensor 5',
      'P2260': 'O2 Sensor Signal Biased/Stuck Lean Bank 1 Sensor 6',
      'P2261': 'O2 Sensor Signal Biased/Stuck Rich Bank 1 Sensor 6',
      'P2262': 'O2 Sensor Signal Biased/Stuck Lean Bank 2 Sensor 6',
      'P2263': 'O2 Sensor Signal Biased/Stuck Rich Bank 2 Sensor 6',
      'P2264': 'Water in Fuel Sensor Circuit',
      'P2265': 'Water in Fuel Sensor Circuit Range/Performance',
      'P2266': 'Water in Fuel Sensor Circuit Low',
      'P2267': 'Water in Fuel Sensor Circuit High',
      'P2268': 'Water in Fuel Sensor Circuit Intermittent',
      'P2269': 'Water in Fuel Condition',
      'P2270': 'O2 Sensor Signal Biased/Stuck Lean Bank 1 Sensor 2',
      'P2271': 'O2 Sensor Signal Biased/Stuck Rich Bank 1 Sensor 2',
      'P2272': 'O2 Sensor Signal Biased/Stuck Lean Bank 2 Sensor 2',
      'P2273': 'O2 Sensor Signal Biased/Stuck Rich Bank 2 Sensor 2',
      'P2274': 'O2 Sensor Signal Biased/Stuck Lean Bank 1 Sensor 3',
      'P2275': 'O2 Sensor Signal Biased/Stuck Rich Bank 1 Sensor 3',
      'P2276': 'O2 Sensor Signal Biased/Stuck Lean Bank 2 Sensor 3',
      'P2277': 'O2 Sensor Signal Biased/Stuck Rich Bank 2 Sensor 3',
      'P2278': 'O2 Sensor Signal Biased/Stuck Lean Bank 1 Sensor 4',
      'P2279': 'O2 Sensor Signal Biased/Stuck Rich Bank 1 Sensor 4',
      'P2280': 'O2 Sensor Signal Biased/Stuck Lean Bank 2 Sensor 4',
      'P2281': 'O2 Sensor Signal Biased/Stuck Rich Bank 2 Sensor 4',
      'P2282': 'Air Leak Between Throttle Body and Intake Valves',
      'P2283': 'Injector Control Pressure Sensor Circuit',
      'P2284': 'Injector Control Pressure Sensor Circuit Range/Performance',
      'P2285': 'Injector Control Pressure Sensor Circuit Low',
      'P2286': 'Injector Control Pressure Sensor Circuit High',
      'P2287': 'Injector Control Pressure Sensor Circuit Intermittent',
      'P2288': 'Injector Control Pressure Too High',
      'P2289': 'Injector Control Pressure Too High - Engine Off',
      'P2290': 'Injector Control Pressure Too Low',
      'P2291': 'Injector Control Pressure Too Low - Engine Cranking',
      'P2292': 'Injector Control Pressure Too Low - Engine Running',
      'P2293': 'Fuel Pressure Regulator 2 Performance',
      'P2294': 'Fuel Pressure Regulator 2 Control Circuit',
      'P2295': 'Fuel Pressure Regulator 2 Control Circuit Low',
      'P2296': 'Fuel Pressure Regulator 2 Control Circuit High',
      'P2297': 'O2 Sensor Out of Range During Deceleration Bank 1 Sensor 1',
      'P2298': 'O2 Sensor Out of Range During Deceleration Bank 2 Sensor 1',
      'P2299': 'Brake Pedal Position/Accelerator Pedal Position Incompatible',
      'P2300': 'Ignition Coil A Primary Control Circuit Low',
      'P2301': 'Ignition Coil A Primary Control Circuit High',
      'P2302': 'Ignition Coil A Secondary Circuit',
      'P2303': 'Ignition Coil B Primary Control Circuit Low',
      'P2304': 'Ignition Coil B Primary Control Circuit High',
      'P2305': 'Ignition Coil B Secondary Circuit',
      'P2306': 'Ignition Coil C Primary Control Circuit Low',
      'P2307': 'Ignition Coil C Primary Control Circuit High',
      'P2308': 'Ignition Coil C Secondary Circuit',
      'P2309': 'Ignition Coil D Primary Control Circuit Low',
      'P2310': 'Ignition Coil D Primary Control Circuit High',
      'P2311': 'Ignition Coil D Secondary Circuit',
      'P2312': 'Ignition Coil E Primary Control Circuit Low',
      'P2313': 'Ignition Coil E Primary Control Circuit High',
      'P2314': 'Ignition Coil E Secondary Circuit',
      'P2315': 'Ignition Coil F Primary Control Circuit Low',
      'P2316': 'Ignition Coil F Primary Control Circuit High',
      'P2317': 'Ignition Coil F Secondary Circuit',
      'P2318': 'Ignition Coil G Primary Control Circuit Low',
      'P2319': 'Ignition Coil G Primary Control Circuit High',
      'P2320': 'Ignition Coil G Secondary Circuit',
      'P2321': 'Ignition Coil H Primary Control Circuit Low',
      'P2322': 'Ignition Coil H Primary Control Circuit High',
      'P2323': 'Ignition Coil H Secondary Circuit',
      'P2324': 'Ignition Coil I Primary Control Circuit Low',
      'P2325': 'Ignition Coil I Primary Control Circuit High',
      'P2326': 'Ignition Coil I Secondary Circuit',
      'P2327': 'Ignition Coil J Primary Control Circuit Low',
      'P2328': 'Ignition Coil J Primary Control Circuit High',
      'P2329': 'Ignition Coil J Secondary Circuit',
      'P2330': 'Ignition Coil K Primary Control Circuit Low',
      'P2331': 'Ignition Coil K Primary Control Circuit High',
      'P2332': 'Ignition Coil K Secondary Circuit',
      'P2333': 'Ignition Coil L Primary Control Circuit Low',
      'P2334': 'Ignition Coil L Primary Control Circuit High',
      'P2335': 'Ignition Coil L Secondary Circuit',
      'P2336': 'Cylinder 1 Above Knock Threshold',
      'P2337': 'Cylinder 2 Above Knock Threshold',
      'P2338': 'Cylinder 3 Above Knock Threshold',
      'P2339': 'Cylinder 4 Above Knock Threshold',
      'P2340': 'Cylinder 5 Above Knock Threshold',
      'P2341': 'Cylinder 6 Above Knock Threshold',
      'P2342': 'Cylinder 7 Above Knock Threshold',
      'P2343': 'Cylinder 8 Above Knock Threshold',
      'P2344': 'Cylinder 9 Above Knock Threshold',
      'P2345': 'Cylinder 10 Above Knock Threshold',
      'P2346': 'Cylinder 11 Above Knock Threshold',
      'P2347': 'Cylinder 12 Above Knock Threshold',
      'P2400': 'EVAP Leak Detection Pump Control Circuit/Open',
      'P2401': 'EVAP Leak Detection Pump Control Circuit Low',
      'P2402': 'EVAP Leak Detection Pump Control Circuit High',
      'P2403': 'EVAP Leak Detection Pump Sense Circuit/Open',
      'P2404': 'EVAP Leak Detection Pump Sense Circuit Range/Performance',
      'P2405': 'EVAP Leak Detection Pump Sense Circuit Low',
      'P2406': 'EVAP Leak Detection Pump Sense Circuit High',
      'P2407': 'EVAP Leak Detection Pump Sense Circuit Intermittent/Erratic',
      'P2408': 'Fuel Cap Sensor/Switch Circuit',
      'P2409': 'Fuel Cap Sensor/Switch Circuit Range/Performance',
      'P2410': 'Fuel Cap Sensor/Switch Circuit Low',
      'P2411': 'Fuel Cap Sensor/Switch Circuit High',
      'P2412': 'Fuel Cap Sensor/Switch Circuit Intermittent/Erratic',
      'P2413': 'EGR System Performance',
      'P2414': 'O2 Sensor Exhaust Sample Error Bank 1 Sensor 1',
      'P2415': 'O2 Sensor Exhaust Sample Error Bank 2 Sensor 1',
      'P2416': 'O2 Sensor Signals Swapped Bank 1 Sensor 2 / Bank 2 Sensor 2',
      'P2417': 'O2 Sensor Signals Swapped Bank 1 Sensor 3 / Bank 2 Sensor 3',
      'P2418': 'EVAP Switching Valve Control Circuit/Open',
      'P2419': 'EVAP Switching Valve Control Circuit Low',
      'P2420': 'EVAP Switching Valve Control Circuit High',
      'P2421': 'EVAP Vent Valve Stuck Open',
      'P2422': 'EVAP Vent Valve Stuck Closed',
      'P2423': 'HC Adsorption Catalyst Efficiency Below Threshold Bank 1',
      'P2424': 'HC Adsorption Catalyst Efficiency Below Threshold Bank 2',
      'P2425': 'EGR Cooler Bypass Control Circuit/Open',
      'P2426': 'EGR Cooler Bypass Control Circuit Low',
      'P2427': 'EGR Cooler Bypass Control Circuit High',
      'P2428': 'Exhaust Gas Temperature Too High Bank 1',
      'P2429': 'Exhaust Gas Temperature Too High Bank 2',
      'P2430': 'Secondary Air Injection System Air Flow/Pressure Sensor Circuit Bank 1',
      'P2431': 'Secondary Air Injection System Air Flow/Pressure Sensor Circuit Range/Performance Bank 1',
      'P2432': 'Secondary Air Injection System Air Flow/Pressure Sensor Circuit Low Bank 1',
      'P2433': 'Secondary Air Injection System Air Flow/Pressure Sensor Circuit High Bank 1',
      'P2434': 'Secondary Air Injection System Air Flow/Pressure Sensor Circuit Intermittent Bank 1',
      'P2435': 'Secondary Air Injection System Air Flow/Pressure Sensor Circuit Bank 2',
      'P2436': 'Secondary Air Injection System Air Flow/Pressure Sensor Circuit Range/Performance Bank 2',
      'P2437': 'Secondary Air Injection System Air Flow/Pressure Sensor Circuit Low Bank 2',
      'P2438': 'Secondary Air Injection System Air Flow/Pressure Sensor Circuit High Bank 2',
      'P2439': 'Secondary Air Injection System Air Flow/Pressure Sensor Circuit Intermittent Bank 2',
      'P2440': 'Secondary Air Injection System Switching Valve Stuck Open Bank 1',
      'P2441': 'Secondary Air Injection System Switching Valve Stuck Closed Bank 1',
      'P2442': 'Secondary Air Injection System Switching Valve Stuck Open Bank 2',
      'P2443': 'Secondary Air Injection System Switching Valve Stuck Closed Bank 2',
      'P2444': 'Secondary Air Injection System Pump Stuck On Bank 1',
      'P2445': 'Secondary Air Injection System Pump Stuck Off Bank 1',
      'P2446': 'Secondary Air Injection System Pump Stuck On Bank 2',
      'P2447': 'Secondary Air Injection System Pump Stuck Off Bank 2',
      'P2448': 'Secondary Air Injection System Pump Stuck On',
      'P2449': 'Secondary Air Injection System Pump Stuck Off',
      'P2450': 'EVAP Switching Valve Performance',
      'P2451': 'Particulate Filter Pressure Sensor A Circuit',
      'P2452': 'Particulate Filter Pressure Sensor A Circuit Range/Performance',
      'P2453': 'Particulate Filter Pressure Sensor A Circuit Low',
      'P2454': 'Particulate Filter Pressure Sensor A Circuit High',
      'P2455': 'Particulate Filter Pressure Sensor A Circuit Intermittent',
      'P2456': 'Particulate Filter Pressure Sensor B Circuit',
      'P2457': 'Particulate Filter Pressure Sensor B Circuit Range/Performance',
      'P2458': 'Particulate Filter Pressure Sensor B Circuit Low',
      'P2459': 'Particulate Filter Pressure Sensor B Circuit High',
      'P2460': 'Particulate Filter Pressure Sensor B Circuit Intermittent',
      'P2461': 'Particulate Filter Restriction - Forced Limited Power',
      'P2462': 'Particulate Filter Restriction - Forced Limited Power',
      'P2463': 'Particulate Filter Restriction - Forced Limited Power',
      'P2500': 'Generator L-Terminal Circuit Low',
      'P2501': 'Generator L-Terminal Circuit High',
      'P2502': 'Charging System Voltage',
      'P2503': 'Charging System Voltage Low',
      'P2504': 'Charging System Voltage High',
      'P2505': 'ECM/PCM Power Input Signal',
      'P2506': 'ECM/PCM Power Input Signal Range/Performance',
      'P2507': 'ECM/PCM Power Input Signal Low',
      'P2508': 'ECM/PCM Power Input Signal High',
      'P2509': 'ECM/PCM Power Input Signal Intermittent',
      'P2510': 'ECM/PCM Power Relay Sense Circuit Range/Performance',
      'P2511': 'ECM/PCM Power Relay Sense Circuit Intermittent',
      'P2512': 'Event Data Recorder Request Circuit/Open',
      'P2513': 'Event Data Recorder Request Circuit Low',
      'P2514': 'Event Data Recorder Request Circuit High',
      'P2515': 'Event Data Recorder Request Circuit Intermittent',
      'P2516': 'B+ Voltage Circuit Low',
      'P2517': 'B+ Voltage Circuit High',
      'P2518': 'B+ Voltage Circuit Intermittent/Erratic',
      'P2519': 'A/C Request A Circuit',
      'P2520': 'A/C Request A Circuit Low',
      'P2521': 'A/C Request A Circuit High',
      'P2522': 'A/C Request B Circuit',
      'P2523': 'A/C Request B Circuit Low',
      'P2524': 'A/C Request B Circuit High',
      'P2525': 'Vacuum Reservoir Pressure Sensor Circuit',
      'P2526': 'Vacuum Reservoir Pressure Sensor Circuit Range/Performance',
      'P2527': 'Vacuum Reservoir Pressure Sensor Circuit Low',
      'P2528': 'Vacuum Reservoir Pressure Sensor Circuit High',
      'P2529': 'Vacuum Reservoir Pressure Sensor Circuit Intermittent',
      'P2530': 'Ignition Switch Run Position Circuit',
      'P2531': 'Ignition Switch Run Position Circuit Low',
      'P2532': 'Ignition Switch Run Position Circuit High',
      'P2533': 'Ignition Switch Start Position Circuit',
      'P2534': 'Ignition Switch Start Position Circuit Low',
      'P2535': 'Ignition Switch Start Position Circuit High',
      'P2536': 'Ignition Switch Accessory Position Circuit',
      'P2537': 'Ignition Switch Accessory Position Circuit Low',
      'P2538': 'Ignition Switch Accessory Position Circuit High',
      'P2539': 'A/C Pressure Sensor A Circuit Low',
      'P2540': 'A/C Pressure Sensor A Circuit High',
      'P2541': 'A/C Pressure Sensor B Circuit',
      'P2542': 'A/C Pressure Sensor B Circuit Range/Performance',
      'P2543': 'A/C Pressure Sensor B Circuit Low',
      'P2544': 'A/C Pressure Sensor B Circuit High',
      'P2545': 'A/C Pressure Sensor B Circuit Intermittent',
      'P2546': 'A/C Pressure Sensor C Circuit',
      'P2547': 'A/C Pressure Sensor C Circuit Range/Performance',
      'P2548': 'A/C Pressure Sensor C Circuit Low',
      'P2549': 'A/C Pressure Sensor C Circuit High',
      'P2550': 'A/C Pressure Sensor C Circuit Intermittent',
      'P2551': 'Throttle/Fuel Inhibit Circuit',
      'P2552': 'Throttle/Fuel Inhibit Circuit Range/Performance',
      'P2553': 'Throttle/Fuel Inhibit Circuit Low',
      'P2554': 'Throttle/Fuel Inhibit Circuit High',
      'P2555': 'Throttle/Fuel Inhibit Circuit Intermittent',
      'P2556': 'Engine Coolant Level Sensor/Switch Circuit',
      'P2557': 'Engine Coolant Level Sensor/Switch Circuit Range/Performance',
      'P2558': 'Engine Coolant Level Sensor/Switch Circuit Low',
      'P2559': 'Engine Coolant Level Sensor/Switch Circuit High',
      'P2560': 'Engine Coolant Level Sensor/Switch Circuit Intermittent',
      'P2561': 'A/C Control Module Requested MIL Illumination',
      'P2562': 'Turbocharger Boost Control Position Sensor Circuit',
      'P2563': 'Turbocharger Boost Control Position Sensor Circuit Range/Performance',
      'P2564': 'Turbocharger Boost Control Position Sensor Circuit Low',
      'P2565': 'Turbocharger Boost Control Position Sensor Circuit High',
      'P2566': 'Turbocharger Boost Control Position Sensor Circuit Intermittent',
      'P2567': 'Direct Ozone Reduction Catalyst Temperature Sensor Circuit',
      'P2568': 'Direct Ozone Reduction Catalyst Temperature Sensor Circuit Range/Performance',
      'P2569': 'Direct Ozone Reduction Catalyst Temperature Sensor Circuit Low',
      'P2570': 'Direct Ozone Reduction Catalyst Temperature Sensor Circuit High',
      'P2571': 'Direct Ozone Reduction Catalyst Temperature Sensor Circuit Intermittent',
      'P2572': 'Direct Ozone Reduction Catalyst Efficiency Below Threshold',
      'P2573': 'Direct Ozone Reduction Catalyst Efficiency Below Threshold',
      'P2574': 'Direct Ozone Reduction Catalyst Temperature Sensor Circuit Range/Performance',
      'P2575': 'Direct Ozone Reduction Catalyst Temperature Sensor Circuit Low',
      'P2576': 'Direct Ozone Reduction Catalyst Temperature Sensor Circuit High',
      'P2577': 'Direct Ozone Reduction Catalyst Temperature Sensor Circuit Intermittent',
      'P2578': 'Direct Ozone Reduction Catalyst Efficiency Below Threshold',
      'P2579': 'Direct Ozone Reduction Catalyst Efficiency Below Threshold',
      'P2580': 'Direct Ozone Reduction Catalyst Temperature Sensor Circuit Range/Performance',
      'P2581': 'Direct Ozone Reduction Catalyst Temperature Sensor Circuit Low',
      'P2582': 'Direct Ozone Reduction Catalyst Temperature Sensor Circuit High',
      'P2583': 'Direct Ozone Reduction Catalyst Temperature Sensor Circuit Intermittent',
      'P2584': 'Direct Ozone Reduction Catalyst Efficiency Below Threshold',
      'P2585': 'Direct Ozone Reduction Catalyst Efficiency Below Threshold',
      'P2586': 'Turbocharger Boost Control Position Sensor B Circuit',
      'P2587': 'Turbocharger Boost Control Position Sensor B Circuit Range/Performance',
      'P2588': 'Turbocharger Boost Control Position Sensor B Circuit Low',
      'P2589': 'Turbocharger Boost Control Position Sensor B Circuit High',
      'P2590': 'Turbocharger Boost Control Position Sensor B Circuit Intermittent',
      'P2591': 'ECM/PCM Power Relay Control Circuit/Open',
      'P2592': 'ECM/PCM Power Relay Control Circuit Low',
      'P2593': 'ECM/PCM Power Relay Control Circuit High',
      'P2594': 'Turbocharger Boost Control Solenoid A Control Circuit',
      'P2595': 'Turbocharger Boost Control Solenoid A Control Circuit Low',
      'P2596': 'Turbocharger Boost Control Solenoid A Control Circuit High',
      'P2597': 'Turbocharger Boost Control Solenoid B Control Circuit',
      'P2598': 'Turbocharger Boost Control Solenoid B Control Circuit Low',
      'P2599': 'Turbocharger Boost Control Solenoid B Control Circuit High',
      'P2600': 'Coolant Pump Control Circuit/Open',
      'P2601': 'Coolant Pump Control Circuit Range/Performance',
      'P2602': 'Coolant Pump Control Circuit Low',
      'P2603': 'Coolant Pump Control Circuit High',
      'P2604': 'Intake Air Heater A Circuit Range/Performance',
      'P2605': 'Intake Air Heater A Circuit/Open',
      'P2606': 'Intake Air Heater A Circuit Low',
      'P2607': 'Intake Air Heater A Circuit High',
      'P2608': 'Intake Air Heater A Circuit Intermittent',
      'P2609': 'Intake Air Heater System Performance',
      'P2610': 'ECM/PCM Internal Engine Off Timer Performance',
      'P2611': 'A/C Clutch Relay Control Circuit',
      'P2612': 'A/C Clutch Relay Control Circuit Low',
      'P2613': 'A/C Clutch Relay Control Circuit High',
      'P2614': 'Camshaft Position Output Circuit',
      'P2615': 'Camshaft Position Output Circuit Low',
      'P2616': 'Camshaft Position Output Circuit High',
      'P2617': 'Crankshaft Position Output Circuit',
      'P2618': 'Crankshaft Position Output Circuit Low',
      'P2619': 'Crankshaft Position Output Circuit High',
      'P2620': 'Throttle Position Output Circuit',
      'P2621': 'Throttle Position Output Circuit Low',
      'P2622': 'Throttle Position Output Circuit High',
      'P2623': 'Injector Control Pressure Regulator Control Circuit',
      'P2624': 'Injector Control Pressure Regulator Control Circuit Low',
      'P2625': 'Injector Control Pressure Regulator Control Circuit High',
      'P2626': 'O2 Sensor Pumping Current Trim Circuit/Open Bank 1 Sensor 1',
      'P2627': 'O2 Sensor Pumping Current Trim Circuit Low Bank 1 Sensor 1',
      'P2628': 'O2 Sensor Pumping Current Trim Circuit High Bank 1 Sensor 1',
      'P2629': 'O2 Sensor Pumping Current Trim Circuit/Open Bank 2 Sensor 1',
      'P2630': 'O2 Sensor Pumping Current Trim Circuit Low Bank 2 Sensor 1',
      'P2631': 'O2 Sensor Pumping Current Trim Circuit High Bank 2 Sensor 1',
      'P2632': 'Fuel Pump B Control Circuit/Open',
      'P2633': 'Fuel Pump B Control Circuit Low',
      'P2634': 'Fuel Pump B Control Circuit High',
      'P2635': 'Fuel Pump A Low Flow/Performance',
      'P2636': 'Fuel Pump B Low Flow/Performance',
      'P2637': 'Torque Management Feedback Signal A',
      'P2638': 'Torque Management Feedback Signal A Range/Performance',
      'P2639': 'Torque Management Feedback Signal A Low',
      'P2640': 'Torque Management Feedback Signal A High',
      'P2641': 'Torque Management Feedback Signal B',
      'P2642': 'Torque Management Feedback Signal B Range/Performance',
      'P2643': 'Torque Management Feedback Signal B Low',
      'P2644': 'Torque Management Feedback Signal B High',
      'P2645': 'A Rocker Arm Actuator Control Circuit/Open (Bank 1)',
      'P2646': 'A Rocker Arm Actuator Control Circuit Low (Bank 1)',
      'P2647': 'A Rocker Arm Actuator Control Circuit High (Bank 1)',
      'P2648': 'A Rocker Arm Actuator Control Circuit/Open (Bank 2)',
      'P2649': 'A Rocker Arm Actuator Control Circuit Low (Bank 2)',
      'P2650': 'A Rocker Arm Actuator Control Circuit High (Bank 2)',
      'P2651': 'B Rocker Arm Actuator Control Circuit/Open (Bank 1)',
      'P2652': 'B Rocker Arm Actuator Control Circuit Low (Bank 1)',
      'P2653': 'B Rocker Arm Actuator Control Circuit High (Bank 1)',
      'P2654': 'B Rocker Arm Actuator Control Circuit/Open (Bank 2)',
      'P2655': 'B Rocker Arm Actuator Control Circuit Low (Bank 2)',
      'P2656': 'B Rocker Arm Actuator Control Circuit High (Bank 2)',
      'P2657': 'A Rocker Arm Actuator Position Sensor Circuit/Open (Bank 1)',
      'P2658': 'A Rocker Arm Actuator Position Sensor Circuit Low (Bank 1)',
      'P2659': 'A Rocker Arm Actuator Position Sensor Circuit High (Bank 1)',
      'P2660': 'A Rocker Arm Actuator Position Sensor Circuit/Open (Bank 2)',
      'P2661': 'A Rocker Arm Actuator Position Sensor Circuit Low (Bank 2)',
      'P2662': 'A Rocker Arm Actuator Position Sensor Circuit High (Bank 2)',
      'P2663': 'B Rocker Arm Actuator Position Sensor Circuit/Open (Bank 1)',
      'P2664': 'B Rocker Arm Actuator Position Sensor Circuit Low (Bank 1)',
      'P2665': 'B Rocker Arm Actuator Position Sensor Circuit High (Bank 1)',
      'P2666': 'B Rocker Arm Actuator Position Sensor Circuit/Open (Bank 2)',
      'P2667': 'B Rocker Arm Actuator Position Sensor Circuit Low (Bank 2)',
      'P2668': 'B Rocker Arm Actuator Position Sensor Circuit High (Bank 2)',
      'P2669': 'Actuator Supply Voltage B Circuit/Open',
      'P2670': 'Actuator Supply Voltage B Circuit Low',
      'P2671': 'Actuator Supply Voltage B Circuit High',
      'P2672': 'Actuator Supply Voltage C Circuit/Open',
      'P2673': 'Actuator Supply Voltage C Circuit Low',
      'P2674': 'Actuator Supply Voltage C Circuit High',
      'P2675': 'Actuator Supply Voltage D Circuit/Open',
      'P2676': 'Actuator Supply Voltage D Circuit Low',
      'P2677': 'Actuator Supply Voltage D Circuit High',
      'P2700': 'Transmission Friction Element A Apply Time Range/Performance',
      'P2701': 'Transmission Friction Element B Apply Time Range/Performance',
      'P2702': 'Transmission Friction Element C Apply Time Range/Performance',
      'P2703': 'Transmission Friction Element D Apply Time Range/Performance',
      'P2704': 'Transmission Friction Element E Apply Time Range/Performance',
      'P2705': 'Transmission Friction Element F Apply Time Range/Performance',
      'P2706': 'Shift Solenoid F Performance or Stuck Off',
      'P2707': 'Shift Solenoid F Stuck On',
      'P2708': 'Shift Solenoid F Electrical',
      'P2709': 'Shift Solenoid F Intermittent',
      'P2710': 'Shift Solenoid G Performance or Stuck Off',
      'P2711': 'Shift Solenoid G Stuck On',
      'P2712': 'Shift Solenoid G Electrical',
      'P2713': 'Shift Solenoid G Intermittent',
      'P2714': 'Pressure Control Solenoid D Performance or Stuck Off',
      'P2715': 'Pressure Control Solenoid D Stuck On',
      'P2716': 'Pressure Control Solenoid D Electrical',
      'P2717': 'Pressure Control Solenoid D Intermittent',
      'P2718': 'Pressure Control Solenoid E Performance or Stuck Off',
      'P2719': 'Pressure Control Solenoid E Stuck On',
      'P2720': 'Pressure Control Solenoid E Electrical',
      'P2721': 'Pressure Control Solenoid E Intermittent',
      'P2722': 'Pressure Control Solenoid F Performance or Stuck Off',
      'P2723': 'Pressure Control Solenoid F Stuck On',
      'P2724': 'Pressure Control Solenoid F Electrical',
      'P2725': 'Pressure Control Solenoid F Intermittent',
      'P2726': 'Pressure Control Solenoid G Performance or Stuck Off',
      'P2727': 'Pressure Control Solenoid G Stuck On',
      'P2728': 'Pressure Control Solenoid G Electrical',
      'P2729': 'Pressure Control Solenoid G Intermittent',
      'P2730': 'Pressure Control Solenoid H Performance or Stuck Off',
      'P2731': 'Pressure Control Solenoid H Stuck On',
      'P2732': 'Pressure Control Solenoid H Electrical',
      'P2733': 'Pressure Control Solenoid H Intermittent',
      'P2734': 'Pressure Control Solenoid I Performance or Stuck Off',
      'P2735': 'Pressure Control Solenoid I Stuck On',
      'P2736': 'Pressure Control Solenoid I Electrical',
      'P2737': 'Pressure Control Solenoid I Intermittent',
      'P2738': 'Pressure Control Solenoid J Performance or Stuck Off',
      'P2739': 'Pressure Control Solenoid J Stuck On',
      'P2740': 'Pressure Control Solenoid J Electrical',
      'P2741': 'Pressure Control Solenoid J Intermittent',
      'P2742': 'Pressure Control Solenoid K Performance or Stuck Off',
      'P2743': 'Pressure Control Solenoid K Stuck On',
      'P2744': 'Pressure Control Solenoid K Electrical',
      'P2745': 'Pressure Control Solenoid K Intermittent',
      'P2746': 'Pressure Control Solenoid L Performance or Stuck Off',
      'P2747': 'Pressure Control Solenoid L Stuck On',
      'P2748': 'Pressure Control Solenoid L Electrical',
      'P2749': 'Pressure Control Solenoid L Intermittent',
      'P2750': 'A/T Clutch Pressure Control Solenoid A',
      'P2751': 'A/T Clutch Pressure Control Solenoid A Performance or Stuck Off',
      'P2752': 'A/T Clutch Pressure Control Solenoid A Stuck On',
      'P2753': 'A/T Clutch Pressure Control Solenoid A Electrical',
      'P2754': 'A/T Clutch Pressure Control Solenoid A Intermittent',
      'P2755': 'A/T Clutch Pressure Control Solenoid B',
      'P2756': 'A/T Clutch Pressure Control Solenoid B Performance or Stuck Off',
      'P2757': 'A/T Clutch Pressure Control Solenoid B Stuck On',
      'P2758': 'A/T Clutch Pressure Control Solenoid B Electrical',
      'P2759': 'A/T Clutch Pressure Control Solenoid B Intermittent',
      'P2760': 'A/T Clutch Pressure Control Solenoid C',
      'P2761': 'A/T Clutch Pressure Control Solenoid C Performance or Stuck Off',
      'P2762': 'A/T Clutch Pressure Control Solenoid C Stuck On',
      'P2763': 'A/T Clutch Pressure Control Solenoid C Electrical',
      'P2764': 'A/T Clutch Pressure Control Solenoid C Intermittent',
      'P2765': 'A/T Clutch Pressure Control Solenoid D',
      'P2766': 'A/T Clutch Pressure Control Solenoid D Performance or Stuck Off',
      'P2767': 'A/T Clutch Pressure Control Solenoid D Stuck On',
      'P2768': 'A/T Clutch Pressure Control Solenoid D Electrical',
      'P2769': 'A/T Clutch Pressure Control Solenoid D Intermittent',
      'P2770': 'A/T Clutch Pressure Control Solenoid E',
      'P2771': 'A/T Clutch Pressure Control Solenoid E Performance or Stuck Off',
      'P2772': 'A/T Clutch Pressure Control Solenoid E Stuck On',
      'P2773': 'A/T Clutch Pressure Control Solenoid E Electrical',
      'P2774': 'A/T Clutch Pressure Control Solenoid E Intermittent',
      'P2775': 'A/T Clutch Pressure Control Solenoid F',
      'P2776': 'A/T Clutch Pressure Control Solenoid F Performance or Stuck Off',
      'P2777': 'A/T Clutch Pressure Control Solenoid F Stuck On',
      'P2778': 'A/T Clutch Pressure Control Solenoid F Electrical',
      'P2779': 'A/T Clutch Pressure Control Solenoid F Intermittent',
      'P2780': 'A/T Clutch Pressure Control Solenoid G',
      'P2781': 'A/T Clutch Pressure Control Solenoid G Performance or Stuck Off',
      'P2782': 'A/T Clutch Pressure Control Solenoid G Stuck On',
      'P2783': 'A/T Clutch Pressure Control Solenoid G Electrical',
      'P2784': 'A/T Clutch Pressure Control Solenoid G Intermittent',
      'P2785': 'A/T Clutch Pressure Control Solenoid H',
      'P2786': 'A/T Clutch Pressure Control Solenoid H Performance or Stuck Off',
      'P2787': 'A/T Clutch Pressure Control Solenoid H Stuck On',
      'P2788': 'A/T Clutch Pressure Control Solenoid H Electrical',
      'P2789': 'A/T Clutch Pressure Control Solenoid H Intermittent',
      'P2790': 'A/T Clutch Pressure Control Solenoid I',
      'P2791': 'A/T Clutch Pressure Control Solenoid I Performance or Stuck Off',
      'P2792': 'A/T Clutch Pressure Control Solenoid I Stuck On',
      'P2793': 'A/T Clutch Pressure Control Solenoid I Electrical',
      'P2794': 'A/T Clutch Pressure Control Solenoid I Intermittent',
      'P2795': 'A/T Clutch Pressure Control Solenoid J',
      'P2796': 'A/T Clutch Pressure Control Solenoid J Performance or Stuck Off',
      'P2797': 'A/T Clutch Pressure Control Solenoid J Stuck On',
      'P2798': 'A/T Clutch Pressure Control Solenoid J Electrical',
      'P2799': 'A/T Clutch Pressure Control Solenoid J Intermittent',
    };
    
    return dtcDescriptions[code] ?? 'Unknown diagnostic trouble code';
  }
  
  /// Request specific OBD2 data
  Future<void> requestData(String dataType) async {
    if (!_isConnected) {
      debugPrint('❌ Cannot request $dataType: Not connected to OBD2 scanner');
      return;
    }
    
    debugPrint('🔍 Requesting $dataType data from OBD2 scanner...');
    debugPrint('📊 Current live data before request: $_liveData');
    
    // Check if scanner is responding properly first
    try {
      final testResponse = await sendOBD2Command('0100'); // Test command
      debugPrint('🔧 Test command response: $testResponse');
      if (testResponse.contains('UNABLE TO') || 
          testResponse.contains('STOPPED') ||
          testResponse.contains('SEARCHING') ||
          testResponse.contains('ERROR')) {
        debugPrint('❌ Scanner not ready for data requests.');
        debugPrint('🔧 TROUBLESHOOTING GUIDE:');
        debugPrint('   1. Ensure vehicle ignition is ON or engine is running');
        debugPrint('   2. Check OBD2 port connection is secure');
        debugPrint('   3. Try disconnecting and reconnecting the scanner');
        debugPrint('   4. Some vehicles require engine to be running for data');
        debugPrint('   5. Wait 30 seconds after connecting before requesting data');
        
        // Store error state for UI feedback
        _liveData['scanner_error'] = 'Scanner cannot communicate with vehicle ECU. Check connection and ignition.';
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('❌ Test command failed: $e');
      _liveData['scanner_error'] = 'Scanner connection test failed. Please reconnect.';
      notifyListeners();
      return;
    }
    
    if (dataType == 'vin') {
      // Special handling for VIN request
      await requestVIN();
      return;
    }
    
    final command = obdCommands[dataType];
    if (command != null) {
      try {
        final response = await sendOBD2Command(command);
        debugPrint('$dataType command response: $response');
        
        // If no response or error, log the error but don't set fake data
        if (response.contains('ERROR') || 
            response.contains('NO DATA') || 
            response.contains('TIMEOUT') ||
            response.contains('UNABLE TO') ||
            response.contains('STOPPED') ||
            response.contains('SEARCHING') ||
            response.contains('?')) {
          debugPrint('❌ Failed to get $dataType data: $response');
        } else {
          debugPrint('✅ $dataType request sent successfully');
        }
      } catch (e) {
        debugPrint('Data request error for $dataType: $e');
      }
    } else {
      debugPrint('❌ No command found for $dataType');
    }
    
    debugPrint('📊 Current live data after request: $_liveData');
  }
  
  /// Request VIN number (requires special multi-frame handling)
  Future<void> requestVIN() async {
    if (!_isConnected) {
      debugPrint('❌ Cannot request VIN: Not connected to OBD2 scanner');
      return;
    }
    
    try {
      debugPrint('🔍 Requesting VIN from OBD2 scanner...');
      final response = await sendOBD2Command('0902');
      debugPrint('VIN command response: $response');
      
      // Parse the VIN response directly if it contains multi-frame data
      if (response.contains('ERROR') || 
          response.contains('NO DATA') || 
          response.contains('TIMEOUT') ||
          response.contains('UNABLE TO') ||
          response.contains('STOPPED') ||
          response.contains('SEARCHING') ||
          response.contains('?')) {
        debugPrint('❌ VIN request failed: $response');
      } else {
        debugPrint('✅ VIN request sent successfully');
        // Parse VIN directly from the complete response
        if (response.contains('49 02') || response.contains('4902')) {
          debugPrint('🔍 Found VIN data in response, parsing directly...');
          _parseVINResponse(response);
        }
      }
    } catch (e) {
      debugPrint('VIN request error: $e');
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
      
      // 🔥 BACKEND INTEGRATION - Update backend connection status
      await _updateBackendConnectionStatus(false);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Disconnect error: $e');
    }
  }
  
  /// Update backend with connection status
  Future<void> _updateBackendConnectionStatus(bool connected) async {
    try {
      final endpoint = connected ? 'connect' : 'disconnect';
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/scanner/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'connected': connected,
          'device_name': _selectedDevice?.platformName ?? 'Unknown',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200) {
        debugPrint('✅ Connection status updated in backend: $connected');
      } else {
        debugPrint('❌ Backend connection update failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Backend connection update error: $e');
    }
  }

  /// Get available vehicles from backend
  Future<List<Map<String, dynamic>>> getAvailableVehicles() async {
    try {
      debugPrint('🔄 Fetching available vehicles from backend...');
      
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/scanner/vehicles'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final vehicles = List<Map<String, dynamic>>.from(data['vehicles'] ?? []);
        debugPrint('✅ Found ${vehicles.length} vehicles');
        return vehicles;
      } else {
        debugPrint('❌ Failed to get vehicles: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Vehicle fetch error: $e');
      return [];
    }
  }

  /// Upload full diagnostic scan results to backend
  Future<bool> uploadFullScanResults({
    required int vehicleId,
    required String scanType,
    required String vehicleInfo,
    required List<Map<String, dynamic>> troubleCodes,
    required Map<String, dynamic> liveParameters,
    required Map<String, dynamic> readinessMonitors,
    List<Map<String, dynamic>>? pendingCodes,
    List<Map<String, dynamic>>? permanentCodes,
    Map<String, dynamic>? freezeFrameData,
  }) async {
    try {
      debugPrint('🔄 Uploading full scan results to backend...');
      
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/scanner/upload-scan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'vehicle_id': vehicleId,
          'scan_type': scanType,
          'vehicle_info': vehicleInfo,
          'trouble_codes': troubleCodes,
          'pending_codes': pendingCodes ?? [],
          'permanent_codes': permanentCodes ?? [],
          'live_parameters': liveParameters,
          'readiness_monitors': readinessMonitors,
          'freeze_frame_data': freezeFrameData ?? {},
          'started_at': DateTime.now().toIso8601String(),
          'completed_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Full scan uploaded successfully: scan_id ${data['scan_id']}');
        
        // Check if backend substituted a different vehicle ID
        if (data['vehicle_id_used'] != null && data['vehicle_id_used'] != vehicleId) {
          debugPrint('ℹ️ Backend used vehicle ID ${data['vehicle_id_used']} instead of $vehicleId');
        }
        
        return true;
      } else {
        debugPrint('❌ Backend scan upload failed: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Full scan upload error: $e');
      return false;
    }
  }
  
  /// Update connection status
  void _updateStatus(String status) {
    _connectionStatus = status;
    debugPrint('OBD2 Status: $status');
    notifyListeners();
  }
}