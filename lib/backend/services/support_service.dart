// TODO: FIREBASE INTEGRATION
// When ready to integrate Firebase, uncomment:
// import 'package:cloud_firestore/cloud_firestore.dart';

class SupportTicket {
  final String id;
  final String uid;
  final String type; // 'bug', 'feedback', 'support'
  final String message;
  final DateTime createdAt;

  SupportTicket({
    required this.id,
    required this.uid,
    required this.type,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'type': type,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SupportTicket.fromMap(String id, Map<String, dynamic> data) {
    return SupportTicket(
      id: id,
      uid: data['uid'],
      type: data['type'],
      message: data['message'],
      createdAt: DateTime.parse(data['createdAt']),
    );
  }
}

abstract class ISupportService {
  Future<void> initialize();
  Future<void> submitTicket(String uid, String type, String message);
  Future<List<SupportTicket>> getTickets(String uid);
}

class SupportService implements ISupportService {
  // TODO: FIREBASE INTEGRATION
  // When ready to integrate Firebase, uncomment:
  // final _firestore = FirebaseFirestore.instance;

  // Mock data storage
  final List<SupportTicket> _mockTickets = [];

  @override
  Future<void> initialize() async {
    // Implementation needed
  }

  @override
  Future<void> submitTicket(String uid, String type, String message) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // await _firestore.collection('support_tickets').add({
    //   'uid': uid,
    //   'type': type,
    //   'message': message,
    //   'createdAt': DateTime.now().toIso8601String(),
    // });

    _mockTickets.add(SupportTicket(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      uid: uid,
      type: type,
      message: message,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<List<SupportTicket>> getTickets(String uid) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final query = await _firestore.collection('support_tickets').where('uid', isEqualTo: uid).get();
    // return query.docs.map((doc) => SupportTicket.fromMap(doc.id, doc.data())).toList();

    return _mockTickets.where((t) => t.uid == uid).toList();
  }
}

class MockSupportService implements ISupportService {
  final List<SupportTicket> _mockTickets = [];

  @override
  Future<void> initialize() async {
    // Implementation needed
  }

  @override
  Future<void> submitTicket(String uid, String type, String message) async {
    _mockTickets.add(SupportTicket(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      uid: uid,
      type: type,
      message: message,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<List<SupportTicket>> getTickets(String uid) async {
    return _mockTickets.where((t) => t.uid == uid).toList();
  }
} 