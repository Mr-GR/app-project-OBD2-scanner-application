import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class VehicleService {
  static const String _baseUrl = 'http://${Config.baseUrl}/api';

  // Add vehicle by VIN (using new backend endpoint)
  static Future<VehicleResponse> addVehicle({
    required String vin,
    bool isPrimary = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/vehicles'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'vin': vin,
          'is_primary': isPrimary,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return VehicleResponse.fromDatabaseJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to add vehicle: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get all stored vehicles
  static Future<List<VehicleResponse>> getVehicles() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/vehicles'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> vehicleList = data['vehicles'];
        return vehicleList.map((json) => VehicleResponse.fromDatabaseJson(json)).toList();
      } else {
        throw Exception('Failed to get vehicles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Delete a vehicle
  static Future<void> deleteVehicle(String vehicleId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/vehicles/$vehicleId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to delete vehicle');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Set vehicle as primary
  static Future<VehicleResponse> setPrimaryVehicle(String vehicleId) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/vehicles/$vehicleId/primary'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VehicleResponse.fromDatabaseJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to set primary vehicle');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get primary vehicle info (for chat context)
  static Future<Map<String, dynamic>> getPrimaryVehicleInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/vehicles/primary/info'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get primary vehicle info');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get vehicle by VIN (for preview before adding - using existing endpoint)
  static Future<VehicleResponse> getVehicleByVin(String vin) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/manual?vin=$vin'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VehicleResponse.fromVinApi(data, vin);
      } else {
        throw Exception('Failed to get vehicle info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

class VehicleResponse {
  final String id;
  final String make;
  final String model;
  final String year;
  final String? trim;
  final String? vin;
  final String? vehicleType;
  final String? bodyClass;
  final String? engineModel;
  final String? fuelType;
  final String? transmission;
  final String? driveType;
  final String? engineCylinders;
  final String? engineDisplacement;
  final String? manufacturer;
  final String? plantCity;
  final String? plantState;
  final String? plantCountry;
  final bool isPrimary;
  final DateTime createdAt;

  VehicleResponse({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.trim,
    this.vin,
    this.vehicleType,
    this.bodyClass,
    this.engineModel,
    this.fuelType,
    this.transmission,
    this.driveType,
    this.engineCylinders,
    this.engineDisplacement,
    this.manufacturer,
    this.plantCity,
    this.plantState,
    this.plantCountry,
    this.isPrimary = false,
    required this.createdAt,
  });

  // For VIN lookup (preview)
  factory VehicleResponse.fromVinApi(Map<String, dynamic> json, String vin) {
    final basicInfo = json['basic_info'] ?? {};
    final detailedInfo = json['detailed_info'] ?? {};
    final manufacturerInfo = json['manufacturer_info'] ?? {};

    return VehicleResponse(
      id: '0', // Temporary ID for preview
      make: basicInfo['make'] ?? '',
      model: basicInfo['model'] ?? '',
      year: basicInfo['year'] ?? '',
      vin: vin,
      vehicleType: basicInfo['vehicle_type'],
      bodyClass: detailedInfo['body_class'],
      engineModel: detailedInfo['engine_model'],
      fuelType: detailedInfo['fuel_type'],
      transmission: detailedInfo['transmission'],
      driveType: detailedInfo['drive_type'],
      engineCylinders: detailedInfo['engine_cylinders'],
      engineDisplacement: detailedInfo['engine_displacement'],
      manufacturer: manufacturerInfo['manufacturer'],
      plantCity: manufacturerInfo['plant_city'],
      plantState: manufacturerInfo['plant_state'],
      plantCountry: manufacturerInfo['plant_country'],
      isPrimary: false,
      createdAt: DateTime.now(),
    );
  }

  // For database stored vehicles
  factory VehicleResponse.fromDatabaseJson(Map<String, dynamic> json) {
    return VehicleResponse(
      id: json['id'].toString(),
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year']?.toString() ?? '',
      vin: json['vin'],
      vehicleType: json['vehicle_type'],
      bodyClass: json['body_class'],
      engineModel: json['engine_model'],
      fuelType: json['fuel_type'],
      transmission: json['transmission'],
      engineCylinders: json['engine_cylinders'],
      engineDisplacement: json['engine_displacement'],
      isPrimary: json['is_primary'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Legacy support for existing fromJson
  factory VehicleResponse.fromJson(Map<String, dynamic> json) {
    return VehicleResponse.fromDatabaseJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'trim': trim,
      'vin': vin,
      'vehicle_type': vehicleType,
      'body_class': bodyClass,
      'engine_model': engineModel,
      'fuel_type': fuelType,
      'transmission': transmission,
      'drive_type': driveType,
      'engine_cylinders': engineCylinders,
      'engine_displacement': engineDisplacement,
      'manufacturer': manufacturer,
      'plant_city': plantCity,
      'plant_state': plantState,
      'plant_country': plantCountry,
      'is_primary': isPrimary,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 