import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../models/diagnostic_models.dart';

class OBD2ScannerService {
  BluetoothConnection? _connection;
  StreamController<String>? _dataStream;
  bool _isConnected = false;
  String _currentProtocol = 'Auto';
  
  // ELM327 Commands
  static const Map<String, String> _elmCommands = {
    'reset': 'ATZ',
    'echoOff': 'ATE0',
    'linefeedsOff': 'ATL0',
    'headersOn': 'ATH1',
    'spacesOn': 'ATS1',
    'autoProtocol': 'ATSP0',
    'getProtocol': 'ATDP',
    'getVersion': 'ATI',
    'getVoltage': 'ATRV',
    'getSupportedPids01': '0100',
    'getSupportedPids09': '0900',
    'getTroubleCodes': '03',
    'clearTroubleCodes': '05',
    'getPendingTroubleCodes': '07',
    'getPermanentTroubleCodes': '0A',
    'getEmissionsStatus': '01',
    'getEmissionsReadiness': '0101',
  };

  // OBD2 PIDs for live data
  static const Map<String, Map<String, dynamic>> _pids = {
    // Mode 01 - Current Data
    '0100': {
      'name': 'Supported PIDs [01-20]',
      'unit': '',
      'formula': 'raw',
      'description': 'Supported PIDs from 01 to 20'
    },
    '0101': {
      'name': 'Monitor Status Since DTCs Cleared',
      'unit': '',
      'formula': 'raw',
      'description': 'Monitor status since DTCs were cleared'
    },
    '0104': {
      'name': 'Calculated Load Value',
      'unit': '%',
      'formula': '(A * 100) / 255',
      'description': 'Calculated engine load as a percentage'
    },
    '0105': {
      'name': 'Engine Coolant Temperature',
      'unit': '°C',
      'formula': 'A - 40',
      'description': 'Engine coolant temperature in Celsius'
    },
    '0106': {
      'name': 'Short Term Fuel Trim Bank 1',
      'unit': '%',
      'formula': '((A - 128) * 100) / 128',
      'description': 'Short term fuel trim for bank 1'
    },
    '0107': {
      'name': 'Long Term Fuel Trim Bank 1',
      'unit': '%',
      'formula': '((A - 128) * 100) / 128',
      'description': 'Long term fuel trim for bank 1'
    },
    '0108': {
      'name': 'Short Term Fuel Trim Bank 2',
      'unit': '%',
      'formula': '((A - 128) * 100) / 128',
      'description': 'Short term fuel trim for bank 2'
    },
    '0109': {
      'name': 'Long Term Fuel Trim Bank 2',
      'unit': '%',
      'formula': '((A - 128) * 100) / 128',
      'description': 'Long term fuel trim for bank 2'
    },
    '010A': {
      'name': 'Fuel Pressure',
      'unit': 'kPa',
      'formula': 'A * 3',
      'description': 'Fuel pressure in kPa'
    },
    '010B': {
      'name': 'Intake Manifold Pressure',
      'unit': 'kPa',
      'formula': 'A',
      'description': 'Intake manifold absolute pressure'
    },
    '010C': {
      'name': 'Engine RPM',
      'unit': 'rpm',
      'formula': '((A * 256) + B) / 4',
      'description': 'Engine revolutions per minute'
    },
    '010D': {
      'name': 'Vehicle Speed',
      'unit': 'km/h',
      'formula': 'A',
      'description': 'Vehicle speed in kilometers per hour'
    },
    '010E': {
      'name': 'Timing Advance',
      'unit': 'degrees',
      'formula': '(A - 128) / 2',
      'description': 'Ignition timing advance relative to cylinder 1'
    },
    '010F': {
      'name': 'Intake Air Temperature',
      'unit': '°C',
      'formula': 'A - 40',
      'description': 'Intake air temperature in Celsius'
    },
    '0110': {
      'name': 'MAF Air Flow Rate',
      'unit': 'g/s',
      'formula': '((A * 256) + B) / 100',
      'description': 'Mass air flow sensor air flow rate'
    },
    '0111': {
      'name': 'Throttle Position',
      'unit': '%',
      'formula': '(A * 100) / 255',
      'description': 'Throttle position as a percentage'
    },
    '0112': {
      'name': 'Commanded Secondary Air Status',
      'unit': '',
      'formula': 'A',
      'description': 'Commanded secondary air status'
    },
    '0113': {
      'name': 'Oxygen Sensors Present',
      'unit': '',
      'formula': 'A',
      'description': 'Oxygen sensors present (banks 1 and 2)'
    },
    '0114': {
      'name': 'Oxygen Sensor 1 Bank 1',
      'unit': 'V',
      'formula': 'A / 200',
      'description': 'Oxygen sensor 1 bank 1 voltage'
    },
    '0115': {
      'name': 'Oxygen Sensor 2 Bank 1',
      'unit': 'V',
      'formula': 'A / 200',
      'description': 'Oxygen sensor 2 bank 1 voltage'
    },
    '0116': {
      'name': 'Oxygen Sensor 3 Bank 1',
      'unit': 'V',
      'formula': 'A / 200',
      'description': 'Oxygen sensor 3 bank 1 voltage'
    },
    '0117': {
      'name': 'Oxygen Sensor 4 Bank 1',
      'unit': 'V',
      'formula': 'A / 200',
      'description': 'Oxygen sensor 4 bank 1 voltage'
    },
    '0118': {
      'name': 'Oxygen Sensor 5 Bank 2',
      'unit': 'V',
      'formula': 'A / 200',
      'description': 'Oxygen sensor 5 bank 2 voltage'
    },
    '0119': {
      'name': 'Oxygen Sensor 6 Bank 2',
      'unit': 'V',
      'formula': 'A / 200',
      'description': 'Oxygen sensor 6 bank 2 voltage'
    },
    '011A': {
      'name': 'Oxygen Sensor 7 Bank 2',
      'unit': 'V',
      'formula': 'A / 200',
      'description': 'Oxygen sensor 7 bank 2 voltage'
    },
    '011B': {
      'name': 'Oxygen Sensor 8 Bank 2',
      'unit': 'V',
      'formula': 'A / 200',
      'description': 'Oxygen sensor 8 bank 2 voltage'
    },
    '011C': {
      'name': 'OBD Standards This Vehicle Conforms To',
      'unit': '',
      'formula': 'A',
      'description': 'OBD standards this vehicle conforms to'
    },
    '011D': {
      'name': 'Oxygen Sensors Present (Banks 1 and 2)',
      'unit': '',
      'formula': 'A',
      'description': 'Oxygen sensors present (banks 1 and 2)'
    },
    '011E': {
      'name': 'Auxiliary Input Status',
      'unit': '',
      'formula': 'A',
      'description': 'Auxiliary input status'
    },
    '011F': {
      'name': 'Run Time Since Engine Start',
      'unit': 'seconds',
      'formula': '(A * 256) + B',
      'description': 'Run time since engine start'
    },
    '0120': {
      'name': 'Supported PIDs [21-40]',
      'unit': '',
      'formula': 'raw',
      'description': 'Supported PIDs from 21 to 40'
    },
    '0121': {
      'name': 'Distance Traveled with MIL on',
      'unit': 'km',
      'formula': '(A * 256) + B',
      'description': 'Distance traveled with malfunction indicator lamp on'
    },
    '0122': {
      'name': 'Fuel Rail Pressure',
      'unit': 'kPa',
      'formula': '((A * 256) + B) * 10',
      'description': 'Fuel rail pressure (relative to manifold vacuum)'
    },
    '0123': {
      'name': 'Fuel Rail Gauge Pressure',
      'unit': 'kPa',
      'formula': '((A * 256) + B) * 10',
      'description': 'Fuel rail gauge pressure (diesel, or gasoline direct injection)'
    },
    '0124': {
      'name': 'Oxygen Sensor 1 Bank 1 Wide Range/Air-Fuel Ratio',
      'unit': '',
      'formula': '((A * 256) + B) * 2 / 65535',
      'description': 'Oxygen sensor 1 bank 1 wide range/air-fuel ratio'
    },
    '0125': {
      'name': 'Oxygen Sensor 2 Bank 1 Wide Range/Air-Fuel Ratio',
      'unit': '',
      'formula': '((A * 256) + B) * 2 / 65535',
      'description': 'Oxygen sensor 2 bank 1 wide range/air-fuel ratio'
    },
    '0126': {
      'name': 'Oxygen Sensor 3 Bank 1 Wide Range/Air-Fuel Ratio',
      'unit': '',
      'formula': '((A * 256) + B) * 2 / 65535',
      'description': 'Oxygen sensor 3 bank 1 wide range/air-fuel ratio'
    },
    '0127': {
      'name': 'Oxygen Sensor 4 Bank 1 Wide Range/Air-Fuel Ratio',
      'unit': '',
      'formula': '((A * 256) + B) * 2 / 65535',
      'description': 'Oxygen sensor 4 bank 1 wide range/air-fuel ratio'
    },
    '0128': {
      'name': 'Oxygen Sensor 5 Bank 2 Wide Range/Air-Fuel Ratio',
      'unit': '',
      'formula': '((A * 256) + B) * 2 / 65535',
      'description': 'Oxygen sensor 5 bank 2 wide range/air-fuel ratio'
    },
    '0129': {
      'name': 'Oxygen Sensor 6 Bank 2 Wide Range/Air-Fuel Ratio',
      'unit': '',
      'formula': '((A * 256) + B) * 2 / 65535',
      'description': 'Oxygen sensor 6 bank 2 wide range/air-fuel ratio'
    },
    '012A': {
      'name': 'Oxygen Sensor 7 Bank 2 Wide Range/Air-Fuel Ratio',
      'unit': '',
      'formula': '((A * 256) + B) * 2 / 65535',
      'description': 'Oxygen sensor 7 bank 2 wide range/air-fuel ratio'
    },
    '012B': {
      'name': 'Oxygen Sensor 8 Bank 2 Wide Range/Air-Fuel Ratio',
      'unit': '',
      'formula': '((A * 256) + B) * 2 / 65535',
      'description': 'Oxygen sensor 8 bank 2 wide range/air-fuel ratio'
    },
    '012C': {
      'name': 'Commanded EGR',
      'unit': '%',
      'formula': '(A * 100) / 255',
      'description': 'Commanded EGR'
    },
    '012D': {
      'name': 'EGR Error',
      'unit': '%',
      'formula': '((A - 128) * 100) / 128',
      'description': 'EGR error'
    },
    '012E': {
      'name': 'Commanded Evaporative Purge',
      'unit': '%',
      'formula': '(A * 100) / 255',
      'description': 'Commanded evaporative purge'
    },
    '012F': {
      'name': 'Fuel Level Input',
      'unit': '%',
      'formula': '(A * 100) / 255',
      'description': 'Fuel level input'
    },
    '0130': {
      'name': 'Warm-ups Since Codes Cleared',
      'unit': '',
      'formula': 'A',
      'description': 'Number of warm-ups since codes cleared'
    },
    '0131': {
      'name': 'Distance Since Codes Cleared',
      'unit': 'km',
      'formula': '(A * 256) + B',
      'description': 'Distance since codes cleared'
    },
    '0132': {
      'name': 'Evap System Vapor Pressure',
      'unit': 'Pa',
      'formula': '((A * 256) + B) / 4',
      'description': 'Evap system vapor pressure'
    },
    '0133': {
      'name': 'Barometric Pressure',
      'unit': 'kPa',
      'formula': 'A',
      'description': 'Barometric pressure'
    },
    '0134': {
      'name': 'Oxygen Sensor 1 Bank 1 Wide Range/Air-Fuel Ratio',
      'unit': '',
      'formula': '((A * 256) + B) * 2 / 65535',
      'description': 'Oxygen sensor 1 bank 1 wide range/air-fuel ratio'
    },
    '0135': {
      'name': 'Oxygen Sensor 2 Bank 1 Wide Range/Air-Fuel Ratio',
      'unit': '',
      'formula': '((A * 256) + B) * 2 / 65535',
      'description': 'Oxygen sensor 2 bank 1 wide range/air-fuel ratio'
    },
    '0136': {
      'name': 'Oxygen Sensor 3 Bank 1 Wide Range/Air-Fuel Ratio',
      'unit': '',
      'formula': '((A * 256) + B) * 2 / 65535',
      'description': 'Oxygen sensor 3 bank 1 wide range/air-fuel ratio'
    },
    '0137': {
      'name': 'Oxygen Sensor 4 Bank 1 Wide Range/Air-Fuel Ratio',
      'unit': '',
      'formula': '((A * 256) + B) * 2 / 65535',
      'description': 'Oxygen sensor 4 bank 1 wide range/air-fuel ratio'
    },
    '0138': {
      'name': 'Oxygen Sensor 5 Bank 2 Wide Range/Air-Fuel Ratio',
      'unit': '',
      'formula': '((A * 256) + B) * 2 / 65535',
      'description': 'Oxygen sensor 5 bank 2 wide range/air-fuel ratio'
    },
    '0139': {
      'name': 'Oxygen Sensor 6 Bank 2 Wide Range/Air-Fuel Ratio',
      'unit': '',
      'formula': '((A * 256) + B) * 2 / 65535',
      'description': 'Oxygen sensor 6 bank 2 wide range/air-fuel ratio'
    },
    '013A': {
      'name': 'Oxygen Sensor 7 Bank 2 Wide Range/Air-Fuel Ratio',
      'unit': '',
      'formula': '((A * 256) + B) * 2 / 65535',
      'description': 'Oxygen sensor 7 bank 2 wide range/air-fuel ratio'
    },
    '013B': {
      'name': 'Oxygen Sensor 8 Bank 2 Wide Range/Air-Fuel Ratio',
      'unit': '',
      'formula': '((A * 256) + B) * 2 / 65535',
      'description': 'Oxygen sensor 8 bank 2 wide range/air-fuel ratio'
    },
    '013C': {
      'name': 'Catalyst Temperature Bank 1 Sensor 1',
      'unit': '°C',
      'formula': '((A * 256) + B) / 10 - 40',
      'description': 'Catalyst temperature bank 1 sensor 1'
    },
    '013D': {
      'name': 'Catalyst Temperature Bank 2 Sensor 1',
      'unit': '°C',
      'formula': '((A * 256) + B) / 10 - 40',
      'description': 'Catalyst temperature bank 2 sensor 1'
    },
    '013E': {
      'name': 'Catalyst Temperature Bank 1 Sensor 2',
      'unit': '°C',
      'formula': '((A * 256) + B) / 10 - 40',
      'description': 'Catalyst temperature bank 1 sensor 2'
    },
    '013F': {
      'name': 'Catalyst Temperature Bank 2 Sensor 2',
      'unit': '°C',
      'formula': '((A * 256) + B) / 10 - 40',
      'description': 'Catalyst temperature bank 2 sensor 2'
    },
    '0140': {
      'name': 'Supported PIDs [41-60]',
      'unit': '',
      'formula': 'raw',
      'description': 'Supported PIDs from 41 to 60'
    },
    '0141': {
      'name': 'Monitor Status This Drive Cycle',
      'unit': '',
      'formula': 'raw',
      'description': 'Monitor status this drive cycle'
    },
    '0142': {
      'name': 'Control Module Voltage',
      'unit': 'V',
      'formula': '((A * 256) + B) / 1000',
      'description': 'Control module voltage'
    },
    '0143': {
      'name': 'Absolute Load Value',
      'unit': '%',
      'formula': '((A * 256) + B) * 100 / 255',
      'description': 'Absolute load value'
    },
    '0144': {
      'name': 'Fuel/Air Commanded Equivalence Ratio',
      'unit': '',
      'formula': '((A * 256) + B) / 32768',
      'description': 'Fuel/air commanded equivalence ratio'
    },
    '0145': {
      'name': 'Relative Throttle Position',
      'unit': '%',
      'formula': '(A * 100) / 255',
      'description': 'Relative throttle position'
    },
    '0146': {
      'name': 'Ambient Air Temperature',
      'unit': '°C',
      'formula': 'A - 40',
      'description': 'Ambient air temperature'
    },
    '0147': {
      'name': 'Absolute Throttle Position B',
      'unit': '%',
      'formula': '(A * 100) / 255',
      'description': 'Absolute throttle position B'
    },
    '0148': {
      'name': 'Absolute Throttle Position C',
      'unit': '%',
      'formula': '(A * 100) / 255',
      'description': 'Absolute throttle position C'
    },
    '0149': {
      'name': 'Accelerator Pedal Position D',
      'unit': '%',
      'formula': '(A * 100) / 255',
      'description': 'Accelerator pedal position D'
    },
    '014A': {
      'name': 'Accelerator Pedal Position E',
      'unit': '%',
      'formula': '(A * 100) / 255',
      'description': 'Accelerator pedal position E'
    },
    '014B': {
      'name': 'Accelerator Pedal Position F',
      'unit': '%',
      'formula': '(A * 100) / 255',
      'description': 'Accelerator pedal position F'
    },
    '014C': {
      'name': 'Commanded Throttle Actuator',
      'unit': '%',
      'formula': '(A * 100) / 255',
      'description': 'Commanded throttle actuator'
    },
    '014D': {
      'name': 'Time Run with MIL on',
      'unit': 'minutes',
      'formula': '(A * 256) + B',
      'description': 'Time run with MIL on'
    },
    '014E': {
      'name': 'Time since trouble codes cleared',
      'unit': 'minutes',
      'formula': '(A * 256) + B',
      'description': 'Time since trouble codes cleared'
    },
    '014F': {
      'name': 'Maximum values',
      'unit': '',
      'formula': 'raw',
      'description': 'Maximum values'
    },
    '0150': {
      'name': 'Maximum MAF air flow rate',
      'unit': 'g/s',
      'formula': '((A * 256) + B) / 10',
      'description': 'Maximum MAF air flow rate'
    },
    '0151': {
      'name': 'Fuel Type',
      'unit': '',
      'formula': 'A',
      'description': 'Fuel type'
    },
    '0152': {
      'name': 'Ethanol Fuel Percentage',
      'unit': '%',
      'formula': '(A * 100) / 255',
      'description': 'Ethanol fuel percentage'
    },
    '0153': {
      'name': 'Absolute Evap system Vapor Pressure',
      'unit': 'kPa',
      'formula': '((A * 256) + B) / 4',
      'description': 'Absolute evap system vapor pressure'
    },
    '0154': {
      'name': 'Evap system vapor pressure',
      'unit': 'Pa',
      'formula': '((A * 256) + B) - 32767',
      'description': 'Evap system vapor pressure'
    },
    '0155': {
      'name': 'Short term secondary oxygen sensor trim Bank 1',
      'unit': '%',
      'formula': '((A - 128) * 100) / 128',
      'description': 'Short term secondary oxygen sensor trim Bank 1'
    },
    '0156': {
      'name': 'Long term secondary oxygen sensor trim Bank 1',
      'unit': '%',
      'formula': '((A - 128) * 100) / 128',
      'description': 'Long term secondary oxygen sensor trim Bank 1'
    },
    '0157': {
      'name': 'Short term secondary oxygen sensor trim Bank 2',
      'unit': '%',
      'formula': '((A - 128) * 100) / 128',
      'description': 'Short term secondary oxygen sensor trim Bank 2'
    },
    '0158': {
      'name': 'Long term secondary oxygen sensor trim Bank 2',
      'unit': '%',
      'formula': '((A - 128) * 100) / 128',
      'description': 'Long term secondary oxygen sensor trim Bank 2'
    },
    '0159': {
      'name': 'Fuel rail absolute pressure',
      'unit': 'kPa',
      'formula': '((A * 256) + B) * 10',
      'description': 'Fuel rail absolute pressure'
    },
    '015A': {
      'name': 'Relative accelerator pedal position',
      'unit': '%',
      'formula': '(A * 100) / 255',
      'description': 'Relative accelerator pedal position'
    },
    '015B': {
      'name': 'Hybrid battery pack remaining life',
      'unit': '%',
      'formula': '(A * 100) / 255',
      'description': 'Hybrid battery pack remaining life'
    },
    '015C': {
      'name': 'Engine oil temperature',
      'unit': '°C',
      'formula': 'A - 40',
      'description': 'Engine oil temperature'
    },
    '015D': {
      'name': 'Fuel injection timing',
      'unit': 'degrees',
      'formula': '(((A * 256) + B) - 26880) / 128',
      'description': 'Fuel injection timing'
    },
    '015E': {
      'name': 'Engine fuel rate',
      'unit': 'L/h',
      'formula': '((A * 256) + B) / 20',
      'description': 'Engine fuel rate'
    },
    '015F': {
      'name': 'Emission requirements to which vehicle is designed',
      'unit': '',
      'formula': 'A',
      'description': 'Emission requirements to which vehicle is designed'
    },
  };

