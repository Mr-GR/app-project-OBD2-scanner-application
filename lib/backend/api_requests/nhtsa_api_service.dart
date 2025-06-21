import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/diagnostic_models.dart';

class NHTSAApiService {
  static const String _baseUrl = 'https://vpic.nhtsa.dot.gov/api';
  
  // Get vehicle data by VIN
  Future<NHTSAVehicleData?> getVehicleDataByVin(String vin) async {
    try {
      final url = Uri.parse('$_baseUrl/vehicles/decodevin/$vin?format=json');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NHTSAVehicleData.fromJson(data);
      } else {
        print('NHTSA API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching vehicle data from NHTSA: $e');
      return null;
    }
  }

  // Get vehicle data by make, model, and year
  Future<List<NHTSAVehicleData>> getVehiclesByMakeModelYear({
    required String make,
    required String model,
    required String year,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/vehicles/GetVehicleTypesForMakeId/$make?format=json'
      );
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['Results'] as List?;
        
        if (results != null) {
          return results
              .where((vehicle) => 
                  vehicle['Model']?.toString().toLowerCase().contains(model.toLowerCase()) == true &&
                  vehicle['ModelYear']?.toString() == year)
              .map((vehicle) => NHTSAVehicleData.fromJson({'Results': [vehicle]}))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching vehicles by make/model/year: $e');
      return [];
    }
  }

