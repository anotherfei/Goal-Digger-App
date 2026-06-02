// ─────────────────────────────────────────────────────────────────────────────
// lib/firebase/firestore/repositories/routine_repository.dart
//
// Persists calendar routines in Firestore so routines are not reset when the
// app reloads or when the user signs in on another device.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../models/models.dart';
import '../firestore_paths.dart';
import '../firestore_service.dart';

class RoutineRepository {
  RoutineRepository({FirestoreService? service})
      : _svc = service ?? FirestoreService();

  final FirestoreService _svc;

  Stream<List<RoutineItem>> watchRoutines(String uid) {
    return _svc
        .watchCol(
          FirestorePaths.routinesCol(uid),
          queryBuilder: (col) => col.orderBy('startsAt'),
        )
        .map((snapshot) => snapshot.docs
            .map((doc) => _routineFromDoc(doc))
            .whereType<RoutineItem>()
            .toList());
  }

  Future<List<RoutineItem>> fetchRoutines(String uid) async {
    final snapshot = await _svc
        .colRef(FirestorePaths.routinesCol(uid))
        .orderBy('startsAt')
        .get();
    return snapshot.docs
        .map((doc) => _routineFromDoc(doc))
        .whereType<RoutineItem>()
        .toList();
  }

  Future<RoutineItem> createRoutine(String uid, RoutineItem routine) async {
    final id = routine.id;
    await _svc.setDoc(
      FirestorePaths.routineDoc(uid, id),
      _routineToMap(routine, id: id),
    );
    return RoutineItem(
      id: id,
      title: routine.title,
      startsAt: routine.startsAt,
      repeat: routine.repeat,
    );
  }

  Future<void> deleteRoutine(String uid, String routineId) async {
    await _svc.deleteDoc(FirestorePaths.routineDoc(uid, routineId));
  }

  Map<String, dynamic> _routineToMap(RoutineItem routine, {required String id}) {
    return {
      'id': id,
      'title': routine.title,
      'startsAt': Timestamp.fromDate(routine.startsAt),
      'repeat': routine.repeat.name,
      'createdAt': FirestoreService.serverTimestamp,
      'updatedAt': FirestoreService.serverTimestamp,
    };
  }

  RoutineItem? _routineFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final d = doc.data()!;
      return RoutineItem(
        id: d['id'] as String? ?? doc.id,
        title: d['title'] as String? ?? 'Routine',
        startsAt: (d['startsAt'] as Timestamp).toDate(),
        repeat: RoutineRepeat.values.byName(
          d['repeat'] as String? ?? RoutineRepeat.daily.name,
        ),
      );
    } catch (e) {
      debugPrint('⚠️  Failed to parse routine ${doc.id}: $e');
      return null;
    }
  }
}
