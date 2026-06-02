// ─────────────────────────────────────────────────────────────────────────────
// lib/firebase/firestore/firestore_paths.dart
//
// Single source of truth for every Firestore collection and document path.
// Never hardcode path strings anywhere else in the codebase.
//
// Data model overview:
//   users/{uid}
//     goals/{goalId}
//       tasks/{taskId}
//     communities/{communityId}
//     profile                        ← single document (merge field on users/{uid})
// ─────────────────────────────────────────────────────────────────────────────

class FirestorePaths {
  FirestorePaths._();

  // ── User root ────────────────────────────────────────────────────────────────

  static String userDoc(String uid) => 'users/$uid';

  // ── Goals ────────────────────────────────────────────────────────────────────

  static String goalsCol(String uid) => 'users/$uid/goals';
  static String goalDoc(String uid, String goalId) =>
      'users/$uid/goals/$goalId';

  // ── Tasks (sub-collection of each goal) ──────────────────────────────────────

  static String tasksCol(String uid, String goalId) =>
      'users/$uid/goals/$goalId/tasks';
  static String taskDoc(String uid, String goalId, String taskId) =>
      'users/$uid/goals/$goalId/tasks/$taskId';


  // ── Routines ────────────────────────────────────────────────────────────────

  static String routinesCol(String uid) => 'users/$uid/routines';
  static String routineDoc(String uid, String routineId) =>
      'users/$uid/routines/$routineId';

  // ── Community ────────────────────────────────────────────────────────────────

  // Notifications

  static String notificationsCol(String uid) => 'users/$uid/notifications';
  static String notificationDoc(String uid, String notificationId) =>
      'users/$uid/notifications/$notificationId';

  /// Global community groups (not per-user)
  static const String communitiesCol = 'communities';
  static String communityDoc(String communityId) =>
      'communities/$communityId';

  /// Which communities a user has joined
  static String userCommunitiesCol(String uid) => 'users/$uid/communities';
  static String userCommunityDoc(String uid, String communityId) =>
      'users/$uid/communities/$communityId';

  // ── AI Coach History ─────────────────────────────────────────────────────────

  static String aiSessionsCol(String uid) => 'users/$uid/ai_sessions';
  static String aiSessionDoc(String uid, String sessionId) =>
      'users/$uid/ai_sessions/$sessionId';
}
