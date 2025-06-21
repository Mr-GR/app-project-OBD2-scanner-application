class VehicleRecord {
  final String? reference;
  final String vin;
  final String make;
  final String model;
  final String year;
  final String ownerId;
  final String? nickname;
  final String? color;
  final String? licensePlate;
  final String? mileage;
  final DateTime? lastScanDate;
  final List<dynamic>? scanHistory;
  final List<dynamic>? chatHistory;
  final DateTime? createdTime;
  final DateTime? updatedTime;

  VehicleRecord({
    this.reference,
    required this.vin,
    required this.make,
    required this.model,
    required this.year,
    required this.ownerId,
    this.nickname,
    this.color,
    this.licensePlate,
    this.mileage,
    this.lastScanDate,
    this.scanHistory,
    this.chatHistory,
    this.createdTime,
    this.updatedTime,
  });

  Map<String, dynamic> toData() {
    return {
      'vin': vin,
      'make': make,
      'model': model,
      'year': year,
      'ownerId': ownerId,
      'nickname': nickname,
      'color': color,
      'licensePlate': licensePlate,
      'mileage': mileage,
      'lastScanDate': lastScanDate,
      'scanHistory': scanHistory,
      'chatHistory': chatHistory,
      'createdTime': createdTime,
      'updatedTime': updatedTime,
    };
  }

  VehicleRecord copyWith({
    String? reference,
    String? vin,
    String? make,
    String? model,
    String? year,
    String? ownerId,
    String? nickname,
    String? color,
    String? licensePlate,
    String? mileage,
    DateTime? lastScanDate,
    List<dynamic>? scanHistory,
    List<dynamic>? chatHistory,
    DateTime? createdTime,
    DateTime? updatedTime,
  }) =>
      VehicleRecord(
        reference: reference ?? this.reference,
        vin: vin ?? this.vin,
        make: make ?? this.make,
        model: model ?? this.model,
        year: year ?? this.year,
        ownerId: ownerId ?? this.ownerId,
        nickname: nickname ?? this.nickname,
        color: color ?? this.color,
        licensePlate: licensePlate ?? this.licensePlate,
        mileage: mileage ?? this.mileage,
        lastScanDate: lastScanDate ?? this.lastScanDate,
        scanHistory: scanHistory ?? this.scanHistory,
        chatHistory: chatHistory ?? this.chatHistory,
        createdTime: createdTime ?? this.createdTime,
        updatedTime: updatedTime ?? this.updatedTime,
      );
}

Map<String, dynamic> createVehicleRecordData({
  String? vin,
  String? make,
  String? model,
  String? year,
  String? ownerId,
  String? nickname,
  String? color,
  String? licensePlate,
  String? mileage,
  DateTime? lastScanDate,
  List<dynamic>? scanHistory,
  List<dynamic>? chatHistory,
  DateTime? createdTime,
  DateTime? updatedTime,
}) {
  return {
    'vin': vin,
    'make': make,
    'model': model,
    'year': year,
    'ownerId': ownerId,
    'nickname': nickname,
    'color': color,
    'licensePlate': licensePlate,
    'mileage': mileage,
    'lastScanDate': lastScanDate,
    'scanHistory': scanHistory,
    'chatHistory': chatHistory,
    'createdTime': createdTime,
    'updatedTime': updatedTime,
  };
} 