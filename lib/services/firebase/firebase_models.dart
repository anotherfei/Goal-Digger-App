/// firebase_models.dart
/// ---------------------
/// Firestore serialization / deserialization for GoalProject, MicroTask,
/// CommunityGroup, and the user profile document.
///
/// Each class provides:
///   • toFirestore()  → Map<String, dynamic>  (write to Firestore)
///   • fromFirestore() factory constructor    (read from Firestore)
///
/// Folder: lib/services/firebase/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ─── Import your existing models ─────────────────────────────────────────────
// Adjust the import path if your project structure differs.
import '../../models/models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GoalProject ↔ Firestore
// ─────────────────────────────────────────────────────────────────────────────

extension GoalProjectFirestore on GoalProject {
  /// Converts a [GoalProject] to a Firestore-safe map.
  /// Tasks are stored in a sub-collection, so they are NOT included here.
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'importance': importance,
      'category': category,
      'deadline': Timestamp.fromDate(deadline),
      'fromColor': from.value,
      'toColor': to.value,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Creates a [GoalProject] from a Firestore document snapshot.
  /// [tasks] must be supplied separately from the tasks sub-collection.
  static GoalProject fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    List<MicroTask> tasks = const [],
  }) {
    final data = doc.data()!;
    return GoalProject(
      id: data['id'] as int,
      title: data['title'] as String,
      importance: data['importance'] as int,
      category: data['category'] as String,
      deadline: (data['deadline'] as Timestamp).toDate(),
      from: Color(data['fromColor'] as int),
      to: Color(data['toColor'] as int),
      tasks: tasks,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MicroTask ↔ Firestore
// ─────────────────────────────────────────────────────────────────────────────

extension MicroTaskFirestore on MicroTask {
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'goalId': goalId,
      'title': title,
      'durationMinutes': durationMinutes,
      'load': load.name,          // 'light' | 'focus' | 'stretch'
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'done': done,
      'points': points,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static MicroTask fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return MicroTask(
      id: data['id'] as int,
      goalId: data['goalId'] as int,
      title: data['title'] as String,
      durationMinutes: data['durationMinutes'] as int,
      load: TaskLoad.values.firstWhere((e) => e.name == data['load']),
      scheduledDate: (data['scheduledDate'] as Timestamp).toDate(),
      done: data['done'] as bool? ?? false,
      points: data['points'] as int? ?? 15,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CommunityGroup ↔ Firestore
// ─────────────────────────────────────────────────────────────────────────────

extension CommunityGroupFirestore on CommunityGroup {
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'members': members,
      'tag': tag,
      'description': description,
      'similarity': similarity,
      'joined': joined,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static CommunityGroup fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CommunityGroup(
      name: data['name'] as String,
      members: data['members'] as int,
      tag: data['tag'] as String,
      description: data['description'] as String,
      similarity: data['similarity'] as int? ?? 82,
      joined: data['joined'] as bool? ?? false,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UserProfile ↔ Firestore  (stored at users/{uid})
// ─────────────────────────────────────────────────────────────────────────────

class UserProfile {
  UserProfile({
    required this.uid,
    required this.displayName,
    required this.coins,
    required this.streak,
    required this.petHappiness,
    required this.activePetSkin,
    required this.activeAccessory,
    required this.onboarded,
    required this.mood,
  });

  final String uid;
  final String displayName;
  final int coins;
  final int streak;
  final int petHappiness;
  final String activePetSkin;
  final String activeAccessory;
  final bool onboarded;
  final String mood;

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'displayName': displayName,
      'coins': coins,
      'streak': streak,
      'petHappiness': petHappiness,
      'activePetSkin': activePetSkin,
      'activeAccessory': activeAccessory,
      'onboarded': onboarded,
      'mood': mood,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserProfile.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserProfile(
      uid: data['uid'] as String,
      displayName: data['displayName'] as String? ?? 'Goal Digger',
      coins: data['coins'] as int? ?? 0,
      streak: data['streak'] as int? ?? 0,
      petHappiness: data['petHappiness'] as int? ?? 50,
      activePetSkin: data['activePetSkin'] as String? ?? 'Mint',
      activeAccessory: data['activeAccessory'] as String? ?? 'Cap',
      onboarded: data['onboarded'] as bool? ?? false,
      mood: data['mood'] as String? ?? 'Okay',
    );
  }

  UserProfile copyWith({
    String? displayName,
    int? coins,
    int? streak,
    int? petHappiness,
    String? activePetSkin,
    String? activeAccessory,
    bool? onboarded,
    String? mood,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      coins: coins ?? this.coins,
      streak: streak ?? this.streak,
      petHappiness: petHappiness ?? this.petHappiness,
      activePetSkin: activePetSkin ?? this.activePetSkin,
      activeAccessory: activeAccessory ?? this.activeAccessory,
      onboarded: onboarded ?? this.onboarded,
      mood: mood ?? this.mood,
    );
  }
}
