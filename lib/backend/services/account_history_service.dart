// TODO: FIREBASE INTEGRATION
// When ready to integrate Firebase, uncomment:
// import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType {
  login,
  logout,
  passwordChange,
  profileUpdate,
  vehicleAdded,
  vehicleRemoved,
  scanPerformed,
  subscriptionChanged,
  settingsUpdated,
  supportTicket,
  dataExport,
  dataImport,
}

class AccountActivity {
  final String id;
  final String userId;
  final ActivityType type;
  final String description;
  final Map<String, dynamic>? metadata;
  final String? ipAddress;
  final String? userAgent;
  final DateTime timestamp;

  AccountActivity({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    this.metadata,
    this.ipAddress,
    this.userAgent,
    required this.timestamp,
  });

  factory AccountActivity.fromMap(String id, Map<String, dynamic> data) {
    return AccountActivity(
      id: id,
      userId: data['userId'],
      type: ActivityType.values.firstWhere(
        (t) => t.toString() == 'ActivityType.${data['type']}',
        orElse: () => ActivityType.login,
      ),
      description: data['description'],
      metadata: data['metadata'],
      ipAddress: data['ipAddress'],
      userAgent: data['userAgent'],
      timestamp: DateTime.parse(data['timestamp']),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'type': type.toString().split('.').last,
    'description': description,
    'metadata': metadata,
    'ipAddress': ipAddress,
    'userAgent': userAgent,
    'timestamp': timestamp.toIso8601String(),
  };

  String get typeName {
    switch (type) {
      case ActivityType.login:
        return 'Login';
      case ActivityType.logout:
        return 'Logout';
      case ActivityType.passwordChange:
        return 'Password Changed';
      case ActivityType.profileUpdate:
        return 'Profile Updated';
      case ActivityType.vehicleAdded:
        return 'Vehicle Added';
      case ActivityType.vehicleRemoved:
        return 'Vehicle Removed';
      case ActivityType.scanPerformed:
        return 'Diagnostic Scan';
      case ActivityType.subscriptionChanged:
        return 'Subscription Changed';
      case ActivityType.settingsUpdated:
        return 'Settings Updated';
      case ActivityType.supportTicket:
        return 'Support Ticket';
      case ActivityType.dataExport:
        return 'Data Exported';
      case ActivityType.dataImport:
        return 'Data Imported';
    }
  }
}

class AccountSummary {
  final String userId;
  final DateTime accountCreated;
  final DateTime lastLogin;
  final int totalLogins;
  final int totalScans;
  final int totalVehicles;
  final int totalSupportTickets;

  AccountSummary({
    required this.userId,
    required this.accountCreated,
    required this.lastLogin,
    this.totalLogins = 0,
    this.totalScans = 0,
    this.totalVehicles = 0,
    this.totalSupportTickets = 0,
  });

  factory AccountSummary.fromMap(String userId, Map<String, dynamic> data) {
    return AccountSummary(
      userId: userId,
      accountCreated: DateTime.parse(data['accountCreated']),
      lastLogin: DateTime.parse(data['lastLogin']),
      totalLogins: data['totalLogins'] ?? 0,
      totalScans: data['totalScans'] ?? 0,
      totalVehicles: data['totalVehicles'] ?? 0,
      totalSupportTickets: data['totalSupportTickets'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'accountCreated': accountCreated.toIso8601String(),
    'lastLogin': lastLogin.toIso8601String(),
    'totalLogins': totalLogins,
    'totalScans': totalScans,
    'totalVehicles': totalVehicles,
    'totalSupportTickets': totalSupportTickets,
  };
}

abstract class IAccountHistoryService {
  Future<void> initialize();
  Future<List<AccountActivity>> getActivityHistory(String userId, {int limit = 50});
  Future<List<AccountActivity>> getActivityHistoryByType(String userId, ActivityType type, {int limit = 50});
  Future<AccountSummary> getAccountSummary(String userId);
  Future<void> logActivity(String userId, ActivityType type, String description, {Map<String, dynamic>? metadata});
  Future<void> exportActivityHistory(String userId);
  Future<void> clearActivityHistory(String userId);
  Future<List<AccountActivity>> searchActivityHistory(String userId, String query);
}

class AccountHistoryService implements IAccountHistoryService {
  // TODO: FIREBASE INTEGRATION
  // When ready to integrate Firebase, uncomment:
  // final _firestore = FirebaseFirestore.instance;

  // Mock data storage
  final List<AccountActivity> _mockActivities = [];
  final Map<String, AccountSummary> _mockSummaries = {};

  @override
  Future<void> initialize() async {
    // TODO: Implement initialization logic
  }

  @override
  Future<List<AccountActivity>> getActivityHistory(String userId, {int limit = 50}) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final query = await _firestore.collection('account_activities')
    //     .where('userId', isEqualTo: userId)
    //     .orderBy('timestamp', descending: true)
    //     .limit(limit)
    //     .get();
    // return query.docs.map((doc) => AccountActivity.fromMap(doc.id, doc.data())).toList();

    return _mockActivities
        .where((activity) => activity.userId == userId)
        .take(limit)
        .toList();
  }

  @override
  Future<List<AccountActivity>> getActivityHistoryByType(String userId, ActivityType type, {int limit = 50}) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final query = await _firestore.collection('account_activities')
    //     .where('userId', isEqualTo: userId)
    //     .where('type', isEqualTo: type.toString().split('.').last)
    //     .orderBy('timestamp', descending: true)
    //     .limit(limit)
    //     .get();
    // return query.docs.map((doc) => AccountActivity.fromMap(doc.id, doc.data())).toList();

    return _mockActivities
        .where((activity) => activity.userId == userId && activity.type == type)
        .take(limit)
        .toList();
  }