  // Emissions monitors
  static const Map<String, String> _emissionsMonitors = {
    'MIS': 'Misfire Monitor',
    'FUEL': 'Fuel System Monitor',
    'CCM': 'Comprehensive Component Monitor',
    'CAT': 'Catalyst Monitor',
    'HEATED_CAT': 'Heated Catalyst Monitor',
    'EVAP': 'Evaporative System Monitor',
    'AIR': 'Secondary Air System Monitor',
    'O2S': 'Oxygen Sensor Monitor',
    'O2S_HEATER': 'Oxygen Sensor Heater Monitor',
    'AC_REF': 'Air Conditioning Refrigerant Monitor',
  };

  bool get isConnected => _isConnected;
  Stream<String>? get dataStream => _dataStream?.stream;

  // Initialize connection to ELM327 device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _dataStream = StreamController<String>.broadcast();
      _isConnected = true;

      // Listen for incoming data
      _connection!.input!.listen((Uint8List data) {
        final response = String.fromCharCodes(data);
        _dataStream?.add(response);
      });

      // Initialize ELM327
      await _initializeELM327();
      
      return true;
    } catch (e) {
      print('Failed to connect to OBD2 device: $e');
      _isConnected = false;
      return false;
    }
  }

  // Initialize ELM327 with proper settings
  Future<void> _initializeELM327() async {
    final commands = [
      _elmCommands['reset']!,
      _elmCommands['echoOff']!,
      _elmCommands['linefeedsOff']!,
      _elmCommands['headersOn']!,
      _elmCommands['spacesOn']!,
      _elmCommands['autoProtocol']!,
    ];

    for (final command in commands) {
      await sendCommand(command);
      await Future.delayed(Duration(milliseconds: 100));
    }

    // Get protocol information
    final protocolResponse = await sendCommand(_elmCommands['getProtocol']!);
    if (protocolResponse.isNotEmpty) {
      _currentProtocol = protocolResponse.replaceAll('AUTO, ', '').trim();
    }
  }

  // Send command to ELM327
  Future<String> sendCommand(String command) async {
    if (!_isConnected || _connection == null) {
      throw Exception('Not connected to OBD2 device');
    }

    try {
      final data = Uint8List.fromList(utf8.encode('$command\r'));
      _connection!.output.add(data);
      await _connection!.output.allSent;

      // Wait for response
      final response = await _waitForResponse();
      return _parseResponse(response);
    } catch (e) {
      print('Error sending command $command: $e');
      return '';
    }
  }

  // Wait for response from ELM327
  Future<String> _waitForResponse() async {
    final completer = Completer<String>();
    String response = '';
    
    StreamSubscription<String>? subscription;
    subscription = _dataStream!.stream.listen((data) {
      response += data;
      if (response.contains('>') || response.contains('OK') || response.contains('ERROR')) {
        subscription?.cancel();
        completer.complete(response);
      }
    });

    // Timeout after 5 seconds
    Timer(Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        subscription?.cancel();
        completer.complete(response);
      }
    });

    return completer.future;
  }

  // Parse ELM327 response
  String _parseResponse(String response) {
    // Remove echo, headers, and prompt
    response = response.replaceAll(RegExp(r'[>OK\r\n]'), '');
    response = response.replaceAll(RegExp(r'[0-9A-F]{2}\s'), ''); // Remove headers
    response = response.trim();
    return response;
  }

  // Get supported PIDs
  Future<List<String>> getSupportedPids() async {
    final response = await sendCommand(_elmCommands['getSupportedPids01']!);
    if (response.isEmpty) return [];

    // Parse supported PIDs from response
    final supportedPids = <String>[];
    final data = response.split(' ');
    if (data.length >= 4) {
      final supportedBits = int.parse(data[3], radix: 16);
      for (int i = 0; i < 32; i++) {
        if ((supportedBits & (1 << (31 - i))) != 0) {
          final pid = (0x01 << 8) | (i + 1);
          supportedPids.add(pid.toRadixString(16).toUpperCase().padLeft(4, '0'));
        }
      }
    }
    return supportedPids;
  }

  // Get diagnostic trouble codes
  Future<List<DiagnosticTroubleCode>> getTroubleCodes() async {
    final codes = <DiagnosticTroubleCode>[];
    
    // Get confirmed DTCs
    final confirmedResponse = await sendCommand(_elmCommands['getTroubleCodes']!);
    codes.addAll(_parseTroubleCodes(confirmedResponse, false));
    
    // Get pending DTCs
    final pendingResponse = await sendCommand(_elmCommands['getPendingTroubleCodes']!);
    codes.addAll(_parseTroubleCodes(pendingResponse, true));

    return codes;
  }

  // Parse trouble codes from response
  List<DiagnosticTroubleCode> _parseTroubleCodes(String response, bool isPending) {
    final codes = <DiagnosticTroubleCode>[];
    if (response.isEmpty || response.contains('NO DATA')) return codes;

    final data = response.split(' ');
    for (int i = 0; i < data.length; i += 4) {
      if (i + 3 < data.length) {
        final code = data[i + 1] + data[i + 2];
        final severity = _getCodeSeverity(data[i]);
        final category = _getCodeCategory(data[i]);
        
        codes.add(DiagnosticTroubleCode(
          code: code,
          description: _getCodeDescription(code),
          severity: severity,
          category: category,
          isPending: isPending,
          isConfirmed: !isPending,
        ));
      }
    }
    return codes;
  }

  // Get code severity
  String _getCodeSeverity(String firstByte) {
    final value = int.parse(firstByte, radix: 16);
    if ((value & 0xC0) == 0x00) return 'P'; // Powertrain
    if ((value & 0xC0) == 0x40) return 'C'; // Chassis
    if ((value & 0xC0) == 0x80) return 'B'; // Body
    return 'U'; // Network
  }

  // Get code category
  String _getCodeCategory(String firstByte) {
    final value = int.parse(firstByte, radix: 16);
    if ((value & 0xC0) == 0x00) return 'Powertrain';
    if ((value & 0xC0) == 0x40) return 'Chassis';
    if ((value & 0xC0) == 0x80) return 'Body';
    return 'Network';
  }

  // Get code description (comprehensive DTC database)
  String _getCodeDescription(String code) {
    // Comprehensive OBD2 DTC database
    final descriptions = {
      // P0xxx - Powertrain Codes
      'P0000': 'No fault',
      'P0001': 'Fuel Volume Regulator Control Circuit/Open',
      'P0002': 'Fuel Volume Regulator Control Circuit Range/Performance',
      'P0003': 'Fuel Volume Regulator Control Circuit Low',
      'P0004': 'Fuel Volume Regulator Control Circuit High',
      'P0005': 'Fuel Shutoff Valve A Control Circuit/Open',
      'P0006': 'Fuel Shutoff Valve A Control Circuit Low',
      'P0007': 'Fuel Shutoff Valve A Control Circuit High',
      'P0008': 'Engine Position System Performance Bank 1',
      'P0009': 'Engine Position System Performance Bank 2',
      'P000A': 'A Camshaft Position Slow Response Bank 1',
      'P000B': 'B Camshaft Position Slow Response Bank 1',
      'P000C': 'A Camshaft Position Slow Response Bank 2',
      'P000D': 'B Camshaft Position Slow Response Bank 2',
      'P000E': 'Fuel Volume Regulator Control Circuit/Open',
      'P000F': 'Fuel Volume Regulator Control Circuit Low',
      'P0010': 'A Camshaft Position Actuator Circuit Bank 1',
      'P0011': 'A Camshaft Position - Timing Over-Advanced or System Performance Bank 1',
      'P0012': 'A Camshaft Position - Timing Over-Retarded Bank 1',
      'P0013': 'B Camshaft Position - Actuator Circuit Bank 1',
      'P0014': 'B Camshaft Position - Timing Over-Advanced or System Performance Bank 1',
      'P0015': 'B Camshaft Position - Timing Over-Retarded Bank 1',
      'P0016': 'Crankshaft Position - Camshaft Position Correlation Bank 1 Sensor A',
      'P0017': 'Crankshaft Position - Camshaft Position Correlation Bank 1 Sensor B',
      'P0018': 'Crankshaft Position - Camshaft Position Correlation Bank 2 Sensor A',
      'P0019': 'Crankshaft Position - Camshaft Position Correlation Bank 2 Sensor B',
      'P0020': 'A Camshaft Position Actuator Circuit Bank 2',
      'P0021': 'A Camshaft Position - Timing Over-Advanced or System Performance Bank 2',
      'P0022': 'A Camshaft Position - Timing Over-Retarded Bank 2',
      'P0023': 'B Camshaft Position - Actuator Circuit Bank 2',
      'P0024': 'B Camshaft Position - Timing Over-Advanced or System Performance Bank 2',
      'P0025': 'B Camshaft Position - Timing Over-Retarded Bank 2',
      'P0026': 'Intake Valve Control Solenoid Circuit Range/Performance Bank 1',
      'P0027': 'Exhaust Valve Control Solenoid Circuit Range/Performance Bank 1',
      'P0028': 'Intake Valve Control Solenoid Circuit Range/Performance Bank 2',
      'P0029': 'Exhaust Valve Control Solenoid Circuit Range/Performance Bank 2',
      'P0030': 'HO2S Heater Control Circuit Bank 1 Sensor 1',
      'P0031': 'HO2S Heater Control Circuit Low Bank 1 Sensor 1',
      'P0032': 'HO2S Heater Control Circuit High Bank 1 Sensor 1',
      'P0033': 'Turbo Charger Bypass Valve Control Circuit',
      'P0034': 'Turbo Charger Bypass Valve Control Circuit Low',
      'P0035': 'Turbo Charger Bypass Valve Control Circuit High',
      'P0036': 'HO2S Heater Control Circuit Bank 1 Sensor 2',
      'P0037': 'HO2S Heater Control Circuit Low Bank 1 Sensor 2',
      'P0038': 'HO2S Heater Control Circuit High Bank 1 Sensor 2',
      'P0039': 'Turbo/Super Charger Bypass Valve Control Circuit Range/Performance',
      'P0040': 'O2 Sensor Signals Swapped Bank 1 Sensor 1 / Bank 2 Sensor 1',
      'P0041': 'O2 Sensor Signals Swapped Bank 1 Sensor 2 / Bank 2 Sensor 2',
      'P0042': 'HO2S Heater Control Circuit Bank 1 Sensor 3',
      'P0043': 'HO2S Heater Control Circuit Low Bank 1 Sensor 3',
      'P0044': 'HO2S Heater Control Circuit High Bank 1 Sensor 3',
      'P0045': 'Turbo/Super Charger Boost Control Solenoid Circuit/Open',
      'P0046': 'Turbo/Super Charger Boost Control Solenoid Circuit Range/Performance',
      'P0047': 'Turbo/Super Charger Boost Control Solenoid Circuit Low',
      'P0048': 'Turbo/Super Charger Boost Control Solenoid Circuit High',
      'P0049': 'Turbo/Super Charger Turbine Overspeed',
      'P0050': 'HO2S Heater Control Circuit Bank 2 Sensor 1',
      'P0051': 'HO2S Heater Control Circuit Low Bank 2 Sensor 1',
      'P0052': 'HO2S Heater Control Circuit High Bank 2 Sensor 1',
      'P0053': 'HO2S Heater Resistance Bank 1 Sensor 1',
      'P0054': 'HO2S Heater Resistance Bank 1 Sensor 2',
      'P0055': 'HO2S Heater Resistance Bank 1 Sensor 3',
      'P0056': 'HO2S Heater Control Circuit Bank 2 Sensor 2',
      'P0057': 'HO2S Heater Control Circuit Low Bank 2 Sensor 2',
      'P0058': 'HO2S Heater Control Circuit High Bank 2 Sensor 2',
      'P0059': 'HO2S Heater Resistance Bank 2 Sensor 1',
      'P0060': 'HO2S Heater Resistance Bank 2 Sensor 2',
      'P0061': 'HO2S Heater Resistance Bank 2 Sensor 3',
      'P0062': 'HO2S Heater Control Circuit Bank 2 Sensor 3',
      'P0063': 'HO2S Heater Control Circuit Low Bank 2 Sensor 3',
      'P0064': 'HO2S Heater Control Circuit High Bank 2 Sensor 3',
      'P0065': 'Air Assisted Injector Control Range/Performance',
      'P0066': 'Air Assisted Injector Control Circuit or Circuit Low',
      'P0067': 'Air Assisted Injector Control Circuit High',
      'P0068': 'MAP/MAF - Throttle Position Correlation',
      'P0069': 'Manifold Absolute Pressure - Barometric Pressure Correlation',
      'P0070': 'Ambient Air Temperature Sensor Circuit',
      'P0071': 'Ambient Air Temperature Sensor Range/Performance',
      'P0072': 'Ambient Air Temperature Sensor Circuit Low',
      'P0073': 'Ambient Air Temperature Sensor Circuit High',
      'P0074': 'Ambient Air Temperature Sensor Circuit Intermittent',
      'P0075': 'Intake Valve Control Solenoid Circuit Bank 2',
      'P0076': 'Intake Valve Control Solenoid Circuit Low Bank 2',
      'P0077': 'Intake Valve Control Solenoid Circuit High Bank 2',
      'P0078': 'Exhaust Valve Control Solenoid Circuit Bank 2',
      'P0079': 'Exhaust Valve Control Solenoid Circuit Low Bank 2',
      'P0080': 'Exhaust Valve Control Solenoid Circuit High Bank 2',
      'P0081': 'Intake Valve Control Solenoid Circuit Bank 2',
      'P0082': 'Intake Valve Control Solenoid Circuit Low Bank 2',
      'P0083': 'Intake Valve Control Solenoid Circuit High Bank 2',
      'P0084': 'Exhaust Valve Control Solenoid Circuit Bank 2',
      'P0085': 'Exhaust Valve Control Solenoid Circuit Low Bank 2',
      'P0086': 'Exhaust Valve Control Solenoid Circuit High Bank 2',
      'P0087': 'Fuel Rail/System Pressure - Too Low',
      'P0088': 'Fuel Rail/System Pressure - Too High',
      'P0089': 'Fuel Pressure Regulator 1 Performance',
      'P0090': 'Fuel Pressure Regulator 1 Control Circuit',
      'P0091': 'Fuel Pressure Regulator 1 Control Circuit Low',
      'P0092': 'Fuel Pressure Regulator 1 Control Circuit High',
      'P0093': 'Fuel System Leak Detected - Large Leak',
      'P0094': 'Fuel System Leak Detected - Small Leak',
      'P0095': 'Intake Air Temperature Sensor 2 Circuit',
      'P0096': 'Intake Air Temperature Sensor 2 Circuit Range/Performance',
      'P0097': 'Intake Air Temperature Sensor 2 Circuit Low',
      'P0098': 'Intake Air Temperature Sensor 2 Circuit High',
      'P0099': 'Intake Air Temperature Sensor 2 Circuit Intermittent/Erratic',
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
      'P010A': 'Mass or Volume Air Flow Circuit Range/Performance Problem',
      'P010B': 'Mass or Volume Air Flow Circuit Low Input',
      'P010C': 'Mass or Volume Air Flow Circuit High Input',
      'P010D': 'Mass or Volume Air Flow Circuit Intermittent',
      'P010E': 'Mass or Volume Air Flow Circuit Intermittent',
      'P010F': 'Mass or Volume Air Flow Circuit Intermittent',
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
      'P011A': 'Engine Coolant Temperature / Intake Air Temperature Correlation',
      'P011B': 'Engine Coolant Temperature / Intake Air Temperature Correlation',
      'P011C': 'Engine Coolant Temperature / Intake Air Temperature Correlation',
      'P011D': 'Engine Coolant Temperature / Intake Air Temperature Correlation',
      'P011E': 'Engine Coolant Temperature / Intake Air Temperature Correlation',
      'P011F': 'Engine Coolant Temperature / Intake Air Temperature Correlation',
      'P0120': 'Throttle/Pedal Position Sensor/Switch A Circuit Malfunction',
      'P0121': 'Throttle/Pedal Position Sensor/Switch A Circuit Range/Performance Problem',
      'P0122': 'Throttle/Pedal Position Sensor/Switch A Circuit Low Input',
      'P0123': 'Throttle/Pedal Position Sensor/Switch A Circuit High Input',
      'P0124': 'Throttle/Pedal Position Sensor/Switch A Circuit Intermittent',
      'P0125': 'Insufficient Coolant Temperature for Closed Loop Fuel Control',
      'P0126': 'Insufficient Coolant Temperature for Stable Operation',
      'P0127': 'Intake Air Temperature Too High',
      'P0128': 'Coolant Thermostat Temperature Below Regulating Temperature',
      'P0129': 'Barometric Pressure Too Low',
      'P012A': 'Throttle/Pedal Position Sensor/Switch A Circuit Range/Performance Problem',
      'P012B': 'Throttle/Pedal Position Sensor/Switch A Circuit Low Input',
      'P012C': 'Throttle/Pedal Position Sensor/Switch A Circuit High Input',
      'P012D': 'Throttle/Pedal Position Sensor/Switch A Circuit Intermittent',
      'P012E': 'Throttle/Pedal Position Sensor/Switch A Circuit Intermittent',
      'P012F': 'Throttle/Pedal Position Sensor/Switch A Circuit Intermittent',
      'P0130': 'O2 Sensor Circuit Malfunction Bank 1 Sensor 1',
      'P0131': 'O2 Sensor Circuit Low Voltage Bank 1 Sensor 1',
      'P0132': 'O2 Sensor Circuit High Voltage Bank 1 Sensor 1',
      'P0133': 'O2 Sensor Circuit Slow Response Bank 1 Sensor 1',
      'P0134': 'O2 Sensor Circuit No Activity Detected Bank 1 Sensor 1',
      'P0135': 'O2 Sensor Heater Circuit Malfunction Bank 1 Sensor 1',
      'P0136': 'O2 Sensor Circuit Malfunction Bank 1 Sensor 2',
      'P0137': 'O2 Sensor Circuit Low Voltage Bank 1 Sensor 2',
      'P0138': 'O2 Sensor Circuit High Voltage Bank 1 Sensor 2',
      'P0139': 'O2 Sensor Circuit Slow Response Bank 1 Sensor 2',
      'P0140': 'O2 Sensor Circuit No Activity Detected Bank 1 Sensor 2',
      'P0141': 'O2 Sensor Heater Circuit Malfunction Bank 1 Sensor 2',
      'P0142': 'O2 Sensor Circuit Malfunction Bank 1 Sensor 3',
      'P0143': 'O2 Sensor Circuit Low Voltage Bank 1 Sensor 3',
      'P0144': 'O2 Sensor Circuit High Voltage Bank 1 Sensor 3',
      'P0145': 'O2 Sensor Circuit Slow Response Bank 1 Sensor 3',
      'P0146': 'O2 Sensor Circuit No Activity Detected Bank 1 Sensor 3',
      'P0147': 'O2 Sensor Heater Circuit Malfunction Bank 1 Sensor 3',
      'P0148': 'O2 Sensor Circuit Malfunction Bank 1 Sensor 4',
      'P0149': 'O2 Sensor Circuit Low Voltage Bank 1 Sensor 4',
      'P014A': 'O2 Sensor Circuit High Voltage Bank 1 Sensor 4',
      'P014B': 'O2 Sensor Circuit Slow Response Bank 1 Sensor 4',
      'P014C': 'O2 Sensor Circuit No Activity Detected Bank 1 Sensor 4',
      'P014D': 'O2 Sensor Heater Circuit Malfunction Bank 1 Sensor 4',
      'P014E': 'O2 Sensor Circuit Malfunction Bank 1 Sensor 4',
      'P014F': 'O2 Sensor Circuit Low Voltage Bank 1 Sensor 4',
      'P0150': 'O2 Sensor Circuit Malfunction Bank 2 Sensor 1',
      'P0151': 'O2 Sensor Circuit Low Voltage Bank 2 Sensor 1',
      'P0152': 'O2 Sensor Circuit High Voltage Bank 2 Sensor 1',
      'P0153': 'O2 Sensor Circuit Slow Response Bank 2 Sensor 1',
      'P0154': 'O2 Sensor Circuit No Activity Detected Bank 2 Sensor 1',
      'P0155': 'O2 Sensor Heater Circuit Malfunction Bank 2 Sensor 1',
      'P0156': 'O2 Sensor Circuit Malfunction Bank 2 Sensor 2',
      'P0157': 'O2 Sensor Circuit Low Voltage Bank 2 Sensor 2',
      'P0158': 'O2 Sensor Circuit High Voltage Bank 2 Sensor 2',
      'P0159': 'O2 Sensor Circuit Slow Response Bank 2 Sensor 2',
      'P015A': 'O2 Sensor Circuit No Activity Detected Bank 2 Sensor 2',
      'P015B': 'O2 Sensor Heater Circuit Malfunction Bank 2 Sensor 2',
      'P015C': 'O2 Sensor Circuit Malfunction Bank 2 Sensor 3',
      'P015D': 'O2 Sensor Circuit Low Voltage Bank 2 Sensor 3',
      'P015E': 'O2 Sensor Circuit High Voltage Bank 2 Sensor 3',
      'P015F': 'O2 Sensor Circuit Slow Response Bank 2 Sensor 3',
      'P0160': 'O2 Sensor Circuit No Activity Detected Bank 2 Sensor 3',
      'P0161': 'O2 Sensor Heater Circuit Malfunction Bank 2 Sensor 3',
      'P0162': 'O2 Sensor Circuit Malfunction Bank 2 Sensor 4',
      'P0163': 'O2 Sensor Circuit Low Voltage Bank 2 Sensor 4',
      'P0164': 'O2 Sensor Circuit High Voltage Bank 2 Sensor 4',
      'P0165': 'O2 Sensor Circuit Slow Response Bank 2 Sensor 4',
      'P0166': 'O2 Sensor Circuit No Activity Detected Bank 2 Sensor 4',
      'P0167': 'O2 Sensor Heater Circuit Malfunction Bank 2 Sensor 4',
      'P0168': 'O2 Sensor Circuit Malfunction Bank 2 Sensor 4',
      'P0169': 'O2 Sensor Circuit Low Voltage Bank 2 Sensor 4',
      'P016A': 'O2 Sensor Circuit High Voltage Bank 2 Sensor 4',
      'P016B': 'O2 Sensor Circuit Slow Response Bank 2 Sensor 4',
      'P016C': 'O2 Sensor Circuit No Activity Detected Bank 2 Sensor 4',
      'P016D': 'O2 Sensor Heater Circuit Malfunction Bank 2 Sensor 4',
      'P016E': 'O2 Sensor Circuit Malfunction Bank 2 Sensor 4',
      'P016F': 'O2 Sensor Circuit Low Voltage Bank 2 Sensor 4',
      'P0170': 'Fuel Trim Malfunction Bank 1',
      'P0171': 'System Too Lean Bank 1',
      'P0172': 'System Too Rich Bank 1',
      'P0173': 'Fuel Trim Malfunction Bank 2',
      'P0174': 'System Too Lean Bank 2',
      'P0175': 'System Too Rich Bank 2',
      'P0176': 'Fuel Composition Sensor Circuit Malfunction',
      'P0177': 'Fuel Composition Sensor Circuit Range/Performance',
      'P0178': 'Fuel Composition Sensor Circuit Low Input',
      'P0179': 'Fuel Composition Sensor Circuit High Input',
      'P017A': 'Fuel Composition Sensor Circuit Intermittent/Erratic',
      'P017B': 'Fuel Composition Sensor Circuit Intermittent/Erratic',
      'P017C': 'Fuel Composition Sensor Circuit Intermittent/Erratic',
      'P017D': 'Fuel Composition Sensor Circuit Intermittent/Erratic',
      'P017E': 'Fuel Composition Sensor Circuit Intermittent/Erratic',
      'P017F': 'Fuel Composition Sensor Circuit Intermittent/Erratic',
      'P0180': 'Fuel Temperature Sensor A Circuit Malfunction',
      'P0181': 'Fuel Temperature Sensor A Circuit Range/Performance',
      'P0182': 'Fuel Temperature Sensor A Circuit Low Input',
      'P0183': 'Fuel Temperature Sensor A Circuit High Input',
      'P0184': 'Fuel Temperature Sensor A Circuit Intermittent',
      'P0185': 'Fuel Temperature Sensor B Circuit Malfunction',
      'P0186': 'Fuel Temperature Sensor B Circuit Range/Performance',
      'P0187': 'Fuel Temperature Sensor B Circuit Low Input',
      'P0188': 'Fuel Temperature Sensor B Circuit High Input',
      'P0189': 'Fuel Temperature Sensor B Circuit Intermittent',
      'P018A': 'Fuel Temperature Sensor A Circuit Range/Performance',
      'P018B': 'Fuel Temperature Sensor A Circuit Low Input',
      'P018C': 'Fuel Temperature Sensor A Circuit High Input',
      'P018D': 'Fuel Temperature Sensor A Circuit Intermittent',
      'P018E': 'Fuel Temperature Sensor A Circuit Intermittent',
      'P018F': 'Fuel Temperature Sensor A Circuit Intermittent',
      'P0190': 'Fuel Rail Pressure Sensor Circuit Malfunction',
      'P0191': 'Fuel Rail Pressure Sensor Circuit Range/Performance',
      'P0192': 'Fuel Rail Pressure Sensor Circuit Low Input',
      'P0193': 'Fuel Rail Pressure Sensor Circuit High Input',
      'P0194': 'Fuel Rail Pressure Sensor Circuit Intermittent',
      'P0195': 'Engine Oil Temperature Sensor Malfunction',
      'P0196': 'Engine Oil Temperature Sensor Range/Performance',
      'P0197': 'Engine Oil Temperature Sensor Low',
      'P0198': 'Engine Oil Temperature Sensor High',
      'P0199': 'Engine Oil Temperature Sensor Intermittent',
      'P019A': 'Engine Oil Temperature Sensor Range/Performance',
      'P019B': 'Engine Oil Temperature Sensor Low',
      'P019C': 'Engine Oil Temperature Sensor High',
      'P019D': 'Engine Oil Temperature Sensor Intermittent',
      'P019E': 'Engine Oil Temperature Sensor Intermittent',
      'P019F': 'Engine Oil Temperature Sensor Intermittent',
      'P01A0': 'Engine Oil Temperature Sensor Range/Performance',
      'P01A1': 'Engine Oil Temperature Sensor Low',
      'P01A2': 'Engine Oil Temperature Sensor High',
      'P01A3': 'Engine Oil Temperature Sensor Intermittent',
      'P01A4': 'Engine Oil Temperature Sensor Intermittent',
      'P01A5': 'Engine Oil Temperature Sensor Intermittent',
      'P01A6': 'Engine Oil Temperature Sensor Range/Performance',
      'P01A7': 'Engine Oil Temperature Sensor Low',
      'P01A8': 'Engine Oil Temperature Sensor High',
      'P01A9': 'Engine Oil Temperature Sensor Intermittent',
      'P01AA': 'Engine Oil Temperature Sensor Intermittent',
      'P01AB': 'Engine Oil Temperature Sensor Intermittent',
      'P01AC': 'Engine Oil Temperature Sensor Range/Performance',
      'P01AD': 'Engine Oil Temperature Sensor Low',
      'P01AE': 'Engine Oil Temperature Sensor High',
      'P01AF': 'Engine Oil Temperature Sensor Intermittent',
      'P01B0': 'Engine Oil Temperature Sensor Intermittent',
      'P01B1': 'Engine Oil Temperature Sensor Intermittent',
      'P01B2': 'Engine Oil Temperature Sensor Range/Performance',
      'P01B3': 'Engine Oil Temperature Sensor Low',
      'P01B4': 'Engine Oil Temperature Sensor High',
      'P01B5': 'Engine Oil Temperature Sensor Intermittent',
      'P01B6': 'Engine Oil Temperature Sensor Intermittent',
      'P01B7': 'Engine Oil Temperature Sensor Intermittent',
      'P01B8': 'Engine Oil Temperature Sensor Range/Performance',
      'P01B9': 'Engine Oil Temperature Sensor Low',
      'P01BA': 'Engine Oil Temperature Sensor High',
      'P01BB': 'Engine Oil Temperature Sensor Intermittent',
      'P01BC': 'Engine Oil Temperature Sensor Intermittent',
      'P01BD': 'Engine Oil Temperature Sensor Intermittent',
      'P01BE': 'Engine Oil Temperature Sensor Range/Performance',
      'P01BF': 'Engine Oil Temperature Sensor Low',
      'P01C0': 'Engine Oil Temperature Sensor High',
      'P01C1': 'Engine Oil Temperature Sensor Intermittent',
      'P01C2': 'Engine Oil Temperature Sensor Intermittent',
      'P01C3': 'Engine Oil Temperature Sensor Intermittent',
      'P01C4': 'Engine Oil Temperature Sensor Range/Performance',
      'P01C5': 'Engine Oil Temperature Sensor Low',
      'P01C6': 'Engine Oil Temperature Sensor High',
      'P01C7': 'Engine Oil Temperature Sensor Intermittent',
      'P01C8': 'Engine Oil Temperature Sensor Intermittent',
      'P01C9': 'Engine Oil Temperature Sensor Intermittent',
      'P01CA': 'Engine Oil Temperature Sensor Range/Performance',
      'P01CB': 'Engine Oil Temperature Sensor Low',
      'P01CC': 'Engine Oil Temperature Sensor High',
      'P01CD': 'Engine Oil Temperature Sensor Intermittent',
      'P01CE': 'Engine Oil Temperature Sensor Intermittent',
      'P01CF': 'Engine Oil Temperature Sensor Intermittent',
      'P01D0': 'Engine Oil Temperature Sensor Range/Performance',
      'P01D1': 'Engine Oil Temperature Sensor Low',
      'P01D2': 'Engine Oil Temperature Sensor High',
      'P01D3': 'Engine Oil Temperature Sensor Intermittent',
      'P01D4': 'Engine Oil Temperature Sensor Intermittent',
      'P01D5': 'Engine Oil Temperature Sensor Intermittent',
      'P01D6': 'Engine Oil Temperature Sensor Range/Performance',
      'P01D7': 'Engine Oil Temperature Sensor Low',
      'P01D8': 'Engine Oil Temperature Sensor High',
      'P01D9': 'Engine Oil Temperature Sensor Intermittent',
      'P01DA': 'Engine Oil Temperature Sensor Intermittent',
      'P01DB': 'Engine Oil Temperature Sensor Intermittent',
      'P01DC': 'Engine Oil Temperature Sensor Range/Performance',
      'P01DD': 'Engine Oil Temperature Sensor Low',
      'P01DE': 'Engine Oil Temperature Sensor High',
      'P01DF': 'Engine Oil Temperature Sensor Intermittent',
      'P01E0': 'Engine Oil Temperature Sensor Intermittent',
      'P01E1': 'Engine Oil Temperature Sensor Intermittent',
      'P01E2': 'Engine Oil Temperature Sensor Range/Performance',
      'P01E3': 'Engine Oil Temperature Sensor Low',
      'P01E4': 'Engine Oil Temperature Sensor High',
      'P01E5': 'Engine Oil Temperature Sensor Intermittent',
      'P01E6': 'Engine Oil Temperature Sensor Intermittent',
      'P01E7': 'Engine Oil Temperature Sensor Intermittent',
      'P01E8': 'Engine Oil Temperature Sensor Range/Performance',
      'P01E9': 'Engine Oil Temperature Sensor Low',
      'P01EA': 'Engine Oil Temperature Sensor High',
      'P01EB': 'Engine Oil Temperature Sensor Intermittent',
      'P01EC': 'Engine Oil Temperature Sensor Intermittent',
      'P01ED': 'Engine Oil Temperature Sensor Intermittent',
      'P01EE': 'Engine Oil Temperature Sensor Range/Performance',
      'P01EF': 'Engine Oil Temperature Sensor Low',
      'P01F0': 'Engine Oil Temperature Sensor High',
      'P01F1': 'Engine Oil Temperature Sensor Intermittent',
      'P01F2': 'Engine Oil Temperature Sensor Intermittent',
      'P01F3': 'Engine Oil Temperature Sensor Intermittent',
      'P01F4': 'Engine Oil Temperature Sensor Range/Performance',
      'P01F5': 'Engine Oil Temperature Sensor Low',
      'P01F6': 'Engine Oil Temperature Sensor High',
      'P01F7': 'Engine Oil Temperature Sensor Intermittent',
      'P01F8': 'Engine Oil Temperature Sensor Intermittent',
      'P01F9': 'Engine Oil Temperature Sensor Intermittent',
      'P01FA': 'Engine Oil Temperature Sensor Range/Performance',
      'P01FB': 'Engine Oil Temperature Sensor Low',
      'P01FC': 'Engine Oil Temperature Sensor High',
      'P01FD': 'Engine Oil Temperature Sensor Intermittent',
      'P01FE': 'Engine Oil Temperature Sensor Intermittent',
      'P01FF': 'Engine Oil Temperature Sensor Intermittent',
      
      // Common P1xxx codes
      'P1000': 'OBD System Readiness Test Not Complete',
      'P1001': 'KOER Not Able To Complete KOEO Self Test',
      'P1002': 'KOER Aborted',
      'P1003': 'Unable To Erect KOEO',
      'P1004': 'Unable To Erect KOER',
      'P1005': 'Unable To Erect KOEO',
      'P1006': 'Unable To Erect KOER',
      'P1007': 'Unable To Erect KOEO',
      'P1008': 'Unable To Erect KOER',
      'P1009': 'Unable To Erect KOEO',
      'P100A': 'Unable To Erect KOER',
      'P100B': 'Unable To Erect KOEO',
      'P100C': 'Unable To Erect KOER',
      'P100D': 'Unable To Erect KOEO',
      'P100E': 'Unable To Erect KOER',
      'P100F': 'Unable To Erect KOEO',
      
      // Common P2xxx codes
      'P2000': 'NOx Trap Efficiency Below Threshold',
      'P2001': 'NOx Trap Efficiency Below Threshold Bank 1',
      'P2002': 'NOx Trap Efficiency Below Threshold Bank 2',
      'P2003': 'NOx Trap Bank 1',
      'P2004': 'NOx Trap Bank 2',
      'P2005': 'NOx Trap Bank 1',
      'P2006': 'NOx Trap Bank 2',
      'P2007': 'NOx Trap Bank 1',
      'P2008': 'NOx Trap Bank 2',
      'P2009': 'NOx Trap Bank 1',
      'P200A': 'NOx Trap Bank 2',
      'P200B': 'NOx Trap Bank 1',
      'P200C': 'NOx Trap Bank 2',
      'P200D': 'NOx Trap Bank 1',
      'P200E': 'NOx Trap Bank 2',
      'P200F': 'NOx Trap Bank 1',
      
      // Common P3xxx codes
      'P3000': 'Random/Multiple Cylinder Misfire Detected',
      'P3001': 'Cylinder 1 Misfire Detected',
      'P3002': 'Cylinder 2 Misfire Detected',
      'P3003': 'Cylinder 3 Misfire Detected',
      'P3004': 'Cylinder 4 Misfire Detected',
      'P3005': 'Cylinder 5 Misfire Detected',
      'P3006': 'Cylinder 6 Misfire Detected',
      'P3007': 'Cylinder 7 Misfire Detected',
      'P3008': 'Cylinder 8 Misfire Detected',
      'P3009': 'Cylinder 9 Misfire Detected',
      'P300A': 'Cylinder 10 Misfire Detected',
      'P300B': 'Cylinder 11 Misfire Detected',
      'P300C': 'Cylinder 12 Misfire Detected',
      'P300D': 'Cylinder 13 Misfire Detected',
      'P300E': 'Cylinder 14 Misfire Detected',
      'P300F': 'Cylinder 15 Misfire Detected',
      
      // Common P4xxx codes
      'P4000': 'Catalyst System Efficiency Below Threshold Bank 1',
      'P4001': 'Catalyst System Efficiency Below Threshold Bank 2',
      'P4002': 'Catalyst System Efficiency Below Threshold Bank 1',
      'P4003': 'Catalyst System Efficiency Below Threshold Bank 2',
      'P4004': 'Catalyst System Efficiency Below Threshold Bank 1',
      'P4005': 'Catalyst System Efficiency Below Threshold Bank 2',
      'P4006': 'Catalyst System Efficiency Below Threshold Bank 1',
      'P4007': 'Catalyst System Efficiency Below Threshold Bank 2',
      'P4008': 'Catalyst System Efficiency Below Threshold Bank 1',
      'P4009': 'Catalyst System Efficiency Below Threshold Bank 2',
      'P400A': 'Catalyst System Efficiency Below Threshold Bank 1',
      'P400B': 'Catalyst System Efficiency Below Threshold Bank 2',
      'P400C': 'Catalyst System Efficiency Below Threshold Bank 1',
      'P400D': 'Catalyst System Efficiency Below Threshold Bank 2',
      'P400E': 'Catalyst System Efficiency Below Threshold Bank 1',
      'P400F': 'Catalyst System Efficiency Below Threshold Bank 2',
      
      // Common P5xxx codes
      'P5000': 'Vehicle Speed Sensor Malfunction',
      'P5001': 'Vehicle Speed Sensor Range/Performance',
      'P5002': 'Vehicle Speed Sensor Low Input',
      'P5003': 'Vehicle Speed Sensor High Input',
      'P5004': 'Vehicle Speed Sensor Intermittent',
      'P5005': 'Vehicle Speed Sensor Malfunction',
      'P5006': 'Vehicle Speed Sensor Range/Performance',
      'P5007': 'Vehicle Speed Sensor Low Input',
      'P5008': 'Vehicle Speed Sensor High Input',
      'P5009': 'Vehicle Speed Sensor Intermittent',
      'P500A': 'Vehicle Speed Sensor Malfunction',
      'P500B': 'Vehicle Speed Sensor Range/Performance',
      'P500C': 'Vehicle Speed Sensor Low Input',
      'P500D': 'Vehicle Speed Sensor High Input',
      'P500E': 'Vehicle Speed Sensor Intermittent',
      'P500F': 'Vehicle Speed Sensor Malfunction',
    };
    
    return descriptions[code] ?? 'Unknown DTC: $code';
  }

  // Get live data for specific PID
  Future<LiveDataPoint?> getLiveData(String pid) async {
    if (!_pids.containsKey(pid)) return null;

    final response = await sendCommand(pid);
    if (response.isEmpty || response.contains('NO DATA')) return null;

    final data = response.split(' ');
    if (data.length < 3) return null;

    final pidInfo = _pids[pid]!;
    final value = _calculateValue(data.sublist(3), pidInfo['formula'] as String);

    return LiveDataPoint(
      pid: pid,
      name: pidInfo['name'] as String,
      value: value,
      unit: pidInfo['unit'] as String,
      description: pidInfo['description'] as String,
    );
  }

  // Calculate value from raw data using formula
  double _calculateValue(List<String> data, String formula) {
    if (data.isEmpty) return 0.0;

    final a = int.parse(data[0], radix: 16).toDouble();
    final b = data.length > 1 ? int.parse(data[1], radix: 16).toDouble() : 0.0;
    // Remove unused variables c and d
    // final c = data.length > 2 ? int.parse(data[2], radix: 16).toDouble() : 0.0;
    // final d = data.length > 3 ? int.parse(data[3], radix: 16).toDouble() : 0.0;
    
    // Handle raw data
    if (formula == 'raw') {
      return a; // Return first byte for raw data
    }

    // Comprehensive formula evaluation
    switch (formula) {
      case 'A - 40':
        return a - 40;
      case 'A':
        return a;
      case '((A * 256) + B) / 4':
        return ((a * 256) + b) / 4;
      case '(A * 100) / 255':
        return (a * 100) / 255;
      case '((A - 128) * 100) / 128':
        return ((a - 128) * 100) / 128;
      case '(A - 128) / 2':
        return (a - 128) / 2;
      case 'A * 3':
        return a * 3;
      case '((A * 256) + B) / 100':
        return ((a * 256) + b) / 100;
      case 'A / 200':
        return a / 200;
      case '(A * 256) + B':
        return (a * 256) + b;
      case '((A * 256) + B) * 10':
        return ((a * 256) + b) * 10;
      case '((A * 256) + B) * 2 / 65535':
        return ((a * 256) + b) * 2 / 65535;
      case '((A * 256) + B) / 10 - 40':
        return ((a * 256) + b) / 10 - 40;
      case '((A * 256) + B) / 1000':
        return ((a * 256) + b) / 1000;
      case '((A * 256) + B) * 100 / 255':
        return ((a * 256) + b) * 100 / 255;
      case '((A * 256) + B) / 32768':
        return ((a * 256) + b) / 32768;
      case '((A * 256) + B) - 32767':
        return ((a * 256) + b) - 32767;
      case '(((A * 256) + B) - 26880) / 128':
        return (((a * 256) + b) - 26880) / 128;
      case '((A * 256) + B) / 20':
        return ((a * 256) + b) / 20;
      default:
        return a; // Default to first byte
    }
  }

  // Get emissions monitor status
  Future<List<EmissionsMonitorStatus>> getEmissionsStatus() async {
    final response = await sendCommand(_elmCommands['getEmissionsReadiness']!);
    if (response.isEmpty || response.contains('NO DATA')) return [];

    final statuses = <EmissionsMonitorStatus>[];
    final data = response.split(' ');
    if (data.length >= 4) {
      final readinessBytes = data.sublist(3);
      if (readinessBytes.length >= 2) {
        final byte1 = int.parse(readinessBytes[0], radix: 16);
        final byte2 = int.parse(readinessBytes[1], radix: 16);

        // Parse monitor status from bytes
        statuses.addAll(_parseEmissionsMonitors(byte1, byte2));
      }
    }

    return statuses;
  }

  // Parse emissions monitors from bytes
  List<EmissionsMonitorStatus> _parseEmissionsMonitors(int byte1, int byte2) {
    final statuses = <EmissionsMonitorStatus>[];
    
    // This is a simplified parsing - actual implementation depends on vehicle
    final monitors = [
      {'name': 'MIS', 'bit': 0, 'byte': byte1},
      {'name': 'FUEL', 'bit': 1, 'byte': byte1},
      {'name': 'CCM', 'bit': 2, 'byte': byte1},
      {'name': 'CAT', 'bit': 3, 'byte': byte1},
      {'name': 'HEATED_CAT', 'bit': 4, 'byte': byte1},
      {'name': 'EVAP', 'bit': 5, 'byte': byte1},
      {'name': 'AIR', 'bit': 6, 'byte': byte1},
      {'name': 'O2S', 'bit': 7, 'byte': byte1},
      {'name': 'O2S_HEATER', 'bit': 0, 'byte': byte2},
      {'name': 'AC_REF', 'bit': 1, 'byte': byte2},
    ];

    for (final monitor in monitors) {
      final byte = monitor['byte'] as int;
      final bit = monitor['bit'] as int;
      final isReady = (byte & (1 << bit)) != 0;
      final status = isReady ? 'Ready' : 'Not Ready';
      
      statuses.add(EmissionsMonitorStatus(
        monitor: _emissionsMonitors[monitor['name'] as String] ?? monitor['name'] as String,
        status: status,
        description: 'Emissions monitor status for ${monitor['name']}',
      ));
    }

    return statuses;
  }

  // Clear trouble codes
  Future<bool> clearTroubleCodes() async {
    final response = await sendCommand(_elmCommands['clearTroubleCodes']!);
    return response.contains('OK');
  }

  // Get vehicle information
  Future<Map<String, dynamic>> getVehicleInfo() async {
    final info = <String, dynamic>{};
    
    // Get VIN (if supported)
    try {
      final vinResponse = await sendCommand('0902');
      if (vinResponse.isNotEmpty && !vinResponse.contains('NO DATA')) {
        info['vin'] = _parseVIN(vinResponse);
      }
    } catch (e) {
      print('VIN not supported: $e');
    }

    // Get calibration IDs
    try {
      final calResponse = await sendCommand('0904');
      if (calResponse.isNotEmpty && !calResponse.contains('NO DATA')) {
        info['calibration'] = _parseCalibration(calResponse);
      }
    } catch (e) {
      print('Calibration info not supported: $e');
    }

    return info;
  }

  // Parse VIN from response
  String _parseVIN(String response) {
    final data = response.split(' ');
    if (data.length < 7) return '';

    // VIN starts at byte 5 and is 17 characters
    final vinBytes = data.sublist(5, 22);
    final vin = vinBytes.map((byte) => String.fromCharCode(int.parse(byte, radix: 16))).join();
    return vin.substring(0, 17);
  }

  // Parse calibration info
  String _parseCalibration(String response) {
    final data = response.split(' ');
    if (data.length < 7) return '';

    final calBytes = data.sublist(5);
    return calBytes.map((byte) => String.fromCharCode(int.parse(byte, radix: 16))).join();
  }

  // Perform complete diagnostic scan
  Future<DiagnosticReport> performDiagnosticScan(String vehicleVin) async {
    final scanId = DateTime.now().millisecondsSinceEpoch.toString();
    final scanDate = DateTime.now();
    
    // Get trouble codes
    final troubleCodes = await getTroubleCodes();
    
    // Get live data for common PIDs
    final liveData = <LiveDataPoint>[];
    final supportedPids = await getSupportedPids();
    
    for (final pid in _pids.keys) {
      if (supportedPids.contains(pid)) {
        final dataPoint = await getLiveData(pid);
        if (dataPoint != null) {
          liveData.add(dataPoint);
        }
      }
    }
    
    // Get emissions status
    final emissionsStatus = await getEmissionsStatus();
    
    // Get vehicle info
    final vehicleInfo = await getVehicleInfo();
    
    // Create raw scan data
    final rawScanData = {
      'protocol': _currentProtocol,
      'vehicleInfo': vehicleInfo,
      'supportedPids': supportedPids,
    };

    return DiagnosticReport(
      id: scanId,
      vehicleVin: vehicleVin,
      scanDate: scanDate,
      troubleCodes: troubleCodes,
      liveData: liveData,
      emissionsStatus: emissionsStatus,
      vehicleData: null, // Will be filled by NHTSA service
      gptAnalysis: '', // Will be filled by GPT service
      severity: _calculateSeverity(troubleCodes),
      recommendations: [], // Will be filled by GPT service
      rawScanData: rawScanData,
    );
  }

  // Calculate overall severity
  String _calculateSeverity(List<DiagnosticTroubleCode> codes) {
    if (codes.isEmpty) return 'Good';
    
    final hasCritical = codes.any((code) => 
        code.severity == 'P' && code.code.startsWith('P0'));
    final hasWarning = codes.any((code) => 
        code.severity == 'P' && code.code.startsWith('P1'));
    
    if (hasCritical) return 'Critical';
    if (hasWarning) return 'Warning';
    return 'Info';
  }

  // Disconnect from device
  Future<void> disconnect() async {
    _isConnected = false;
    await _dataStream?.close();
    await _connection?.close();
    _connection = null;
    _dataStream = null;
  }

  double _parseFuelPressure(List<String> data) {
    if (data.isEmpty) return 0.0;
    
    final a = int.parse(data[0], radix: 16).toDouble();
    final b = data.length > 1 ? int.parse(data[1], radix: 16).toDouble() : 0.0;
    // Remove unused variables c and d
    // final c = data.length > 2 ? int.parse(data[2], radix: 16).toDouble() : 0.0;
    // final d = data.length > 3 ? int.parse(data[3], radix: 16).toDouble() : 0.0;
    
    return a * 3.0; // kPa
  }
} 