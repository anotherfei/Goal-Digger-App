// ─────────────────────────────────────────────────────────────────────────────
// lib/firebase/firestore/firestore_service.dart
//
// Generic Firestore helpers shared by every repository.
// Repositories extend or compose this class.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  FirebaseFirestore get db => _db;

  // ── Document helpers ─────────────────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> docRef(String path) =>
      _db.doc(path);

  CollectionReference<Map<String, dynamic>> colRef(String path) =>
      _db.collection(path);

  /// Set (create or overwrite) a document.
  Future<void> setDoc(
    String path,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    await _db.doc(path).set(data, SetOptions(merge: merge));
    debugPrint('📝 Firestore set: $path');
  }

  /// Update specific fields in a document.
  Future<void> updateDoc(String path, Map<String, dynamic> data) async {
    await _db.doc(path).update(data);
    debugPrint('✏️  Firestore update: $path');
  }

  /// Delete a document.
  Future<void> deleteDoc(String path) async {
    await _db.doc(path).delete();
    debugPrint('🗑️  Firestore delete: $path');
  }

  /// Fetch a document once.
  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc(String path) =>
      _db.doc(path).get();

  /// Watch a document in real-time.
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDoc(String path) =>
      _db.doc(path).snapshots();

  /// Watch a collection in real-time.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchCol(
    String path, {
    Query<Map<String, dynamic>> Function(
            CollectionReference<Map<String, dynamic>>)?
        queryBuilder,
  }) {
    final col = _db.collection(path);
    final query = queryBuilder != null ? queryBuilder(col) : col;
    return query.snapshots();
  }

  /// Batch write helper.
  WriteBatch get batch => _db.batch();

  /// Run a transaction.
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction txn) action,
  ) =>
      _db.runTransaction(action);

  /// Server timestamp sentinel.
  static FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  /// Array union sentinel.
  static FieldValue arrayUnion(List<dynamic> elements) =>
      FieldValue.arrayUnion(elements);

  /// Array remove sentinel.
  static FieldValue arrayRemove(List<dynamic> elements) =>
      FieldValue.arrayRemove(elements);

  /// Atomic increment sentinel.
  static FieldValue increment(num value) => FieldValue.increment(value);
}
