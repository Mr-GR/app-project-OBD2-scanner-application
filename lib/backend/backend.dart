// TODO: FIREBASE INTEGRATION
// When ready to integrate Firebase, uncomment:
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

import 'schema/users_record.dart';

export 'dart:async' show StreamSubscription;
export 'schema/util/schema_util.dart';

export 'schema/users_record.dart';

// Mock user for development
class MockUser {
  final String uid;
  final String? email;
  final String? displayName;

  MockUser({
    required this.uid,
    this.email,
    this.displayName,
  });
}

// Mock current user
MockUser? currentMockUser;

/// Functions to query UsersRecords (as a Stream and as a Future).
Future<int> queryUsersRecordCount({
  dynamic queryBuilder,
  int limit = -1,
}) async {
  // TODO: FIREBASE INTEGRATION
  // When ready to integrate Firebase, replace with:
  // return queryCollectionCount(
  //   UsersRecord.collection,
  //   queryBuilder: queryBuilder,
  //   limit: limit,
  // );

  return 1; // Mock count
}

Stream<List<UsersRecord>> queryUsersRecord({
  dynamic queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) {
  // TODO: FIREBASE INTEGRATION
  // When ready to integrate Firebase, replace with:
  // return queryCollection(
  //   UsersRecord.collection,
  //   UsersRecord.fromSnapshot,
  //   queryBuilder: queryBuilder,
  //   limit: limit,
  //   singleRecord: singleRecord,
  // );

  // Mock stream
  return Stream.value([]);
}

Future<List<UsersRecord>> queryUsersRecordOnce({
  dynamic queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) async {
  // TODO: FIREBASE INTEGRATION
  // When ready to integrate Firebase, replace with:
  // return queryCollectionOnce(
  //   UsersRecord.collection,
  //   UsersRecord.fromSnapshot,
  //   queryBuilder: queryBuilder,
  //   limit: limit,
  //   singleRecord: singleRecord,
  // );

  return []; // Mock empty list
}

Future<int> queryCollectionCount(
  dynamic collection, {
  dynamic queryBuilder,
  int limit = -1,
}) async {
  // TODO: FIREBASE INTEGRATION
  // When ready to integrate Firebase, replace with:
  // final builder = queryBuilder ?? (q) => q;
  // var query = builder(collection);
  // if (limit > 0) {
  //   query = query.limit(limit);
  // }
  // return query.count().get()
  //   .then((value) => value.count ?? 0)
  //   .catchError((err) {
  //     print('Error querying $collection: $err');
  //     return 0;
  //   });

  return 0; // Mock count
}

Stream<List<T>> queryCollection<T>(
  dynamic collection,
  dynamic recordBuilder, {
  dynamic queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) {
  // TODO: FIREBASE INTEGRATION
  // When ready to integrate Firebase, replace with:
  // final builder = queryBuilder ?? (q) => q;
  // var query = builder(collection);
  // if (limit > 0 || singleRecord) {
  //   query = query.limit(singleRecord ? 1 : limit);
  // }
  // return query.snapshots().handleError((err) {
  //   print('Error querying $collection: $err');
  // }).map((s) => s.docs
  //     .map(
  //       (d) => safeGet(
  //         () => recordBuilder(d),
  //         (e) => print('Error serializing doc ${d.reference.path}:\n$e'),
  //       ),
  //     )
  //     .where((d) => d != null)
  //     .map((d) => d!)
  //     .toList());

  return Stream.value(<T>[]); // Mock empty stream
}

Future<List<T>> queryCollectionOnce<T>(
  dynamic collection,
  dynamic recordBuilder, {
  dynamic queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) async {
  // TODO: FIREBASE INTEGRATION
  // When ready to integrate Firebase, replace with:
  // final builder = queryBuilder ?? (q) => q;
  // var query = builder(collection);
  // if (limit > 0 || singleRecord) {
  //   query = query.limit(singleRecord ? 1 : limit);
  // }
  // return query.get().then((s) => s.docs
  //     .map(
  //       (d) => safeGet(
  //         () => recordBuilder(d),
  //         (e) => print('Error serializing doc ${d.reference.path}:\n$e'),
  //       ),
  //     )
  //     .where((d) => d != null)
  //     .map((d) => d!)
  //     .toList());

  return <T>[]; // Mock empty list
}

// Mock filter functions
dynamic filterIn(String field, List? list) => null;
dynamic filterArrayContainsAny(String field, List? list) => null;

// Mock query extension
extension QueryExtension on dynamic {
  dynamic whereIn(String field, List? list) => this;
  dynamic whereNotIn(String field, List? list) => this;
  dynamic whereArrayContainsAny(String field, List? list) => this;
}

class FFFirestorePage<T> {
  final List<T> data;
  final Stream<List<T>>? dataStream;
  final dynamic nextPageMarker;

  FFFirestorePage(this.data, this.dataStream, this.nextPageMarker);
}

Future<FFFirestorePage<T>> queryCollectionPage<T>(
  dynamic collection,
  dynamic recordBuilder, {
  dynamic queryBuilder,
  dynamic nextPageMarker,
  required int pageSize,
  required bool isStream,
}) async {
  // TODO: FIREBASE INTEGRATION
  // When ready to integrate Firebase, replace with Firebase implementation

  return FFFirestorePage(<T>[], null, null); // Mock empty page
}

// Creates a Firestore document representing the logged in user if it doesn't yet exist
Future maybeCreateUser(dynamic user) async {
  // TODO: FIREBASE INTEGRATION
  // When ready to integrate Firebase, replace with:
  // final userRecord = UsersRecord.collection.doc(user.uid);
  // final userExists = await userRecord.get().then((u) => u.exists);
  // if (userExists) {
  //   currentUserDocument = await UsersRecord.getDocumentOnce(userRecord);
  //   return;
  // }

  // Mock implementation
  currentMockUser = MockUser(
    uid: 'mock_user_id',
    email: 'user@example.com',
    displayName: 'Mock User',
  );
}

// Mock current user document
dynamic currentUserDocument;

// Mock safe get function
T? safeGet<T>(T Function() getter, Function(String) onError) {
  try {
    return getter();
  } catch (e) {
    onError(e.toString());
    return null;
  }
}

// Mock record builder type
typedef RecordBuilder<T> = T Function(dynamic);

// Mock user functions
String get currentUserUid => currentMockUser?.uid ?? 'mock_user_id';
String? get currentUserEmail => currentMockUser?.email;
String? get currentUserDisplayName => currentMockUser?.displayName;
bool get isUserLoggedIn => currentMockUser != null;

// Mock user creation
Future<void> createUserRecord(dynamic user) async {
  // TODO: FIREBASE INTEGRATION
  // When ready to integrate Firebase, replace with Firebase implementation
  currentMockUser = MockUser(
    uid: user.uid ?? 'mock_user_id',
    email: user.email,
    displayName: user.displayName,
  );
}

// Mock user deletion
Future<void> deleteUserRecord(dynamic user) async {
  // TODO: FIREBASE INTEGRATION
  // When ready to integrate Firebase, replace with Firebase implementation
  currentMockUser = null;
}

// Mock user update
Future<void> updateUserRecord(dynamic user) async {
  // TODO: FIREBASE INTEGRATION
  // When ready to integrate Firebase, replace with Firebase implementation
  if (currentMockUser != null) {
    currentMockUser = MockUser(
      uid: currentMockUser!.uid,
      email: user.email ?? currentMockUser!.email,
      displayName: user.displayName ?? currentMockUser!.displayName,
    );
  }
}
