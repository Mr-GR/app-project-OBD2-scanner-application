// Diagnostic Models for OBD2 Scanner App

class DiagnosticTroubleCode {
  final String code;
  final String description;
  final String severity; // 'P', 'C', 'B', 'U'
  final String category;
  final bool isPending;
  final bool isConfirmed;

  DiagnosticTroubleCode({
    required this.code,
    required this.description,
    required this.severity,
    required this.category,
    this.isPending = false,
    this.isConfirmed = true,
  });

  factory DiagnosticTroubleCode.fromJson(Map<String, dynamic> json) {
    return DiagnosticTroubleCode(
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      severity: json['severity'] ?? '',
      category: json['category'] ?? '',
      isPending: json['isPending'] ?? false,
      isConfirmed: json['isConfirmed'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'severity': severity,
      'category': category,
      'isPending': isPending,
      'isConfirmed': isConfirmed,
    };
  }
}

class LiveDataPoint {
  final String pid;
  final String name;
  final dynamic value;
  final String unit;
  final String description;

  LiveDataPoint({
    required this.pid,
    required this.name,
    required this.value,
    required this.unit,
    required this.description,
  });

  factory LiveDataPoint.fromJson(Map<String, dynamic> json) {
    return LiveDataPoint(
      pid: json['pid'] ?? '',
      name: json['name'] ?? '',
      value: json['value'],
      unit: json['unit'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pid': pid,
      'name': name,
      'value': value,
      'unit': unit,
      'description': description,
    };
  }
}

class EmissionsMonitorStatus {
  final String monitor;
  final String status; // 'Ready', 'Not Ready', 'Not Available'
  final String description;

  EmissionsMonitorStatus({
    required this.monitor,
    required this.status,
    required this.description,
  });

  factory EmissionsMonitorStatus.fromJson(Map<String, dynamic> json) {
    return EmissionsMonitorStatus(
      monitor: json['monitor'] ?? '',
      status: json['status'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monitor': monitor,
      'status': status,
      'description': description,
    };
  }
}

class NHTSAVehicleData {
  final String make;
  final String model;
  final String year;
  final String bodyClass;
  final String engineConfiguration;
  final String engineCylinders;
  final String fuelType;
  final String transmissionStyle;
  final String driveType;
  final String brakeSystemType;
  final String steeringType;
  final String antiBrakeSystem;
  final String tankSize;
  final String overallHeight;
  final String overallLength;
  final String overallWidth;
  final String standardSeating;
  final String optionalSeating;
  final String highwayMpg;
  final String cityMpg;

  NHTSAVehicleData({
    required this.make,
    required this.model,
    required this.year,
    required this.bodyClass,
    required this.engineConfiguration,
    required this.engineCylinders,
    required this.fuelType,
    required this.transmissionStyle,
    required this.driveType,
    required this.brakeSystemType,
    required this.steeringType,
    required this.antiBrakeSystem,
    required this.tankSize,
    required this.overallHeight,
    required this.overallLength,
    required this.overallWidth,
    required this.standardSeating,
    required this.optionalSeating,
    required this.highwayMpg,
    required this.cityMpg,
  });

  factory NHTSAVehicleData.fromJson(Map<String, dynamic> json) {
    final results = json['Results']?[0] ?? {};
    return NHTSAVehicleData(
      make: results['Make'] ?? '',
      model: results['Model'] ?? '',
      year: results['ModelYear'] ?? '',
      bodyClass: results['BodyClass'] ?? '',
      engineConfiguration: results['EngineConfiguration'] ?? '',
      engineCylinders: results['EngineCylinders'] ?? '',
      fuelType: results['FuelTypePrimary'] ?? '',
      transmissionStyle: results['TransmissionStyle'] ?? '',
      driveType: results['DriveType'] ?? '',
      brakeSystemType: results['BrakeSystemType'] ?? '',
      steeringType: results['SteeringType'] ?? '',
      antiBrakeSystem: results['AntiBrakeSystem'] ?? '',
      tankSize: results['TankSize'] ?? '',
      overallHeight: results['OverallHeight'] ?? '',
      overallLength: results['OverallLength'] ?? '',
      overallWidth: results['OverallWidth'] ?? '',
      standardSeating: results['StandardSeating'] ?? '',
      optionalSeating: results['OptionalSeating'] ?? '',
      highwayMpg: results['HighwayMpg'] ?? '',
      cityMpg: results['CityMpg'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Results': [{
        'Make': make,
        'Model': model,
        'ModelYear': year,
        'BodyClass': bodyClass,
        'EngineConfiguration': engineConfiguration,
        'EngineCylinders': engineCylinders,
        'FuelTypePrimary': fuelType,
        'TransmissionStyle': transmissionStyle,
        'DriveType': driveType,
        'BrakeSystemType': brakeSystemType,
        'SteeringType': steeringType,
        'AntiBrakeSystem': antiBrakeSystem,
        'TankSize': tankSize,
        'OverallHeight': overallHeight,
        'OverallLength': overallLength,
        'OverallWidth': overallWidth,
        'StandardSeating': standardSeating,
        'OptionalSeating': optionalSeating,
        'HighwayMpg': highwayMpg,
        'CityMpg': cityMpg,
      }]
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'bodyClass': bodyClass,
      'engineConfiguration': engineConfiguration,
      'engineCylinders': engineCylinders,
      'fuelType': fuelType,
      'transmissionStyle': transmissionStyle,
      'driveType': driveType,
      'brakeSystemType': brakeSystemType,
      'steeringType': steeringType,
      'antiBrakeSystem': antiBrakeSystem,
      'tankSize': tankSize,
      'overallHeight': overallHeight,
      'overallLength': overallLength,
      'overallWidth': overallWidth,
      'standardSeating': standardSeating,
      'optionalSeating': optionalSeating,
      'highwayMpg': highwayMpg,
      'cityMpg': cityMpg,
    };
  }
}

class DiagnosticReport {
  final String id;
  final String vehicleVin;
  final DateTime scanDate;
  final List<DiagnosticTroubleCode> troubleCodes;
  final List<LiveDataPoint> liveData;
  final List<EmissionsMonitorStatus> emissionsStatus;
  final NHTSAVehicleData? vehicleData;
  final String gptAnalysis;
  final String severity; // 'Critical', 'Warning', 'Info', 'Good'
  final List<String> recommendations;
  final Map<String, dynamic> rawScanData;
  final int? healthScore; // AI-generated health score (0-100)

