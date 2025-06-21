import 'package:flutter/foundation.dart';
// TODO: FIREBASE INTEGRATION
// When ready to integrate Firebase, uncomment:
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import '../schema/vehicle_record.dart';
import '../models/scan_result.dart';
import '../models/chat_session.dart';
import '../api_requests/chatgpt_api_service.dart';

class VehicleProvider extends ChangeNotifier {
  // TODO: FIREBASE INTEGRATION
  // When ready to integrate Firebase, uncomment:
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<VehicleRecord> _vehicles = [];
  VehicleRecord? _selectedVehicle;
  List<ScanResult> _scanResults = [];
  List<ChatSession> _chatSessions = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<VehicleRecord> get vehicles => _vehicles;
  VehicleRecord? get selectedVehicle => _selectedVehicle;
  List<ScanResult> get scanResults => _scanResults;
  List<ChatSession> get chatSessions => _chatSessions;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Initialize the provider
  Future<void> initialize() async {
    await _loadVehicles();
  }

  // Load user's vehicles (mock data for now)
  Future<void> _loadVehicles() async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // if (_auth.currentUser == null) return;
    // final querySnapshot = await _firestore
    //     .collection('vehicles')
    //     .where('ownerId', isEqualTo: _auth.currentUser!.uid)
    //     .orderBy('createdTime', descending: true)
    //     .get();
    // ... Firebase implementation

