// lib/firebase/firestore/repositories/community_repository.dart
//
// Handles the global `communities` collection, per-user membership, and
// community streak updates driven by task completions.

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/date_helpers.dart';
import '../../../models/models.dart';
import '../firestore_paths.dart';
import '../firestore_service.dart';

class CommunityRepository {
  CommunityRepository({FirestoreService? service})
      : _svc = service ?? FirestoreService();

  final FirestoreService _svc;
  final _uuid = const Uuid();

  Stream<List<CommunityGroup>> watchAllCommunities() {
    return _svc.watchCol(FirestorePaths.communitiesCol).map((snap) {
      final communities = snap.docs
          .map((doc) => _communityFromDoc(doc))
          .whereType<CommunityGroup>()
          .toList();
      communities.sort(_compareCommunities);
      return communities;
    });
  }

  Stream<Set<String>> watchJoinedIds(String uid) {
    return _svc
        .watchCol(FirestorePaths.userCommunitiesCol(uid))
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  Future<List<CommunityGroup>> fetchAll() async {
    final snap = await _svc.colRef(FirestorePaths.communitiesCol).get();
    final communities = snap.docs
        .map((doc) => _communityFromDoc(doc))
        .whereType<CommunityGroup>()
        .toList();
    communities.sort(_compareCommunities);
    return communities;
  }

  Future<CommunityGroup> createCommunity(
    CommunityGroup community,
    String creatorUid,
  ) async {
    final id = _uuid.v4();
    await _svc.setDoc(FirestorePaths.communityDoc(id), {
      'id': id,
      'name': community.name,
      'tag': community.tag,
      'description': community.description,
      'members': <String>[],
      'memberCount': 0,
      'similarity': community.similarity,
      'creatorUid': creatorUid,
      'communityStreak': 0,
      'lastCommunityStreakDateKey': null,
      'activeMemberCountToday': 0,
      'requiredActiveMembersToday': 1,
      'lastCommunityActivityDateKey': null,
      'createdAt': FirestoreService.serverTimestamp,
      'updatedAt': FirestoreService.serverTimestamp,
    });

    await join(creatorUid, id);
    return CommunityGroup(
      name: community.name,
      members: 1,
      tag: community.tag,
      description: community.description,
      similarity: community.similarity,
      joined: true,
      backendId: id,
      communityStreak: 0,
      activeMemberCountToday: 0,
      requiredActiveMembersToday: 1,
    );
  }

  Future<void> join(String uid, String communityId) async {
    final communityRef = _svc.docRef(FirestorePaths.communityDoc(communityId));
    final membershipRef =
        _svc.docRef(FirestorePaths.userCommunityDoc(uid, communityId));

    await _svc.runTransaction<void>((transaction) async {
      final snapshot = await transaction.get(communityRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() ?? {};
      final rawMembers = data['members'];
      final memberUids = _stringListFromRaw(rawMembers).toSet();

      transaction.set(
        membershipRef,
        {
          'communityId': communityId,
          'joinedAt': FirestoreService.serverTimestamp,
        },
        SetOptions(merge: true),
      );

      if (rawMembers is Iterable || rawMembers == null) {
        memberUids.add(uid);
        transaction.set(
          communityRef,
          {
            'members': memberUids.toList(),
            'memberCount': memberUids.length,
            'updatedAt': FirestoreService.serverTimestamp,
          },
          SetOptions(merge: true),
        );
      } else {
        transaction.update(communityRef, {
          'members': FirestoreService.increment(1),
          'memberCount': FirestoreService.increment(1),
          'updatedAt': FirestoreService.serverTimestamp,
        });
      }
    });
    debugPrint('User $uid joined community $communityId');
  }

  Future<void> leave(String uid, String communityId) async {
    final communityRef = _svc.docRef(FirestorePaths.communityDoc(communityId));
    final membershipRef =
        _svc.docRef(FirestorePaths.userCommunityDoc(uid, communityId));

    await _svc.runTransaction<void>((transaction) async {
      final snapshot = await transaction.get(communityRef);
      transaction.delete(membershipRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() ?? {};
      final rawMembers = data['members'];
      final memberUids = _stringListFromRaw(rawMembers).toSet();

      if (rawMembers is Iterable || rawMembers == null) {
        memberUids.remove(uid);
        transaction.set(
          communityRef,
          {
            'members': memberUids.toList(),
            'memberCount': memberUids.length,
            'updatedAt': FirestoreService.serverTimestamp,
          },
          SetOptions(merge: true),
        );
      } else {
        transaction.update(communityRef, {
          'members': FirestoreService.increment(-1),
          'memberCount': FirestoreService.increment(-1),
          'updatedAt': FirestoreService.serverTimestamp,
        });
      }
    });
    debugPrint('User $uid left community $communityId');
  }

  Future<void> deleteCommunity(String uid, String communityId) async {
    await leave(uid, communityId);
    await _svc.deleteDoc(FirestorePaths.communityDoc(communityId));
  }

  Future<int> markTaskCompleted(String uid, DateTime completedAt) async {
    final communityIds = await _joinedCommunityIdsFor(uid);
    if (communityIds.isEmpty) return 0;

    var updatedCount = 0;
    Object? firstError;
    StackTrace? firstStackTrace;
    for (final communityId in communityIds) {
      try {
        await _markCommunityActiveToday(uid, communityId, completedAt);
        updatedCount++;
      } catch (error, stackTrace) {
        firstError ??= error;
        firstStackTrace ??= stackTrace;
        debugPrint('Community streak update failed for $communityId: $error');
      }
    }

    if (updatedCount == 0 && firstError != null) {
      Error.throwWithStackTrace(
        firstError,
        firstStackTrace ?? StackTrace.current,
      );
    }

    return updatedCount;
  }

  CommunityGroup? _communityFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    try {
      final d = doc.data()!;
      final totalMembers = max(1, _memberCount(d));
      final lastCommunityStreakDateKey = _readOptionalString(
        d,
        const ['lastCommunityStreakDateKey', 'lastStreakDateKey'],
      );
      final activityDateKey = _readOptionalString(
        d,
        const ['lastCommunityActivityDateKey', 'activityDateKey'],
      );
      final activeMemberCountToday = activityDateKey == dateKey(DateTime.now())
          ? _readInt(d, const ['activeMemberCountToday'], 0)
          : 0;

      return CommunityGroup(
        name: (d['name'] ?? d['title'])?.toString() ?? 'Untitled community',
        members: totalMembers,
        tag: (d['tag'] ?? d['category'])?.toString() ?? 'General',
        description: (d['description'] ?? d['about'])?.toString() ??
            'No description yet.',
        similarity: (d['similarity'] as num?)?.toInt() ?? 80,
        backendId: doc.id,
        communityStreak: _communityStreakForToday(
          _readInt(d, const ['communityStreak', 'streak'], 0),
          lastCommunityStreakDateKey,
        ),
        lastCommunityStreakDateKey: lastCommunityStreakDateKey,
        activeMemberCountToday: activeMemberCountToday,
        requiredActiveMembersToday: _readInt(
          d,
          const ['requiredActiveMembersToday'],
          max(1, (totalMembers / 2).ceil()),
        ),
      );
    } catch (e) {
      debugPrint('Failed to parse community ${doc.id}: $e');
      return null;
    }
  }

  Future<Set<String>> _joinedCommunityIdsFor(String uid) async {
    final ids = <String>{};

    try {
      final membershipSnap =
          await _svc.colRef(FirestorePaths.userCommunitiesCol(uid)).get();
      ids.addAll(membershipSnap.docs.map((doc) => doc.id));
    } catch (error) {
      debugPrint('Community membership lookup failed: $error');
    }

    try {
      final userSnap = await _svc.getDoc(FirestorePaths.userDoc(uid));
      ids.addAll(_stringListFromRaw(userSnap.data()?['communityIds']));
    } catch (error) {
      debugPrint('User communityIds lookup failed: $error');
    }

    try {
      final memberSnap = await _svc
          .colRef(FirestorePaths.communitiesCol)
          .where('members', arrayContains: uid)
          .limit(100)
          .get();
      ids.addAll(memberSnap.docs.map((doc) => doc.id));
    } catch (error) {
      debugPrint('Community members lookup failed: $error');
    }

    return ids;
  }

  Future<void> _markCommunityActiveToday(
    String uid,
    String communityId,
    DateTime completedAt,
  ) async {
    final day = dateOnly(completedAt);
    final dayKey = dateKey(day);
    final yesterdayKey = dateKey(addDays(day, -1));
    final communityRef = _svc.docRef(FirestorePaths.communityDoc(communityId));
    final activityRef = _svc.docRef(
      FirestorePaths.communityDailyActivityDoc(communityId, dayKey),
    );

    await _svc.runTransaction<void>((transaction) async {
      final communitySnap = await transaction.get(communityRef);
      if (!communitySnap.exists) return;

      final data = communitySnap.data() ?? {};
      final memberUids = _stringListFromRaw(data['members']).toSet();
      final hasExplicitMemberList = data['members'] is Iterable;

      if (hasExplicitMemberList && !memberUids.contains(uid)) return;

      final totalMembers = max(1, max(_memberCount(data), memberUids.length));
      final requiredActiveMembers = max(1, (totalMembers / 2).ceil());
      final activitySnap = await transaction.get(activityRef);
      final activeMemberUids = _stringListFromRaw(
        activitySnap.data()?['activeMemberUids'],
      ).toSet()
        ..add(uid);
      final activeMemberCount = activeMemberUids.length;
      final qualified = activeMemberCount >= requiredActiveMembers;

      transaction.set(
        activityRef,
        {
          'dateKey': dayKey,
          'activeMemberUids': activeMemberUids.toList(),
          'activeMemberCount': activeMemberCount,
          'requiredActiveMembers': requiredActiveMembers,
          'qualified': qualified,
          'updatedAt': FirestoreService.serverTimestamp,
        },
        SetOptions(merge: true),
      );

      final lastCommunityStreakDateKey = _readOptionalString(
        data,
        const ['lastCommunityStreakDateKey', 'lastStreakDateKey'],
      );
      final rawCommunityStreak = _readInt(
        data,
        const ['communityStreak', 'streak'],
        0,
      );
      final communityUpdates = <String, dynamic>{
        'activeMemberCountToday': activeMemberCount,
        'requiredActiveMembersToday': requiredActiveMembers,
        'lastCommunityActivityDateKey': dayKey,
        'lastCommunityActivityAt': FirestoreService.serverTimestamp,
        'updatedAt': FirestoreService.serverTimestamp,
      };

      if (qualified) {
        final nextStreak = lastCommunityStreakDateKey == dayKey
            ? max(1, rawCommunityStreak)
            : lastCommunityStreakDateKey == yesterdayKey
                ? rawCommunityStreak + 1
                : 1;

        communityUpdates.addAll({
          'communityStreak': nextStreak,
          'lastCommunityStreakDateKey': dayKey,
        });
      } else if (lastCommunityStreakDateKey != dayKey &&
          lastCommunityStreakDateKey != yesterdayKey &&
          rawCommunityStreak > 0) {
        communityUpdates['communityStreak'] = 0;
      }

      transaction.set(
        communityRef,
        communityUpdates,
        SetOptions(merge: true),
      );
    });
  }

  int _memberCount(Map<String, dynamic> d) {
    final members = d['members'];
    if (members is num) return members.toInt();

    final memberCount = d['memberCount'] ?? d['membersCount'];
    if (members is List) {
      final listedMembers = members.length;
      if (memberCount is num) return max(listedMembers, memberCount.toInt());
      return listedMembers;
    }

    if (memberCount is num) return memberCount.toInt();
    return 0;
  }

  int _compareCommunities(CommunityGroup a, CommunityGroup b) {
    final streakCompare = b.communityStreak.compareTo(a.communityStreak);
    if (streakCompare != 0) return streakCompare;

    final activeCompare =
        b.activeMemberCountToday.compareTo(a.activeMemberCountToday);
    if (activeCompare != 0) return activeCompare;

    final memberCompare = b.members.compareTo(a.members);
    if (memberCompare != 0) return memberCompare;

    return a.name.compareTo(b.name);
  }

  int _communityStreakForToday(int streak, String? lastStreakDateKey) {
    final lastStreakDay = _parseDateKey(lastStreakDateKey);
    if (lastStreakDay == null) return streak;

    final gap = daysBetween(lastStreakDay, DateTime.now());
    return gap > 1 ? 0 : streak;
  }

  DateTime? _parseDateKey(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.trim().split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  int _readInt(
    Map<String, dynamic> data,
    List<String> keys, [
    int fallback = 0,
  ]) {
    for (final key in keys) {
      final value = data[key];
      if (value is num) return value.toInt();
    }
    return fallback;
  }

  String? _readOptionalString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  List<String> _stringListFromRaw(dynamic raw) {
    if (raw is! Iterable) return const [];

    return raw
        .map((value) => value.toString().trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }
}
