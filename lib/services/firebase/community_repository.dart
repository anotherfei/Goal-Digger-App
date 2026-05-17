/// community_repository.dart
/// --------------------------
/// Firestore CRUD for [CommunityGroup].
///
/// Firestore path layout:
///   communities/{groupId}              ← shared across all users
///   users/{uid}/joinedCommunities/{groupId}   ← per-user membership
///
/// Folder: lib/services/firebase/

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/models.dart';
import 'firebase_config.dart';
import 'firebase_models.dart';

class CommunityRepository {
  CommunityRepository({String? uid}) : _uid = uid ?? currentUid ?? 'anonymous';

  final String _uid;

  // ── Collection references ──────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _communitiesRef =>
      firestore.collection('communities');

  CollectionReference<Map<String, dynamic>> get _joinedRef =>
      firestore.collection('users').doc(_uid).collection('joinedCommunities');

  // ── Real-time streams ──────────────────────────────────────────────────────

  /// All available community groups, enriched with the user's join status.
  Stream<List<CommunityGroup>> watchCommunities() {
    return _communitiesRef
        .orderBy('members', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final joinedIds = await _fetchJoinedIds();
      return snapshot.docs.map((doc) {
        final group = CommunityGroupFirestore.fromFirestore(doc);
        return CommunityGroup(
          name: group.name,
          members: group.members,
          tag: group.tag,
          description: group.description,
          similarity: group.similarity,
          joined: joinedIds.contains(doc.id),
        );
      }).toList();
    });
  }

  // ── One-shot reads ─────────────────────────────────────────────────────────

  Future<List<CommunityGroup>> fetchAllCommunities() async {
    final [snapshot, joinedIds] = await Future.wait([
      _communitiesRef.orderBy('members', descending: true).get(),
      _fetchJoinedIds() as Future,
    ]);

    final ids = joinedIds as Set<String>;
    return (snapshot as QuerySnapshot<Map<String, dynamic>>).docs.map((doc) {
      final group = CommunityGroupFirestore.fromFirestore(doc);
      return CommunityGroup(
        name: group.name,
        members: group.members,
        tag: group.tag,
        description: group.description,
        similarity: group.similarity,
        joined: ids.contains(doc.id),
      );
    }).toList();
  }

  // ── Write operations ───────────────────────────────────────────────────────

  /// Seed a new community into the shared collection.
  /// Usually done once by an admin; safe to call from the app for demos.
  Future<String> addCommunity(CommunityGroup group) async {
    final ref = await _communitiesRef.add(group.toFirestore());
    return ref.id;
  }

  /// Toggle join/leave. Adjusts the member count atomically.
  Future<void> toggleJoin(String communityId, {required bool join}) async {
    final batch = firestore.batch();

    if (join) {
      batch.set(_joinedRef.doc(communityId), {
        'joinedAt': FieldValue.serverTimestamp(),
      });
      batch.update(_communitiesRef.doc(communityId), {
        'members': FieldValue.increment(1),
      });
    } else {
      batch.delete(_joinedRef.doc(communityId));
      batch.update(_communitiesRef.doc(communityId), {
        'members': FieldValue.increment(-1),
      });
    }

    await batch.commit();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<Set<String>> _fetchJoinedIds() async {
    final snapshot = await _joinedRef.get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }
}
