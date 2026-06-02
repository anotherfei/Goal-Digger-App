// ─────────────────────────────────────────────────────────────────────────────
// lib/firebase/firestore/repositories/community_repository.dart
//
// Handles the global `communities` collection and per-user membership.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../models/models.dart';
import '../firestore_paths.dart';
import '../firestore_service.dart';

class CommunityRepository {
  CommunityRepository({FirestoreService? service})
      : _svc = service ?? FirestoreService();

  final FirestoreService _svc;
  final _uuid = const Uuid();

  // ── Global community stream ──────────────────────────────────────────────────

  Stream<List<CommunityGroup>> watchAllCommunities() {
    return _svc
        .watchCol(
      FirestorePaths.communitiesCol,
      queryBuilder: (col) => col.orderBy('members', descending: true),
    )
        .map((snap) {
      return snap.docs
          .map((doc) => _communityFromDoc(doc))
          .whereType<CommunityGroup>()
          .toList();
    });
  }

  // ── User membership stream ───────────────────────────────────────────────────

  /// Stream of community IDs the user has joined.
  Stream<Set<String>> watchJoinedIds(String uid) {
    return _svc
        .watchCol(FirestorePaths.userCommunitiesCol(uid))
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  // ── Fetch ────────────────────────────────────────────────────────────────────

  Future<List<CommunityGroup>> fetchAll() async {
    final snap = await _svc.colRef(FirestorePaths.communitiesCol).get();
    return snap.docs
        .map((doc) => _communityFromDoc(doc))
        .whereType<CommunityGroup>()
        .toList();
  }

  // ── Create ───────────────────────────────────────────────────────────────────

  Future<CommunityGroup> createCommunity(
      CommunityGroup community, String creatorUid) async {
    final id = _uuid.v4();
    await _svc.setDoc(FirestorePaths.communityDoc(id), {
      'id': id,
      'name': community.name,
      'tag': community.tag,
      'description': community.description,
      'members': 0,
      'similarity': community.similarity,
      'creatorUid': creatorUid,
      'createdAt': FirestoreService.serverTimestamp,
    });
    // Auto-join creator. The document starts at 0 members so join() increments
    // it to exactly 1 instead of accidentally showing 2 members.
    await join(creatorUid, id);
    return CommunityGroup(
      name: community.name,
      members: 1,
      tag: community.tag,
      description: community.description,
      similarity: community.similarity,
      joined: true,
      backendId: id,
    );
  }

  // ── Join / Leave ─────────────────────────────────────────────────────────────

  Future<void> join(String uid, String communityId) async {
    final batch = _svc.batch;

    // Add membership record
    batch.set(
      _svc.docRef(FirestorePaths.userCommunityDoc(uid, communityId)),
      {
        'communityId': communityId,
        'joinedAt': FirestoreService.serverTimestamp,
      },
    );

    // Increment member count
    batch.update(
      _svc.docRef(FirestorePaths.communityDoc(communityId)),
      {'members': FirestoreService.increment(1)},
    );

    await batch.commit();
    debugPrint('✅ User $uid joined community $communityId');
  }

  Future<void> leave(String uid, String communityId) async {
    final batch = _svc.batch;

    batch.delete(
        _svc.docRef(FirestorePaths.userCommunityDoc(uid, communityId)));
    batch.update(
      _svc.docRef(FirestorePaths.communityDoc(communityId)),
      {'members': FirestoreService.increment(-1)},
    );

    await batch.commit();
    debugPrint('👋 User $uid left community $communityId');
  }

  Future<void> deleteCommunity(String uid, String communityId) async {
    await leave(uid, communityId);
    await _svc.deleteDoc(FirestorePaths.communityDoc(communityId));
  }

  // ── Serialisation ─────────────────────────────────────────────────────────────

  CommunityGroup? _communityFromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final d = doc.data()!;
      return CommunityGroup(
        name: d['name'] as String,
        members: (d['members'] as num).toInt(),
        tag: d['tag'] as String,
        description: d['description'] as String,
        similarity: (d['similarity'] as num?)?.toInt() ?? 80,
        backendId: doc.id,
      );
    } catch (e) {
      debugPrint('⚠️  Failed to parse community ${doc.id}: $e');
      return null;
    }
  }
}
