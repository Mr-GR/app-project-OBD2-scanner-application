import 'package:o_b_d2_scanner_frontend/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

// TODO: FIREBASE INTEGRATION
// When ready to integrate Firebase, uncomment:
// import 'package:cloud_firestore/cloud_firestore.dart';

class UsersRecord {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool? emailVerified;
  final DateTime? createdTime;
  final DateTime? lastSignInTime;
  final String? role;
  final Map<String, dynamic>? settings;

  UsersRecord({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.emailVerified,
    this.createdTime,
    this.lastSignInTime,
    this.role,
    this.settings,
  });

  static CollectionReference get collection =>
      // TODO: FIREBASE INTEGRATION
      // When ready to integrate Firebase, replace with:
      // FirebaseFirestore.instance.collection('users');
      MockFirebaseFirestore.instance.collection('users');

  static Future<UsersRecord?> getDocumentOnce(String uid) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final ref = collection.doc(uid);
    // final doc = await ref.get();
    // if (!doc.exists) return null;
    // return UsersRecord.fromMap(uid, doc.data()!);

    // Mock implementation
    return null;
  }

  static Future<List<UsersRecord>> query({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // Query query = collection;
    // if (queryBuilder != null) {
    //   query = queryBuilder(query);
    // }
    // if (limit > 0 || singleRecord) {
    //   query = query.limit(singleRecord ? 1 : limit);
    // }
    // final querySnapshot = await query.get();
    // return querySnapshot.docs.map((doc) => UsersRecord.fromMap(doc.id, doc.data())).toList();

    // Mock implementation
    return [];
  }

  static Query queryBuilder(Query query) {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // return query;

    // Mock implementation
    return query;
  }

  static Future<Stream<List<UsersRecord>>> queryStream({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // Query query = collection;
    // if (queryBuilder != null) {
    //   query = queryBuilder(query);
    // }
    // if (limit > 0 || singleRecord) {
    //   query = query.limit(singleRecord ? 1 : limit);
    // }
    // return query.snapshots().map((snapshot) => snapshot.docs.map((doc) => UsersRecord.fromMap(doc.id, doc.data())).toList());

    // Mock implementation
    return Stream.value([]);
  }

  static Future<UsersRecord?> getDocumentFromData(
    Map<String, dynamic> data,
    String uid,
  ) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // return UsersRecord.fromMap(uid, data);

    // Mock implementation
    return null;
  }

  static UsersRecord fromMap(String uid, Map<String, dynamic> data) =>
      UsersRecord(
        uid: uid,
        email: data['email'] as String?,
        displayName: data['displayName'] as String?,
        photoUrl: data['photoUrl'] as String?,
        phoneNumber: data['phoneNumber'] as String?,
        emailVerified: data['emailVerified'] as bool?,
        createdTime: data['createdTime'] as DateTime?,
        lastSignInTime: data['lastSignInTime'] as DateTime?,
        role: data['role'] as String?,
        settings: data['settings'] as Map<String, dynamic>?,
      );

  static Future<UsersRecord?> getDocument(String uid) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final ref = collection.doc(uid);
    // final doc = await ref.get();
    // if (!doc.exists) return null;
    // return UsersRecord.fromMap(uid, doc.data()!);

    // Mock implementation
    return null;
  }

  static Future<void> deleteDocument(String uid) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final ref = collection.doc(uid);
    // await ref.delete();

    // Mock implementation
  }

  static Future<DocumentReference> createDocument(UsersRecord data) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final ref = collection.doc();
    // await ref.set(data.toMap());
    // return ref;

    // Mock implementation
    return MockDocumentReference(
        'users/${DateTime.now().millisecondsSinceEpoch}');
  }

  static Future<void> updateDocument(UsersRecord data) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final ref = collection.doc(data.uid);
    // await ref.update(data.toMap());

    // Mock implementation
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'phoneNumber': phoneNumber,
        'emailVerified': emailVerified,
        'createdTime': createdTime?.toIso8601String(),
        'lastSignInTime': lastSignInTime?.toIso8601String(),
        'role': role,
        'settings': settings,
      };

  UsersRecord copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool? emailVerified,
    DateTime? createdTime,
    DateTime? lastSignInTime,
    String? role,
    Map<String, dynamic>? settings,
  }) =>
      UsersRecord(
        uid: uid ?? this.uid,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        emailVerified: emailVerified ?? this.emailVerified,
        createdTime: createdTime ?? this.createdTime,
        lastSignInTime: lastSignInTime ?? this.lastSignInTime,
        role: role ?? this.role,
        settings: settings ?? this.settings,
      );

  // Additional getters for compatibility
  String get shortDescription => displayName ?? email ?? uid;
  DateTime? get lastActiveTime => lastSignInTime;
  String get title => displayName ?? email ?? 'User';
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  String? shortDescription,
  DateTime? lastActiveTime,
  String? role,
  String? title,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'shortDescription': shortDescription,
      'last_active_time': lastActiveTime,
      'role': role,
      'title': title,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality {
  const UsersRecordDocumentEquality();

  bool equals(UsersRecord? e1, UsersRecord? e2) {
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.shortDescription == e2?.shortDescription &&
        e1?.lastActiveTime == e2?.lastActiveTime &&
        e1?.role == e2?.role &&
        e1?.title == e2?.title;
  }

  int hash(UsersRecord? e) => Object.hash(
      e?.email,
      e?.displayName,
      e?.photoUrl,
      e?.uid,
      e?.createdTime,
      e?.phoneNumber,
      e?.shortDescription,
      e?.lastActiveTime,
      e?.role,
      e?.title);

  bool isValidKey(Object? o) => o is UsersRecord;
}