  @override
  Future<AccountSummary> getAccountSummary(String userId) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final doc = await _firestore.collection('account_summaries').doc(userId).get();
    // if (!doc.exists) {
    //   final defaultSummary = AccountSummary(
    //     userId: userId,
    //     accountCreated: DateTime.now(),
    //     lastLogin: DateTime.now(),
    //   );
    //   await _firestore.collection('account_summaries').doc(userId).set(defaultSummary.toMap());
    //   return defaultSummary;
    // }
    // return AccountSummary.fromMap(userId, doc.data()!);

    return _mockSummaries[userId] ?? AccountSummary(
      userId: userId,
      accountCreated: DateTime.now().subtract(const Duration(days: 30)),
      lastLogin: DateTime.now(),
      totalLogins: 15,
      totalScans: 8,
      totalVehicles: 2,
      totalSupportTickets: 1,
    );
  }

  @override
  Future<void> logActivity(String userId, ActivityType type, String description, {Map<String, dynamic>? metadata}) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final activity = AccountActivity(
    //   id: DateTime.now().millisecondsSinceEpoch.toString(),
    //   userId: userId,
    //   type: type,
    //   description: description,
    //   metadata: metadata,
    //   timestamp: DateTime.now(),
    // );
    // await _firestore.collection('account_activities').add(activity.toMap());
    // await _updateAccountSummary(userId, type);

    final activity = AccountActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: type,
      description: description,
      metadata: metadata,
      timestamp: DateTime.now(),
    );

    _mockActivities.add(activity);

    // Update summary
    final summary = _mockSummaries[userId] ?? AccountSummary(
      userId: userId,
      accountCreated: DateTime.now().subtract(const Duration(days: 30)),
      lastLogin: DateTime.now(),
    );

    switch (type) {
      case ActivityType.login:
        _mockSummaries[userId] = AccountSummary(
          userId: userId,
          accountCreated: summary.accountCreated,
          lastLogin: DateTime.now(),
          totalLogins: summary.totalLogins + 1,
          totalScans: summary.totalScans,
          totalVehicles: summary.totalVehicles,
          totalSupportTickets: summary.totalSupportTickets,
        );
        break;
      case ActivityType.scanPerformed:
        _mockSummaries[userId] = AccountSummary(
          userId: userId,
          accountCreated: summary.accountCreated,
          lastLogin: summary.lastLogin,
          totalLogins: summary.totalLogins,
          totalScans: summary.totalScans + 1,
          totalVehicles: summary.totalVehicles,
          totalSupportTickets: summary.totalSupportTickets,
        );
        break;
      case ActivityType.vehicleAdded:
        _mockSummaries[userId] = AccountSummary(
          userId: userId,
          accountCreated: summary.accountCreated,
          lastLogin: summary.lastLogin,
          totalLogins: summary.totalLogins,
          totalScans: summary.totalScans,
          totalVehicles: summary.totalVehicles + 1,
          totalSupportTickets: summary.totalSupportTickets,
        );
        break;
      case ActivityType.vehicleRemoved:
        _mockSummaries[userId] = AccountSummary(
          userId: userId,
          accountCreated: summary.accountCreated,
          lastLogin: summary.lastLogin,
          totalLogins: summary.totalLogins,
          totalScans: summary.totalScans,
          totalVehicles: summary.totalVehicles - 1,
          totalSupportTickets: summary.totalSupportTickets,
        );
        break;
      case ActivityType.supportTicket:
        _mockSummaries[userId] = AccountSummary(
          userId: userId,
          accountCreated: summary.accountCreated,
          lastLogin: summary.lastLogin,
          totalLogins: summary.totalLogins,
          totalScans: summary.totalScans,
          totalVehicles: summary.totalVehicles,
          totalSupportTickets: summary.totalSupportTickets + 1,
        );
        break;
      default:
        break;
    }
  }

  @override
  Future<void> exportActivityHistory(String userId) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final activities = await getActivityHistory(userId, limit: 1000);
    // final exportData = {
    //   'userId': userId,
    //   'exportDate': DateTime.now().toIso8601String(),
    //   'activities': activities.map((activity) => activity.toMap()).toList(),
    // };
    // await _firestore.collection('data_exports').add(exportData);

    print('Mock export - no Firebase integration yet');
  }

  @override
  Future<void> clearActivityHistory(String userId) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final activities = await _firestore.collection('account_activities')
    //     .where('userId', isEqualTo: userId)
    //     .get();
    // final batch = _firestore.batch();
    // for (final doc in activities.docs) {
    //   batch.delete(doc.reference);
    // }
    // await batch.commit();

    _mockActivities.removeWhere((activity) => activity.userId == userId);
  }

  @override
  Future<List<AccountActivity>> searchActivityHistory(String userId, String query) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final activities = await getActivityHistory(userId, limit: 1000);
    // return activities.where((activity) => 
    //   activity.description.toLowerCase().contains(query.toLowerCase()) ||
    //   activity.typeName.toLowerCase().contains(query.toLowerCase())
    // ).toList();

    final activities = await getActivityHistory(userId, limit: 1000);
    return activities.where((activity) => 
      activity.description.toLowerCase().contains(query.toLowerCase()) ||
      activity.typeName.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}

