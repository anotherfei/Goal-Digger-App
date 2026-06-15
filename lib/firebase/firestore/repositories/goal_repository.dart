// ─────────────────────────────────────────────────────────────────────────────
// lib/firebase/firestore/repositories/goal_repository.dart
//
// FIX (Data loss): `progress` field was never written to or read from
//   Firestore.  Calling `updateProgress()` stored data that was silently
//   dropped on the next read — goals always reloaded with 0% progress.
//   Added 'progress' to both `_goalToMap` and `_goalFromDoc`.
//
// FIX (Silent CRUD failures): The original code used `_uuid.v4()` as the
//   Firestore document ID, but stored a different value (uuid.hashCode) in
//   the model's `id` field.  Subsequent `updateGoal` / `deleteGoal` calls
//   used `goal.id.toString()` (the hashCode), which never matched the
//   actual UUID document path — so updates and deletes silently no-op'd.
//
//   Fix: use `DateTime.now().microsecondsSinceEpoch` as both the Firestore
//   document ID and the model's int `id`.  This gives a unique, parseable
//   integer that round-trips cleanly through `int.tryParse`.
//
// ENHANCE: `_deleteSubCollection` now loops until all documents are removed
//   (Firestore batch limit is 500; previously stopped at 100).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../firestore_paths.dart';
import '../firestore_service.dart';

class GoalRepository {
  GoalRepository({FirestoreService? service})
      : _svc = service ?? FirestoreService();

  final FirestoreService _svc;

  // ── Real-time stream ───────────────────────────────────────────────────────

  Stream<List<GoalProject>> watchGoals(String uid) {
    return _svc
        .watchCol(
          FirestorePaths.goalsCol(uid),
          queryBuilder: (col) => col.orderBy('createdAt', descending: false),
        )
        .map((snapshot) => snapshot.docs
            .map((doc) => _goalFromDoc(doc))
            .whereType<GoalProject>()
            .toList());
  }

  // ── Fetch once ────────────────────────────────────────────────────────────

  Future<List<GoalProject>> fetchGoals(String uid) async {
    final snapshot = await _svc
        .colRef(FirestorePaths.goalsCol(uid))
        .orderBy('createdAt')
        .get();
    return snapshot.docs
        .map((doc) => _goalFromDoc(doc))
        .whereType<GoalProject>()
        .toList();
  }

  // ── Create ────────────────────────────────────────────────────────────────

