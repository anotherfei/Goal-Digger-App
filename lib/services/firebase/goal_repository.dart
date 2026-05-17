/// goal_repository.dart
/// ---------------------
/// Firestore CRUD operations for [GoalProject] and its [MicroTask] sub-collection.
///
/// Firestore path layout:
///   users/{uid}/goals/{goalId}
///   users/{uid}/goals/{goalId}/tasks/{taskId}
///
/// Folder: lib/services/firebase/

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/models.dart';
import 'firebase_config.dart';
import 'firebase_models.dart';

class GoalRepository {
  GoalRepository({String? uid}) : _uid = uid ?? currentUid ?? 'anonymous';

  final String _uid;

  // ── Collection references ──────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _goalsRef =>
      firestore.collection('users').doc(_uid).collection('goals');

  CollectionReference<Map<String, dynamic>> _tasksRef(String goalDocId) =>
      _goalsRef.doc(goalDocId).collection('tasks');

  // Helper: use the numeric goalId as the Firestore document ID.
  String _goalDocId(int goalId) => goalId.toString();

  // ── Real-time streams ─────────────────────────────────────────────────────

  /// Streams all goals (with their tasks) for the current user.
  /// Emits a new list whenever any goal or task changes.
  Stream<List<GoalProject>> watchGoals() async* {
    await for (final snapshot in _goalsRef
        .orderBy('deadline')
        .snapshots()) {
      final goals = <GoalProject>[];
      for (final doc in snapshot.docs) {
        final tasks = await _fetchTasks(doc.id);
        goals.add(GoalProjectFirestore.fromFirestore(doc, tasks: tasks));
      }
      yield goals;
    }
  }

  /// Streams a single goal (without tasks — use [watchGoalWithTasks] for that).
  Stream<GoalProject?> watchGoal(int goalId) {
    return _goalsRef.doc(_goalDocId(goalId)).snapshots().map((doc) {
      if (!doc.exists) return null;
      return GoalProjectFirestore.fromFirestore(doc);
    });
  }

  /// Streams a single goal together with its live tasks sub-collection.
  Stream<GoalProject?> watchGoalWithTasks(int goalId) async* {
    final goalDoc = _goalsRef.doc(_goalDocId(goalId));
    await for (final snapshot in goalDoc.snapshots()) {
      if (!snapshot.exists) {
        yield null;
        continue;
      }
      final tasks = await _fetchTasks(snapshot.id);
      yield GoalProjectFirestore.fromFirestore(snapshot, tasks: tasks);
    }
  }

  // ── One-shot reads ────────────────────────────────────────────────────────

  Future<List<GoalProject>> fetchAllGoals() async {
    final snapshot = await _goalsRef.orderBy('deadline').get();
    final goals = <GoalProject>[];
    for (final doc in snapshot.docs) {
      final tasks = await _fetchTasks(doc.id);
      goals.add(GoalProjectFirestore.fromFirestore(doc, tasks: tasks));
    }
    return goals;
  }

  Future<GoalProject?> fetchGoal(int goalId) async {
    final doc = await _goalsRef.doc(_goalDocId(goalId)).get();
    if (!doc.exists) return null;
    final tasks = await _fetchTasks(doc.id);
    return GoalProjectFirestore.fromFirestore(doc, tasks: tasks);
  }

  // ── Write operations ──────────────────────────────────────────────────────

  /// Creates or overwrites a goal document. Tasks are written individually.
  Future<void> saveGoal(GoalProject goal) async {
    final batch = firestore.batch();

    final goalRef = _goalsRef.doc(_goalDocId(goal.id));
    batch.set(goalRef, goal.toFirestore());

    for (final task in goal.tasks) {
      final taskRef = _tasksRef(_goalDocId(goal.id)).doc(task.id.toString());
      batch.set(taskRef, task.toFirestore());
    }

    await batch.commit();
  }

  /// Updates only the provided fields on an existing goal document.
  Future<void> updateGoalFields(
    int goalId,
    Map<String, dynamic> fields,
  ) async {
    await _goalsRef.doc(_goalDocId(goalId)).update({
      ...fields,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes a goal and all its tasks (cascade delete via batch).
  Future<void> deleteGoal(int goalId) async {
    final goalDocId = _goalDocId(goalId);
    final tasksDocs = await _tasksRef(goalDocId).get();

    final batch = firestore.batch();
    for (final doc in tasksDocs.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_goalsRef.doc(goalDocId));
    await batch.commit();
  }

  // ── Task operations ───────────────────────────────────────────────────────

  Future<void> saveTask(MicroTask task) async {
    await _tasksRef(_goalDocId(task.goalId))
        .doc(task.id.toString())
        .set(task.toFirestore());
  }

  Future<void> markTaskDone(int goalId, int taskId, {required bool done}) async {
    await _tasksRef(_goalDocId(goalId)).doc(taskId.toString()).update({
      'done': done,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTask(int goalId, int taskId) async {
    await _tasksRef(_goalDocId(goalId)).doc(taskId.toString()).delete();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<List<MicroTask>> _fetchTasks(String goalDocId) async {
    final snapshot = await _tasksRef(goalDocId).orderBy('scheduledDate').get();
    return snapshot.docs
        .map((doc) => MicroTaskFirestore.fromFirestore(doc))
        .toList();
  }
}
