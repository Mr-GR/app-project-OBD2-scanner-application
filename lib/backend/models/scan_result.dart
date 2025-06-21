class ScanResult {
  final String id;
  final String vehicleVin;
  final DateTime scanDate;
  final String scanType; // 'manual' or 'bluetooth'
  final Map<String, dynamic> diagnosticData;
  final List<String> errorCodes;
  final String? notes;
  final Map<String, dynamic>? rawData;

  ScanResult({
    required this.id,
    required this.vehicleVin,
    required this.scanDate,
    required this.scanType,
    required this.diagnosticData,
    required this.errorCodes,
    this.notes,
    this.rawData,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicleVin': vehicleVin,
    'scanDate': scanDate.toIso8601String(),
    'scanType': scanType,
    'diagnosticData': diagnosticData,
    'errorCodes': errorCodes,
    'notes': notes,
    'rawData': rawData,
  };

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
    id: json['id'] ?? '',
    vehicleVin: json['vehicleVin'] ?? '',
    scanDate: DateTime.parse(json['scanDate']),
    scanType: json['scanType'] ?? '',
    diagnosticData: Map<String, dynamic>.from(json['diagnosticData'] ?? {}),
    errorCodes: List<String>.from(json['errorCodes'] ?? []),
    notes: json['notes'],
    rawData: json['rawData'] != null 
        ? Map<String, dynamic>.from(json['rawData']) 
        : null,
  );

  ScanResult copyWith({
    String? id,
    String? vehicleVin,
    DateTime? scanDate,
    String? scanType,
    Map<String, dynamic>? diagnosticData,
    List<String>? errorCodes,
    String? notes,
    Map<String, dynamic>? rawData,
  }) =>
      ScanResult(
        id: id ?? this.id,
        vehicleVin: vehicleVin ?? this.vehicleVin,
        scanDate: scanDate ?? this.scanDate,
        scanType: scanType ?? this.scanType,
        diagnosticData: diagnosticData ?? this.diagnosticData,
        errorCodes: errorCodes ?? this.errorCodes,
        notes: notes ?? this.notes,
        rawData: rawData ?? this.rawData,
      );
} 