  DiagnosticReport({
    required this.id,
    required this.vehicleVin,
    required this.scanDate,
    required this.troubleCodes,
    required this.liveData,
    required this.emissionsStatus,
    this.vehicleData,
    required this.gptAnalysis,
    required this.severity,
    required this.recommendations,
    required this.rawScanData,
    this.healthScore,
  });

  factory DiagnosticReport.fromJson(Map<String, dynamic> json) {
    return DiagnosticReport(
      id: json['id'] ?? '',
      vehicleVin: json['vehicleVin'] ?? '',
      scanDate: DateTime.parse(json['scanDate'] ?? DateTime.now().toIso8601String()),
      troubleCodes: (json['troubleCodes'] as List?)
          ?.map((e) => DiagnosticTroubleCode.fromJson(e))
          .toList() ?? [],
      liveData: (json['liveData'] as List?)
          ?.map((e) => LiveDataPoint.fromJson(e))
          .toList() ?? [],
      emissionsStatus: (json['emissionsStatus'] as List?)
          ?.map((e) => EmissionsMonitorStatus.fromJson(e))
          .toList() ?? [],
      vehicleData: json['vehicleData'] != null 
          ? NHTSAVehicleData.fromJson(json['vehicleData']) 
          : null,
      gptAnalysis: json['gptAnalysis'] ?? '',
      severity: json['severity'] ?? 'Info',
      recommendations: List<String>.from(json['recommendations'] ?? []),
      rawScanData: json['rawScanData'] ?? {},
      healthScore: json['healthScore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleVin': vehicleVin,
      'scanDate': scanDate.toIso8601String(),
      'troubleCodes': troubleCodes.map((e) => e.toJson()).toList(),
      'liveData': liveData.map((e) => e.toJson()).toList(),
      'emissionsStatus': emissionsStatus.map((e) => e.toJson()).toList(),
      'vehicleData': vehicleData?.toJson(),
      'gptAnalysis': gptAnalysis,
      'severity': severity,
      'recommendations': recommendations,
      'rawScanData': rawScanData,
      'healthScore': healthScore,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleVin': vehicleVin,
      'scanDate': scanDate.toIso8601String(),
      'troubleCodes': troubleCodes.map((e) => e.toJson()).toList(),
      'liveData': liveData.map((e) => e.toJson()).toList(),
      'emissionsStatus': emissionsStatus.map((e) => e.toJson()).toList(),
      'vehicleData': vehicleData?.toMap(),
      'gptAnalysis': gptAnalysis,
      'severity': severity,
      'recommendations': recommendations,
      'rawScanData': rawScanData,
      'healthScore': healthScore,
    };
  }
}

class ScanSession {
  final String id;
  final String vehicleVin;
  final DateTime startTime;
  final DateTime? endTime;
  final String status; // 'scanning', 'completed', 'failed'
  final List<String> protocols;
  final String? errorMessage;
  final DiagnosticReport? report;

  ScanSession({
    required this.id,
    required this.vehicleVin,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.protocols,
    this.errorMessage,
    this.report,
  });

  factory ScanSession.fromJson(Map<String, dynamic> json) {
    return ScanSession(
      id: json['id'] ?? '',
      vehicleVin: json['vehicleVin'] ?? '',
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime']) 
          : null,
      status: json['status'] ?? 'scanning',
      protocols: List<String>.from(json['protocols'] ?? []),
      errorMessage: json['errorMessage'],
      report: json['report'] != null 
          ? DiagnosticReport.fromJson(json['report']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleVin': vehicleVin,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'status': status,
      'protocols': protocols,
      'errorMessage': errorMessage,
      'report': report?.toJson(),
    };
  }
} 