    _setLoading(true);
    try {
      // Mock data for development
      _vehicles = [
        VehicleRecord(
          reference: 'mock_vehicle_1',
          vin: '1HGBH41JXMN109186',
          make: 'Honda',
          model: 'Civic',
          year: '2021',
          ownerId: 'mock_user_id',
          nickname: 'My Civic',
          color: 'Blue',
          licensePlate: 'ABC123',
          mileage: '15000',
          lastScanDate: DateTime.now().subtract(Duration(days: 2)),
          scanHistory: [],
          chatHistory: [],
          createdTime: DateTime.now().subtract(Duration(days: 30)),
          updatedTime: DateTime.now().subtract(Duration(days: 2)),
        ),
        VehicleRecord(
          reference: 'mock_vehicle_2',
          vin: '5NPE34AF4FH012345',
          make: 'Hyundai',
          model: 'Sonata',
          year: '2015',
          ownerId: 'mock_user_id',
          nickname: 'Family Car',
          color: 'Silver',
          licensePlate: 'XYZ789',
          mileage: '85000',
          lastScanDate: DateTime.now().subtract(Duration(days: 5)),
          scanHistory: [],
          chatHistory: [],
          createdTime: DateTime.now().subtract(Duration(days: 60)),
          updatedTime: DateTime.now().subtract(Duration(days: 5)),
        ),
      ];
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load vehicles: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add a new vehicle (mock data for now)
  Future<VehicleRecord?> addVehicle({
    required String vin,
    required String make,
    required String model,
    required String year,
    String? nickname,
    String? color,
    String? licensePlate,
    String? mileage,
  }) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // if (_auth.currentUser == null) {
    //   _setError('User not authenticated');
    //   return null;
    // }

    // Check if VIN already exists
    final existingVehicle = _vehicles.where((v) => v.vin == vin).firstOrNull;
    if (existingVehicle != null) {
      _setError('Vehicle with this VIN already exists');
      return null;
    }

    _setLoading(true);
    try {
      // TODO: FIREBASE INTEGRATION
      // When ready to integrate Firebase, replace with:
      // final vehicleData = createVehicleRecordData(...);
      // final docRef = await _firestore.collection('vehicles').add(vehicleData);

      final newVehicle = VehicleRecord(
        reference: 'mock_vehicle_${_vehicles.length + 1}',
        vin: vin,
        make: make,
        model: model,
        year: year,
        ownerId: 'mock_user_id',
        nickname: nickname,
        color: color,
        licensePlate: licensePlate,
        mileage: mileage,
        createdTime: DateTime.now(),
        updatedTime: DateTime.now(),
      );
      
      _vehicles.insert(0, newVehicle);
      notifyListeners();
      
      return newVehicle;
    } catch (e) {
      _setError('Failed to add vehicle: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Select a vehicle
  void selectVehicle(VehicleRecord vehicle) {
    _selectedVehicle = vehicle;
    _loadVehicleData(vehicle.vin);
    notifyListeners();
  }

  // Load vehicle-specific data
  Future<void> _loadVehicleData(String vin) async {
    await Future.wait([
      _loadScanResults(vin),
      _loadChatSessions(vin),
    ]);
  }

  // Load scan results for a vehicle (mock data for now)
  Future<void> _loadScanResults(String vin) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final querySnapshot = await _firestore
    //     .collection('scanResults')
    //     .where('vehicleVin', isEqualTo: vin)
    //     .orderBy('scanDate', descending: true)
    //     .get();
    // _scanResults = querySnapshot.docs
    //     .map((doc) => ScanResult.fromJson(doc.data()))
    //     .toList();

    try {
      // Mock scan results
      _scanResults = [
        ScanResult(
          id: 'scan_1',
          vehicleVin: vin,
          scanDate: DateTime.now().subtract(Duration(days: 2)),
          scanType: 'manual',
          diagnosticData: {
            'engineStatus': 'Warning',
            'fuelLevel': 75.0,
            'engineTemp': 195.0,
            'batteryVoltage': 12.6,
            'mileage': 15000,
          },
          errorCodes: ['P0300', 'P0171'],
          notes: 'Engine misfire detected',
        ),
        ScanResult(
          id: 'scan_2',
          vehicleVin: vin,
          scanDate: DateTime.now().subtract(Duration(days: 5)),
          scanType: 'manual',
          diagnosticData: {
            'engineStatus': 'Normal',
            'fuelLevel': 45.0,
            'engineTemp': 190.0,
            'batteryVoltage': 12.8,
            'mileage': 14950,
          },
          errorCodes: [],
          notes: 'Routine scan - all systems normal',
        ),
      ];
      
      notifyListeners();
    } catch (e) {
      print('Failed to load scan results: $e');
    }
  }

  // Load chat sessions for a vehicle (mock data for now)
  Future<void> _loadChatSessions(String vin) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final querySnapshot = await _firestore
    //     .collection('chatSessions')
    //     .where('vehicleVin', isEqualTo: vin)
    //     .orderBy('sessionDate', descending: true)
    //     .get();
    // _chatSessions = querySnapshot.docs
    //     .map((doc) => ChatSession.fromJson(doc.data()))
    //     .toList();

    try {
      // Mock chat sessions
      _chatSessions = [
        ChatSession(
          id: 'chat_1',
          vehicleVin: vin,
          sessionDate: DateTime.now().subtract(Duration(days: 1)),
          title: 'Engine Misfire Discussion',
          messages: [
            ChatMessage(
              role: 'user',
              content: 'What does error code P0300 mean?',
              timestamp: DateTime.now().subtract(Duration(days: 1, hours: 2)),
            ),
            ChatMessage(
              role: 'assistant',
              content: 'P0300 indicates a random/multiple cylinder misfire detected. This can be caused by...',
              timestamp: DateTime.now().subtract(Duration(days: 1, hours: 1)),
            ),
          ],
          summary: 'Discussion about engine misfire diagnostic code P0300',
        ),
        ChatSession(
          id: 'chat_2',
          vehicleVin: vin,
          sessionDate: DateTime.now().subtract(Duration(days: 3)),
          title: 'Oil Change Discussion',
          messages: [
            ChatMessage(
              role: 'user',
              content: 'How often should I change my oil?',
              timestamp: DateTime.now().subtract(Duration(days: 3, hours: 2)),
            ),
            ChatMessage(
              role: 'assistant',
              content: 'For most modern vehicles, oil changes are recommended every 5,000-7,500 miles...',
              timestamp: DateTime.now().subtract(Duration(days: 3, hours: 1)),
            ),
          ],
          summary: 'Oil change interval discussion',
        ),
      ];
      
      notifyListeners();
    } catch (e) {
      print('Failed to load chat sessions: $e');
    }
  }

  // Add scan result
  Future<bool> addScanResult({
    required String vehicleVin,
    required String scanType,
    required Map<String, dynamic> diagnosticData,
    required List<String> errorCodes,
    String? notes,
    Map<String, dynamic>? rawData,
  }) async {
    _setLoading(true);
    try {
      final scanResult = ScanResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        vehicleVin: vehicleVin,
        scanDate: DateTime.now(),
        scanType: scanType,
        diagnosticData: diagnosticData,
        errorCodes: errorCodes,
        notes: notes,
        rawData: rawData,
      );

      // TODO: FIREBASE INTEGRATION
      // When ready to integrate Firebase, replace with:
      // await _firestore
      //     .collection('scanResults')
      //     .doc(scanResult.id)
      //     .set(scanResult.toJson());

      // Update vehicle's last scan date
      final vehicleIndex = _vehicles.indexWhere((v) => v.vin == vehicleVin);
      if (vehicleIndex != -1) {
        final vehicle = _vehicles[vehicleIndex];
        // TODO: FIREBASE INTEGRATION
        // When ready to integrate Firebase, replace with:
        // await _firestore
        //     .collection('vehicles')
        //     .doc(vehicle.reference?.split('/').last)
        //     .update({
        //   'lastScanDate': Timestamp.now(),
        //   'updatedTime': Timestamp.now(),
        // });
        
        // Update local vehicle data
        _vehicles[vehicleIndex] = vehicle.copyWith(
          lastScanDate: DateTime.now(),
          updatedTime: DateTime.now(),
        );
      }

      // Add to local list
      _scanResults.insert(0, scanResult);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to save scan result: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add chat session
  Future<bool> addChatSession({
    required String vehicleVin,
    required String title,
    required List<ChatMessage> messages,
    String? summary,
    Map<String, dynamic>? metadata,
  }) async {
    _setLoading(true);
    try {
      final chatSession = ChatSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        vehicleVin: vehicleVin,
        sessionDate: DateTime.now(),
        title: title,
        messages: messages,
        summary: summary,
        metadata: metadata,
      );

      // TODO: FIREBASE INTEGRATION
      // When ready to integrate Firebase, replace with:
      // await _firestore
      //     .collection('chatSessions')
      //     .doc(chatSession.id)
      //     .set(chatSession.toJson());

      // Add to local list
      _chatSessions.insert(0, chatSession);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to save chat session: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update vehicle with named parameters
  Future<bool> updateVehicle({
    required String vin,
    String? nickname,
    String? color,
    String? licensePlate,
    String? mileage,
  }) async {
    try {
      final vehicleIndex = _vehicles.indexWhere((v) => v.vin == vin);
      if (vehicleIndex == -1) {
        _setError('Vehicle not found');
        return false;
      }

      final currentVehicle = _vehicles[vehicleIndex];
      final updatedVehicle = currentVehicle.copyWith(
        nickname: nickname,
        color: color,
        licensePlate: licensePlate,
        mileage: mileage,
        updatedTime: DateTime.now(),
      );

      // TODO: FIREBASE INTEGRATION
      // When ready to integrate Firebase, replace with:
      // await _firestore
      //     .collection('vehicles')
      //     .doc(currentVehicle.reference?.split('/').last)
      //     .update(updatedVehicle.toMap());

      // Update local list
      _vehicles[vehicleIndex] = updatedVehicle;
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to update vehicle: $e');
      return false;
    }
  }

  // Delete vehicle
  Future<bool> deleteVehicle(String vin) async {
    _setLoading(true);
    try {
      final vehicleIndex = _vehicles.indexWhere((v) => v.vin == vin);
      if (vehicleIndex == -1) {
        _setError('Vehicle not found');
        return false;
      }

      final vehicle = _vehicles[vehicleIndex];
      
      // TODO: FIREBASE INTEGRATION
      // When ready to integrate Firebase, replace with:
      // await _firestore
      //     .collection('vehicles')
      //     .doc(vehicle.reference?.split('/').last)
      //     .delete();
      // final scanResultsQuery = await _firestore
      //     .collection('scanResults')
      //     .where('vehicleVin', isEqualTo: vin)
      //     .get();
      // for (final doc in scanResultsQuery.docs) {
      //   await doc.reference.delete();
      // }
      // final chatSessionsQuery = await _firestore
      //     .collection('chatSessions')
      //     .where('vehicleVin', isEqualTo: vin)
      //     .get();
      // for (final doc in chatSessionsQuery.docs) {
      //   await doc.reference.delete();
      // }

      // Remove from local lists
      _vehicles.removeAt(vehicleIndex);
      if (_selectedVehicle?.vin == vin) {
        _selectedVehicle = null;
        _scanResults.clear();
        _chatSessions.clear();
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete vehicle: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get vehicle by VIN
  VehicleRecord? getVehicleByVin(String vin) {
    return _vehicles.where((v) => v.vin == vin).firstOrNull;
  }

  // Clear selected vehicle
  void clearSelectedVehicle() {
    _selectedVehicle = null;
    _scanResults.clear();
    _chatSessions.clear();
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
} 