class MockAccountHistoryService implements IAccountHistoryService {
  final List<AccountActivity> _mockActivities = [];
  final Map<String, AccountSummary> _mockSummaries = {};

  @override
  Future<void> initialize() async {
    // TODO: Implement initialization logic
  }

  @override
  Future<List<AccountActivity>> getActivityHistory(String userId, {int limit = 50}) async {
    return _mockActivities
        .where((activity) => activity.userId == userId)
        .take(limit)
        .toList();
  }

  @override
  Future<List<AccountActivity>> getActivityHistoryByType(String userId, ActivityType type, {int limit = 50}) async {
    return _mockActivities
        .where((activity) => activity.userId == userId && activity.type == type)
        .take(limit)
        .toList();
  }

  @override
  Future<AccountSummary> getAccountSummary(String userId) async {
    return _mockSummaries[userId] ?? AccountSummary(
      userId: userId,
      accountCreated: DateTime.now().subtract(const Duration(days: 30)),
      lastLogin: DateTime.now(),
      totalLogins: 15,
      totalScans: 8,
      totalVehicles: 2,
      totalSupportTickets: 1,
    );
  }

  @override
  Future<void> logActivity(String userId, ActivityType type, String description, {Map<String, dynamic>? metadata}) async {
    final activity = AccountActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: type,
      description: description,
      metadata: metadata,
      timestamp: DateTime.now(),
    );

    _mockActivities.add(activity);

    // Update summary
    final summary = _mockSummaries[userId] ?? AccountSummary(
      userId: userId,
      accountCreated: DateTime.now().subtract(const Duration(days: 30)),
      lastLogin: DateTime.now(),
    );

    switch (type) {
      case ActivityType.login:
        _mockSummaries[userId] = AccountSummary(
          userId: userId,
          accountCreated: summary.accountCreated,
          lastLogin: DateTime.now(),
          totalLogins: summary.totalLogins + 1,
          totalScans: summary.totalScans,
          totalVehicles: summary.totalVehicles,
          totalSupportTickets: summary.totalSupportTickets,
        );
        break;
      case ActivityType.scanPerformed:
        _mockSummaries[userId] = AccountSummary(
          userId: userId,
          accountCreated: summary.accountCreated,
          lastLogin: summary.lastLogin,
          totalLogins: summary.totalLogins,
          totalScans: summary.totalScans + 1,
          totalVehicles: summary.totalVehicles,
          totalSupportTickets: summary.totalSupportTickets,
        );
        break;
      default:
        break;
    }
  }

  @override
  Future<void> exportActivityHistory(String userId) async {
    // Mock export
    print('Exporting activity history for user: $userId');
  }

  @override
  Future<void> clearActivityHistory(String userId) async {
    _mockActivities.removeWhere((activity) => activity.userId == userId);
  }

  @override
  Future<List<AccountActivity>> searchActivityHistory(String userId, String query) async {
    return _mockActivities.where((activity) => 
      activity.userId == userId &&
      (activity.description.toLowerCase().contains(query.toLowerCase()) ||
       activity.typeName.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }
} 