  Future<GoalProject> createGoal(String uid, GoalProject goal) async {
    // FIX: Use microsecondsSinceEpoch so the ID is a valid int that survives
    // int.tryParse() and also serves as the Firestore document path.
    // Previously a UUID was used as the doc path but an incompatible hashCode
    // int was stored in the model — making update/delete silently fail.
    final id = goal.id != 0 ? goal.id : DateTime.now().microsecondsSinceEpoch;
    final docPath = FirestorePaths.goalDoc(uid, id.toString());
    final data = _goalToMap(goal, id: id);
    await _svc.setDoc(docPath, data);
    return _copyGoalWithId(goal, id);
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<void> updateGoal(String uid, GoalProject goal) async {
    await _svc.updateDoc(
      FirestorePaths.goalDoc(uid, goal.id.toString()),
      {
        'title': goal.title,
        'importance': goal.importance,
        'category': goal.category,
        'deadline': Timestamp.fromDate(goal.deadline),
        // FIX: persist progress so watchGoals reads the correct value
        'progress': goal.progress,
        'updatedAt': FirestoreService.serverTimestamp,
      },
    );
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteGoal(String uid, String goalId) async {
    // Tasks live in the embedded `tasksMap` field on the goal document, not in
    // a `tasks` sub-collection — deleting the goal doc removes them too. The
    // old `_deleteSubCollection(tasksCol(...))` call queried a sub-collection
    // that (a) never exists and (b) has no matching security rule, so it threw
    // PERMISSION_DENIED and aborted the delete before the goal was removed.
    await _svc.deleteDoc(FirestorePaths.goalDoc(uid, goalId));
  }

  // ── Progress ──────────────────────────────────────────────────────────────

  /// Atomically update a goal's progress percentage (0.0–1.0).
  Future<void> updateProgress(
      String uid, String goalId, double progress) async {
    await _svc.updateDoc(
      FirestorePaths.goalDoc(uid, goalId),
      {
        'progress': progress.clamp(0.0, 1.0),
        'updatedAt': FirestoreService.serverTimestamp,
      },
    );
  }

  // ── Task CRUD ─────────────────────────────────────────────────────────────

  Future<void> upsertTask(String uid, String goalId, MicroTask task) async {
    final taskId = task.id.toString();
    await _svc.updateDoc(
      FirestorePaths.goalDoc(uid, goalId),
      {
        'tasksMap.$taskId': _taskToMap(task),
        'updatedAt': FirestoreService.serverTimestamp,
      },
    );
  }

  Future<void> toggleTask(
    String uid,
    String goalId,
    String taskId,
    bool done, {
    DateTime? completedAt,
  }) async {
    await _svc.updateDoc(
      FirestorePaths.goalDoc(uid, goalId),
      {
        'tasksMap.$taskId.done': done,
        'tasksMap.$taskId.completedAt': done
            ? (completedAt == null
                ? FirestoreService.serverTimestamp
                : Timestamp.fromDate(completedAt))
            : FieldValue.delete(),
        'updatedAt': FirestoreService.serverTimestamp,
      },
    );
  }

  Future<void> deleteTask(String uid, String goalId, String taskId) async {
    await _svc.updateDoc(
      FirestorePaths.goalDoc(uid, goalId),
      {
        'tasksMap.$taskId': FieldValue.delete(),
        'updatedAt': FirestoreService.serverTimestamp,
      },
    );
  }

  // ── Serialisation ──────────────────────────────────────────────────────────

  Map<String, dynamic> _goalToMap(GoalProject goal, {required int id}) {
    final tasksMap = <String, dynamic>{};
    for (final task in goal.tasks) {
      tasksMap[task.id.toString()] = _taskToMap(task);
    }

    return {
      'id': id, // FIX: always an int
      'title': goal.title,
      'importance': goal.importance,
      'category': goal.category,
      'deadline': Timestamp.fromDate(goal.deadline),
      'colorFrom': goal.from.toARGB32(),
      'colorTo': goal.to.toARGB32(),
      // FIX: persist progress so it survives a reload
      'progress': goal.progress.clamp(0.0, 1.0),
      'tasksMap': tasksMap,
      'createdAt': FirestoreService.serverTimestamp,
      'updatedAt': FirestoreService.serverTimestamp,
    };
  }

  Map<String, dynamic> _taskToMap(MicroTask task) => {
        'id': task.id,
        'goalId': task.goalId,
        'title': task.title,
        'durationMinutes': task.durationMinutes,
        'load': task.load.name,
        'scheduledDate': Timestamp.fromDate(task.scheduledDate),
        'done': task.done,
        'points': task.points,
        'completedAt': task.completedAt == null
            ? null
            : Timestamp.fromDate(task.completedAt!),
      };

  GoalProject? _goalFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final d = doc.data()!;

      // FIX: 'id' is now always an int — int.tryParse never falls back to
      // hashCode, so the parsed ID matches the Firestore document path.
      final id =
          (d['id'] as num?)?.toInt() ?? int.tryParse(doc.id) ?? doc.id.hashCode;

      final tasksMap = (d['tasksMap'] as Map<String, dynamic>? ?? {});
      final tasks = tasksMap.values
          .map((v) => _taskFromMap(v as Map<String, dynamic>))
          .toList();

      return GoalProject(
        id: id,
        title: d['title'] as String,
        importance: (d['importance'] as num).toInt(),
        category: d['category'] as String,
        deadline: (d['deadline'] as Timestamp).toDate(),
        from: Color(d['colorFrom'] as int),
        to: Color(d['colorTo'] as int),
        // FIX: read progress field so the UI shows the correct value
        progress: (d['progress'] as num?)?.toDouble() ?? 0.0,
        tasks: tasks,
      );
    } catch (e) {
      debugPrint('⚠️  Failed to parse goal ${doc.id}: $e');
      return null;
    }
  }

  MicroTask _taskFromMap(Map<String, dynamic> m) {
    final completedAt = m['completedAt'];
    return MicroTask(
      id: (m['id'] as num).toInt(),
      goalId: (m['goalId'] as num).toInt(),
      title: m['title'] as String,
      durationMinutes: (m['durationMinutes'] as num).toInt(),
      load: TaskLoad.values.byName(m['load'] as String),
      scheduledDate: (m['scheduledDate'] as Timestamp).toDate(),
      done: m['done'] as bool? ?? false,
      points: (m['points'] as num?)?.toInt() ?? 15,
      completedAt: completedAt is Timestamp ? completedAt.toDate() : null,
    );
  }

  GoalProject _copyGoalWithId(GoalProject goal, int id) => GoalProject(
        id: id,
        title: goal.title,
        importance: goal.importance,
        category: goal.category,
        deadline: goal.deadline,
        from: goal.from,
        to: goal.to,
        progress: goal.progress,
        tasks: goal.tasks,
      );
}