  // Get all makes
  Future<List<String>> getAllMakes() async {
    try {
      final url = Uri.parse('$_baseUrl/vehicles/getallmakes?format=json');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['Results'] as List?;
        
        if (results != null) {
          return results
              .map((make) => make['Make_Name'] as String)
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching makes: $e');
      return [];
    }
  }

  // Get models for a specific make
  Future<List<String>> getModelsForMake(String make) async {
    try {
      final url = Uri.parse('$_baseUrl/vehicles/getmodelsformake/$make?format=json');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['Results'] as List?;
        
        if (results != null) {
          return results
              .map((model) => model['Model_Name'] as String)
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching models for make $make: $e');
      return [];
    }
  }

  // Get years for a specific make and model
  Future<List<String>> getYearsForMakeModel({
    required String make,
    required String model,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/vehicles/GetVehicleTypesForMakeId/$make?format=json'
      );
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['Results'] as List?;
        
        if (results != null) {
          final years = results
              .where((vehicle) => 
                  vehicle['Model']?.toString().toLowerCase().contains(model.toLowerCase()) == true)
              .map((vehicle) => vehicle['ModelYear']?.toString() ?? '')
              .where((year) => year.isNotEmpty)
              .toSet()
              .toList();
          
          years.sort((a, b) => int.parse(b).compareTo(int.parse(a)));
          return years;
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching years for make $make model $model: $e');
      return [];
    }
  }

  // Validate VIN format
  bool isValidVin(String vin) {
    if (vin.length != 17) return false;
    
    // Check for valid characters (no I, O, Q)
    final invalidChars = RegExp(r'[IOQ]');
    if (invalidChars.hasMatch(vin.toUpperCase())) return false;
    
    // Check for valid VIN format (simplified)
    final vinPattern = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$');
    return vinPattern.hasMatch(vin.toUpperCase());
  }

  // Decode VIN to get basic information
  Map<String, String> decodeVinBasic(String vin) {
    if (!isValidVin(vin)) return {};
    
    final upperVin = vin.toUpperCase();
    
    // Extract basic information from VIN
    final worldManufacturer = upperVin.substring(0, 3);
    final vehicleAttributes = upperVin.substring(3, 9);
    final checkDigit = upperVin[8];
    final modelYear = upperVin[9];
    final plantCode = upperVin[10];
    final serialNumber = upperVin.substring(11);
    
    // Decode model year
    String year = '';
    final yearChar = modelYear;
    if (RegExp(r'[1-9]').hasMatch(yearChar)) {
      year = '200${yearChar}';
    } else if (RegExp(r'[A-Y]').hasMatch(yearChar)) {
      final yearCode = yearChar.codeUnitAt(0) - 'A'.codeUnitAt(0) + 1;
      year = (2010 + yearCode).toString();
    }
    
    return {
      'worldManufacturer': worldManufacturer,
      'vehicleAttributes': vehicleAttributes,
      'checkDigit': checkDigit,
      'modelYear': year,
      'plantCode': plantCode,
      'serialNumber': serialNumber,
    };
  }

  // Get vehicle specifications by VIN
  Future<Map<String, dynamic>> getVehicleSpecifications(String vin) async {
    try {
      final url = Uri.parse('$_baseUrl/vehicles/decodevin/$vin?format=json');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['Results'] as List?;
        
        if (results != null && results.isNotEmpty) {
          final vehicle = results.first;
          return {
            'make': vehicle['Make'] ?? '',
            'model': vehicle['Model'] ?? '',
            'year': vehicle['ModelYear'] ?? '',
            'bodyClass': vehicle['BodyClass'] ?? '',
            'engineConfiguration': vehicle['EngineConfiguration'] ?? '',
            'engineCylinders': vehicle['EngineCylinders'] ?? '',
            'fuelType': vehicle['FuelTypePrimary'] ?? '',
            'transmissionStyle': vehicle['TransmissionStyle'] ?? '',
            'driveType': vehicle['DriveType'] ?? '',
            'brakeSystemType': vehicle['BrakeSystemType'] ?? '',
            'steeringType': vehicle['SteeringType'] ?? '',
            'antiBrakeSystem': vehicle['AntiBrakeSystem'] ?? '',
            'tankSize': vehicle['TankSize'] ?? '',
            'overallHeight': vehicle['OverallHeight'] ?? '',
            'overallLength': vehicle['OverallLength'] ?? '',
            'overallWidth': vehicle['OverallWidth'] ?? '',
            'standardSeating': vehicle['StandardSeating'] ?? '',
            'optionalSeating': vehicle['OptionalSeating'] ?? '',
            'highwayMpg': vehicle['HighwayMpg'] ?? '',
            'cityMpg': vehicle['CityMpg'] ?? '',
            'grossVehicleWeightRating': vehicle['GrossVehicleWeightRating'] ?? '',
            'bedLength': vehicle['BedLength'] ?? '',
            'bedType': vehicle['BedType'] ?? '',
            'cabType': vehicle['CabType'] ?? '',
            'wheelBase': vehicle['WheelBase'] ?? '',
            'grossAxleWeightRating': vehicle['GrossAxleWeightRating'] ?? '',
            'otherEngineInfo': vehicle['OtherEngineInfo'] ?? '',
            'otherRestraintSystemInfo': vehicle['OtherRestraintSystemInfo'] ?? '',
            'otherTrailerInfo': vehicle['OtherTrailerInfo'] ?? '',
            'plantCity': vehicle['PlantCity'] ?? '',
            'plantCountry': vehicle['PlantCountry'] ?? '',
            'plantState': vehicle['PlantState'] ?? '',
            'plantCompanyName': vehicle['PlantCompanyName'] ?? '',
            'vehicleType': vehicle['VehicleType'] ?? '',
            'engineModel': vehicle['EngineModel'] ?? '',
            'engineManufacturer': vehicle['EngineManufacturer'] ?? '',
            'engineDisplacement': vehicle['EngineDisplacement'] ?? '',
            'enginePower': vehicle['EnginePower'] ?? '',
            'primaryFuelType': vehicle['PrimaryFuelType'] ?? '',
            'secondaryFuelType': vehicle['SecondaryFuelType'] ?? '',
            'otherMotorInfo': vehicle['OtherMotorInfo'] ?? '',
            'numberOfForwardGears': vehicle['NumberOfForwardGears'] ?? '',
            'transmissionModel': vehicle['TransmissionModel'] ?? '',
            'transmissionManufacturer': vehicle['TransmissionManufacturer'] ?? '',
            'otherTransmissionInfo': vehicle['OtherTransmissionInfo'] ?? '',
            'driveSystem': vehicle['DriveSystem'] ?? '',
            'axleConfiguration': vehicle['AxleConfiguration'] ?? '',
            'otherAxleInfo': vehicle['OtherAxleInfo'] ?? '',
            'wheelBaseType': vehicle['WheelBaseType'] ?? '',
            'otherWheelBaseInfo': vehicle['OtherWheelBaseInfo'] ?? '',
            'otherBusInfo': vehicle['OtherBusInfo'] ?? '',
            'otherMotorcycleInfo': vehicle['OtherMotorcycleInfo'] ?? '',
            'otherTruckInfo': vehicle['OtherTruckInfo'] ?? '',
            'otherVehicleInfo': vehicle['OtherVehicleInfo'] ?? '',
            'busLength': vehicle['BusLength'] ?? '',
            'busFloorConfigurationType': vehicle['BusFloorConfigurationType'] ?? '',
            'motorcycleSuspensionType': vehicle['MotorcycleSuspensionType'] ?? '',
            'motorcycleChassisType': vehicle['MotorcycleChassisType'] ?? '',
            'motorcycleWheelBase': vehicle['MotorcycleWheelBase'] ?? '',
            'motorcycleOtherInfo': vehicle['MotorcycleOtherInfo'] ?? '',
            'trailerBodyType': vehicle['TrailerBodyType'] ?? '',
            'trailerLength': vehicle['TrailerLength'] ?? '',
            'trailerAxles': vehicle['TrailerAxles'] ?? '',
            'truckCargoBodyType': vehicle['TruckCargoBodyType'] ?? '',
            'truckLoadType': vehicle['TruckLoadType'] ?? '',
          };
        }
      }
      
      return {};
    } catch (e) {
      print('Error fetching vehicle specifications: $e');
      return {};
    }
  }

  // Get vehicle recalls by VIN
  Future<List<Map<String, dynamic>>> getVehicleRecalls(String vin) async {
    try {
      final url = Uri.parse('$_baseUrl/vehicles/recalls/vin/$vin?format=json');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['Results'] as List?;
        
        if (results != null) {
          return results.cast<Map<String, dynamic>>();
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching vehicle recalls: $e');
      return [];
    }
  }

  // Get vehicle complaints by VIN
  Future<List<Map<String, dynamic>>> getVehicleComplaints(String vin) async {
    try {
      final url = Uri.parse('$_baseUrl/vehicles/complaints/vin/$vin?format=json');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['Results'] as List?;
        
        if (results != null) {
          return results.cast<Map<String, dynamic>>();
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching vehicle complaints: $e');
      return [];
    }
  }
} 