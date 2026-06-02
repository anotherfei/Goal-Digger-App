import 'dart:async';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../firebase/firestore/repositories/notification_repository.dart';
import '../notifications/models/notification_models.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../firebase/auth/auth_state.dart';
import '../onboarding/onboarding_screen.dart';

import '../../core/theme/gd_design.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';

const bool kDebugAllowGuestSocialAccess = false;

class CommunityPage extends StatefulWidget {
  const CommunityPage({
    super.key,
    required this.controller,
    required this.communities,
    required this.friends,
    required this.friendSuggestions,
    required this.streak,
    required this.onAddCommunity,
    required this.onJoinCommunity,
    required this.onDeleteCommunity,
    required this.onAddFriend,
    required this.onDeleteFriend,
  });

  final TextEditingController controller;
  final List<CommunityGroup> communities;
  final List<String> friends;
  final List<String> friendSuggestions;
  final int streak;
  final VoidCallback onAddCommunity;
  final ValueChanged<CommunityGroup> onJoinCommunity;
  final ValueChanged<CommunityGroup> onDeleteCommunity;
  final ValueChanged<String> onAddFriend;
  final ValueChanged<String> onDeleteFriend;

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  int _tab = 0;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationRepository _notificationRepository = NotificationRepository();
  final Uuid _uuid = const Uuid();
  bool _profileReady = false;
  bool _allowFriendsError = false;
  Timer? _friendsErrorTimer;

  @override
  void initState() {
    super.initState();

    _friendsErrorTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
            setState(() => _allowFriendsError = true);
        }
    });

    unawaited(_prepareSocialProfile());
  }

  Future<void> _prepareSocialProfile() async {
    try {
        await _ensurePublicProfile();
    } finally {
        if (mounted) {
            setState(() => _profileReady = true);
        }
    }
  }

  @override
  void didUpdateWidget(covariant CommunityPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streak != widget.streak) {
      unawaited(_ensurePublicProfile());
    }
  }

  @override
  void dispose() {
    _friendsErrorTimer?.cancel();
    super.dispose();
  }

  User? get _user => _auth.currentUser;

  bool get _isGuestUser => _user?.isAnonymous ?? false;

  bool get _canUseSocial {
    final user = _user;
    if (user == null) return false;

    if (kDebugAllowGuestSocialAccess) {
      return true;
    }

    return !user.isAnonymous;
  }

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _publicProfiles =>
      _db.collection('public_profiles');

  CollectionReference<Map<String, dynamic>> get _communitiesCollection =>
      _db.collection('communities');

  Future<void> _ensurePublicProfile() async {
    final user = _user;
    if (user == null) return;

    if (user.isAnonymous && !kDebugAllowGuestSocialAccess) {
      return;
    }

    final displayName = _cleanDisplayName(user.displayName, user.email);
    final username = _usernameFor(displayName, user.email, user.uid);
    final searchName = _searchIndex(displayName, username, user.email);

    final userRef = _usersCollection.doc(user.uid);
    final userSnapshot = await userRef.get();
    final hasFriendsField =
        userSnapshot.exists && (userSnapshot.data()?.containsKey('friends') ?? false);
    final invalidFriendEntries = _invalidFriendEntriesFromData(userSnapshot.data());

    final userData = <String, dynamic>{
      'uid': user.uid,
      'displayName': displayName,
      'name': displayName,
      'username': username,
      'email': user.email,
      'photoUrl': user.photoURL,
      'photoURL': user.photoURL,
      'streak': widget.streak,
      'searchName': searchName,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!userSnapshot.exists) {
      userData['createdAt'] = FieldValue.serverTimestamp();
    }

    if (invalidFriendEntries.isNotEmpty) {
      userData['friends'] = FieldValue.arrayRemove(invalidFriendEntries);
    } else if (!hasFriendsField) {
      userData['friends'] = <String>[];
    }

    await userRef.set(userData, SetOptions(merge: true));

    await _publicProfiles.doc(user.uid).set({
      'uid': user.uid,
      'displayName': displayName,
      'username': username,
      'photoUrl': user.photoURL,
      'streak': widget.streak,
      'searchName': searchName,
      'updatedAt': FieldValue.serverTimestamp(),
      if (!userSnapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _cleanDisplayName(String? displayName, String? email) {
    final fromName = displayName?.trim();
    if (fromName != null && fromName.isNotEmpty) return fromName;
    final fromEmail = email?.split('@').first.trim();
    if (fromEmail != null && fromEmail.isNotEmpty) return fromEmail;
    return 'Goal Digger User';
  }

  String _usernameFor(String displayName, String? email, String uid) {
    final base = email
            ?.split('@')
            .first
            .trim()
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9_]'), '_') ??
        displayName.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    final cleaned =
        base.replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_|_$'), '');
    if (cleaned.isEmpty) return '@user_${uid.substring(0, min(6, uid.length))}';
    return cleaned.startsWith('@') ? cleaned : '@$cleaned';
  }

  String _searchIndex(String displayName, String username, [String? email]) {
    final cleanedUsername = username.toLowerCase().replaceAll('@', '');
    final cleanedEmail = email?.toLowerCase() ?? '';
    return '${displayName.toLowerCase()} $cleanedUsername ${username.toLowerCase()} $cleanedEmail';
  }

  _FriendProfile _currentUserFallbackProfile() {
    final user = _user;
    final displayName = _cleanDisplayName(user?.displayName, user?.email);
    final username =
        _usernameFor(displayName, user?.email, user?.uid ?? 'guest');

    return _FriendProfile(
      uid: user?.uid ?? 'guest',
      displayName: displayName,
      username: username,
      photoUrl: user?.photoURL,
      streak: widget.streak,
      isReal: user != null,
      isFriend: true,
      hasChat: false,
      lastMessage: null,
      lastSenderUid: null,
      hasUnread: false,
      chatUpdatedAt: null,
    );
  }

  Stream<_FriendsData> _friendsDataStream() {
    if (!_canUseSocial) {
      return Stream.value(
        _FriendsData(
          currentUser: _currentUserFallbackProfile(),
          friends: const [],
        ),
      );
    }

    final user = _user;
    if (user == null) {
      return Stream.value(
        _FriendsData(
          currentUser: _currentUserFallbackProfile(),
          friends: const [],
        ),
      );
    }

    final controller = StreamController<_FriendsData>();
    DocumentSnapshot<Map<String, dynamic>>? latestUserSnapshot;
    QuerySnapshot<Map<String, dynamic>>? latestChatsSnapshot;
    var emitVersion = 0;
    var disposed = false;

    Future<void> emit() async {
      final version = ++emitVersion;
      try {
        final data = await _buildFriendsDataFromSnapshots(
          userUid: user.uid,
          userSnapshot: latestUserSnapshot,
          chatsSnapshot: latestChatsSnapshot,
        );

        if (disposed || controller.isClosed || version != emitVersion) return;
        controller.add(data);
      } catch (error, stackTrace) {
        if (disposed || controller.isClosed) return;
        controller.addError(error, stackTrace);
      }
    }

    final userSub = _usersCollection.doc(user.uid).snapshots().listen(
      (snapshot) {
        latestUserSnapshot = snapshot;
        unawaited(emit());
      },
      onError: controller.addError,
    );

    final chatSub = _db
        .collection('chats')
        .where('members', arrayContains: user.uid)
        .snapshots()
        .listen(
      (snapshot) {
        latestChatsSnapshot = snapshot;
        unawaited(emit());
      },
      onError: controller.addError,
    );

    controller.onCancel = () async {
      disposed = true;
      await userSub.cancel();
      await chatSub.cancel();
    };

    return controller.stream;
  }

  Future<_FriendsData> _buildFriendsDataFromSnapshots({
    required String userUid,
    required DocumentSnapshot<Map<String, dynamic>>? userSnapshot,
    required QuerySnapshot<Map<String, dynamic>>? chatsSnapshot,
  }) async {
    final fallback = _currentUserFallbackProfile();
    final currentUser = userSnapshot != null && userSnapshot.exists
        ? _FriendProfile.fromUserDoc(
            userSnapshot,
            fallbackName: fallback.displayName,
            fallbackUsername: fallback.username,
            fallbackPhotoUrl: fallback.photoUrl,
            fallbackStreak: fallback.streak,
          )
        : fallback;

    final friendUidList = _friendUidsFromData(userSnapshot?.data())
        .where((uid) => uid != userUid)
        .toList();
    final friendUidSet = friendUidList.toSet();

    final chatByUid = _directChatSummariesFromSnapshot(chatsSnapshot, userUid);

    final orderedUids = <String>[];
    final seen = <String>{};

    // Chat rooms first, newest first, so incoming chats show up immediately.
    final chatEntries = chatByUid.entries.toList()
      ..sort(
        (a, b) => _timestampMillis(b.value.updatedAt)
            .compareTo(_timestampMillis(a.value.updatedAt)),
      );

    for (final entry in chatEntries) {
      if (seen.add(entry.key)) {
        orderedUids.add(entry.key);
      }
    }

    // Then add friends who do not have a chat yet.
    for (final uid in friendUidList) {
      if (seen.add(uid)) {
        orderedUids.add(uid);
      }
    }

    final friends = await _fetchUserProfiles(
      userUids: orderedUids,
      friendUids: friendUidSet,
      chatByUid: chatByUid,
    );

    return _FriendsData(currentUser: currentUser, friends: friends);
  }

  Map<String, _DirectChatSummary> _directChatSummariesFromSnapshot(
    QuerySnapshot<Map<String, dynamic>>? snapshot,
    String currentUid,
  ) {
    final summaries = <String, _DirectChatSummary>{};
    if (snapshot == null) return summaries;

    for (final doc in snapshot.docs) {
      final summary = _DirectChatSummary.fromChatDoc(doc, currentUid);
      if (summary == null) continue;

      final existing = summaries[summary.otherUid];
      if (existing == null ||
          _timestampMillis(summary.updatedAt) >
              _timestampMillis(existing.updatedAt)) {
        summaries[summary.otherUid] = summary;
      }
    }

    return summaries;
  }

  int _timestampMillis(Timestamp? timestamp) =>
      timestamp?.millisecondsSinceEpoch ?? 0;

  Future<List<_FriendProfile>> _fetchUserProfiles({
    required List<String> userUids,
    required Set<String> friendUids,
    required Map<String, _DirectChatSummary> chatByUid,
  }) async {
    final orderedUids = <String>[];
    final seen = <String>{};

    for (final uid in userUids) {
      final cleaned = uid.trim();
      if (cleaned.isEmpty || seen.contains(cleaned)) continue;
      seen.add(cleaned);
      orderedUids.add(cleaned);
    }

    if (orderedUids.isEmpty) return const [];

    final profilesByUid = <String, _FriendProfile>{};

    for (final chunk in _chunks(orderedUids, 10)) {
      final snapshot = await _publicProfiles
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        final summary = chatByUid[doc.id];
        profilesByUid[doc.id] = _FriendProfile.fromUserDoc(
          doc,
          isFriend: friendUids.contains(doc.id),
          hasChat: summary != null,
          lastMessage: summary?.lastMessage,
          lastSenderUid: summary?.lastSenderUid,
          hasUnread: summary?.hasUnread ?? false,
          chatUpdatedAt: summary?.updatedAt,
        );
      }
    }

    final result = <_FriendProfile>[];

    for (final uid in orderedUids) {
      final profile = profilesByUid[uid];
      if (profile != null) {
        result.add(profile);
        continue;
      }

      final chatSummary = chatByUid[uid];
      if (chatSummary != null) {
        result.add(
          _FriendProfile.fromChatSummary(
            chatSummary,
            isFriend: friendUids.contains(uid),
          ),
        );
        continue;
      }

      // This can happen when users/{currentUid}.friends contains a UID,
      // but that user has not created public_profiles/{uid} yet.
      // Do not crash the whole Friends page; show a safe fallback row instead.
      final shortUid = uid.substring(0, min(6, uid.length));
      final displayName = 'Friend $shortUid';
      result.add(
        _FriendProfile(
          uid: uid,
          displayName: displayName,
          username: _fallbackUsernameFor(displayName, '', uid),
          photoUrl: null,
          streak: 0,
          isReal: true,
          isFriend: friendUids.contains(uid),
          hasChat: false,
          lastMessage: null,
          lastSenderUid: null,
          hasUnread: false,
          chatUpdatedAt: null,
        ),
      );
    }

    return result;
  }

  List<String> _friendUidsFromData(Map<String, dynamic>? data) {
    final rawFriends = data?['friends'];

    if (rawFriends is! Iterable) {
      return const [];
    }

    return rawFriends
        .map((friend) {
          if (friend is String) return friend;
          if (friend is Map) {
            return (friend['uid'] ?? friend['id'] ?? friend['userId'])
                ?.toString();
          }
          return null;
        })
        .whereType<String>()
        .map((uid) => uid.trim())
        // Old app versions stored display names in friends, for example
        // "wilson thang". Friends must be stored as user document ids / UIDs.
        .where(_looksLikeStoredUid)
        .toList();
  }

  List<Object> _invalidFriendEntriesFromData(Map<String, dynamic>? data) {
    final rawFriends = data?['friends'];

    if (rawFriends is! Iterable) {
      return const [];
    }

    return rawFriends
        .where((friend) {
          if (friend is String) {
            return !_looksLikeStoredUid(friend.trim());
          }
          if (friend is Map) {
            final uid = (friend['uid'] ?? friend['id'] ?? friend['userId'])
                ?.toString()
                .trim();
            return uid == null || !_looksLikeStoredUid(uid);
          }
          return true;
        })
        .cast<Object>()
        .toList();
  }

  bool _looksLikeStoredUid(String value) {
    final uid = value.trim();
    if (uid.isEmpty) return false;
    if (uid.contains(RegExp(r'\s'))) return false;
    if (uid.startsWith('@')) return false;
    return uid.length >= 6;
  }

  List<List<T>> _chunks<T>(List<T> values, int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < values.length; i += size) {
      chunks.add(values.sublist(i, min(i + size, values.length)));
    }
    return chunks;
  }

  Future<void> _addFriend(_PublicProfile profile) async {
    await _addFriendByUid(
      friendUid: profile.uid,
      displayName: profile.displayName,
    );
  }

  Future<void> _addFriendFromFriendProfile(_FriendProfile profile) async {
    await _addFriendByUid(
      friendUid: profile.uid,
      displayName: profile.displayName,
    );
  }

  Future<void> _addFriendByUid({
    required String friendUid,
    required String displayName,
  }) async {
    final user = _user;
    if (user == null) {
      _showSnack('Sign in before adding friends.');
      return;
    }

    if (user.isAnonymous && !kDebugAllowGuestSocialAccess) {
      _showSnack('Use a full account before adding real friends.');
      return;
    }

    if (friendUid == user.uid) {
      _showSnack('That is your own profile.');
      return;
    }

    await _ensurePublicProfile();

    await _usersCollection.doc(user.uid).set({
      'friends': FieldValue.arrayUnion([friendUid]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final actorName = _cleanDisplayName(user.displayName, user.email);

    await _notificationRepository.addSocialNotification(
        recipientUid: friendUid,
        actorUid: user.uid,
        notification: AppNotification(
            id: _uuid.v4(),
            title: 'New friend',
            body: '$actorName added you as a friend.',
            type: AppNotificationType.friend,
            delivery: NotificationDelivery.inApp,
            createdAt: DateTime.now(),
            important: false,
            sourceId: user.uid,
            payload: {
                'actorUid': user.uid,
                'actorName': actorName,
                'route': 'friends',
                'friendUid': user.uid,
            },
        ),
     );

    widget.onAddFriend(displayName);
    _showSnack('$displayName added to your friends.');
  }

  Future<void> _deleteFriend(_FriendProfile friend) async {
    final user = _user;
    if (user == null) {
      _showSnack('Sign in before removing friends.');
      return;
    }

    await _usersCollection.doc(user.uid).set({
      'friends': FieldValue.arrayRemove([friend.uid]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    widget.onDeleteFriend(friend.displayName);
    _showSnack('${friend.displayName} removed.');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }


  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 85),
        children: [
          const SizedBox(height: 14),
          AppCard(
            color: gdCardLight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: _SegmentButton(
                      label: 'Friends',
                      icon: Icons.person_add_alt_1_rounded,
                      selected: _tab == 0,
                      onTap: () => setState(() => _tab = 0),
                    ),
                  ),
                  Expanded(
                    child: _SegmentButton(
                      label: 'Communities',
                      icon: Icons.groups_rounded,
                      selected: _tab == 1,
                      onTap: () => setState(() => _tab = 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!_canUseSocial)
            _buildSignedOutGate(context)
          else if (_tab == 0)
            _buildFriendsTab(context)
          else
            _buildCommunitiesTab(context),
        ],
      ),
    );
  }

  Widget _buildSignedOutGate(BuildContext context) {
    final isGuest = _isGuestUser;
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: gdPrimarySoft,
              child: Icon(
                Icons.lock_outline_rounded,
                color: gdPrimary,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isGuest ? 'Full sign-in required' : 'Sign in to use Social',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: gdInk,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isGuest
                  ? 'Guest mode is only for preview. Friends, friend search, communities, and chat need a full account so your data can sync safely with Firestore.'
                  : 'Friends, friend search, communities, and chat need an account so your data can sync safely with Firestore.',
              style: TextStyle(
                color: gdMuted,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openFullAccountLogin(context),
                icon: const Icon(Icons.login_rounded),
                label: Text(isGuest ? 'Use full account' : 'Sign in'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFullAccountLogin(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _FullAccountLoginPage(),
      ),
    );

    if (!mounted) return;
    setState(() => _profileReady = false);
    await _prepareSocialProfile();
  }

  Widget _buildFriendsTab(BuildContext context) {
    if (!_profileReady) {
    return const Center(
        child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
        ),
      );
    }
    return StreamBuilder<_FriendsData>(
      stream: _friendsDataStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError && !_allowFriendsError) {
            return const Center(
                child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
                ),
            );
        }

        if (snapshot.hasError) {
            return HelpfulErrorBox(
                title: 'Friends failed to load',
                message:
                    'Check Firestore rules for users/{uid}.friends and user profile reads. Details: ${snapshot.error}',
                actionLabel: 'OK',
                showAction: false,
            );
        }

        final friendsData = snapshot.data ??
            _FriendsData(
              currentUser: _currentUserFallbackProfile(),
              friends: const [],
            );
        final currentUser = friendsData.currentUser;
        final friends = friendsData.friends;
        final leaderboard = <_LeaderboardEntry>[
          _LeaderboardEntry('You', currentUser.streak, isYou: true),
          for (final friend in friends)
            _LeaderboardEntry(friend.displayName, friend.streak),
        ]..sort((a, b) => b.streak.compareTo(a.streak));

        final topThree = leaderboard.take(3).toList();
        final friendPreview =
            friends.length > 5 ? friends.take(5).toList() : friends;
        final currentFriendUids = friends
            .where((friend) => friend.isFriend)
            .map((friend) => friend.uid)
            .toSet();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(title: 'Top streaks', trailing: 'TOP 3'),
            const SizedBox(height: 10),
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    for (var i = 0; i < topThree.length; i++)
                      _LeaderboardTile(rank: i + 1, entry: topThree[i]),
                    if (leaderboard.length > 3) ...[
                      const Divider(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _openLeaderboardPage(context, leaderboard),
                          icon: const Icon(Icons.emoji_events_rounded),
                          label: const Text('View full leaderboard'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SectionTitle(title: 'Friends & chats', trailing: '${friends.length}'),
            const SizedBox(height: 10),
            if (snapshot.connectionState == ConnectionState.waiting &&
                snapshot.data == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (friends.isEmpty)
              const HelpfulErrorBox(
                title: 'No friends or chats yet',
                message:
                    'Find real users or start a chat. Any direct chat room will appear here too.',
                actionLabel: 'Got it',
                showAction: false,
              )
            else ...[
              for (final friend in friendPreview)
                _FriendListCard(
                  friend: friend,
                  onDetails: () => _openUserDetailsPage(context, friend),
                  onChat: () => _openChatPage(context, friend),
                  onAdd: () => unawaited(_addFriendFromFriendProfile(friend)),
                  onDelete: friend.isFriend
                      ? () => unawaited(_deleteFriend(friend))
                      : null,
                ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: gdPrimary,
                    foregroundColor: gdCardLight,
                    side: BorderSide(color: gdPrimary, width: 1.5),
                  ),
                  onPressed: () => _openAllFriendsPage(context, friends),
                  icon: const Icon(Icons.people_rounded),
                  label: Text('View all friends & chats (${friends.length})'),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (friends.isEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () =>
                      _openFindFriendsPage(context, currentFriendUids),
                  icon: const Icon(Icons.person_search_rounded),
                  label: const Text('Find friends'),
                ),
              ),
            ],
            // Extra space for the floating Focus button and bottom navigation.
            // This lets the final button scroll above the nav instead of sitting
            // underneath it on small Android screens.
            const SizedBox(height: 70),
          ],
        );
      },
    );
  }

  Stream<List<_DbCommunity>> _communitiesStream() {
    final user = _user;
    if (user == null) return Stream.value(const []);

    return _communitiesCollection
        .limit(100)
        .snapshots()
        .map((snapshot) {
      final communities = snapshot.docs
          .map((doc) => _DbCommunity.fromDoc(doc, currentUid: user.uid))
          .toList();

      communities.sort((a, b) {
        if (a.joined != b.joined) return a.joined ? -1 : 1;
        return _timestampMillis(b.updatedAt).compareTo(_timestampMillis(a.updatedAt));
      });
      return communities;
    });
  }

  Future<void> _createCommunityFromInput() async {
    final user = _user;
    if (user == null) {
      _showSnack('Sign in before creating a community.');
      return;
    }

    if (user.isAnonymous && !kDebugAllowGuestSocialAccess) {
      _showSnack('Use a full account before creating communities.');
      return;
    }

    final name = widget.controller.text.trim();
    if (name.isEmpty) {
      _showSnack('Type a community name first.');
      return;
    }

    final displayName = _cleanDisplayName(user.displayName, user.email);
    final tag = _communityTagForName(name);
    final docRef = _communitiesCollection.doc();
    final joinCode = _joinCodeFromId(docRef.id);

    try {
      await docRef.set({
        'name': name,
        'tag': tag,
        'description': 'A community for people working on $name.',
        'ownerUid': user.uid,
        'ownerName': displayName,
        'members': [user.uid],
        'memberCount': 1,
        'joinCode': joinCode,
        'searchText': _communitySearchText(name, tag, 'A community for people working on $name.', joinCode),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _usersCollection.doc(user.uid).set({
        'communityIds': FieldValue.arrayUnion([docRef.id]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      widget.controller.clear();
      _showSnack('$name created. Join code: $joinCode');
    } on FirebaseException catch (error) {
      _showSnack('Create community failed: ${error.message ?? error.code}');
    } catch (error) {
      _showSnack('Create community failed: $error');
    }
  }

  String _communityTagForName(String name) {
    final cleaned = name.trim().toLowerCase();
    if (cleaned.contains('exam') || cleaned.contains('study') || cleaned.contains('midterm')) {
      return 'Study';
    }
    if (cleaned.contains('fit') || cleaned.contains('gym') || cleaned.contains('workout')) {
      return 'Fitness';
    }
    if (cleaned.contains('code') || cleaned.contains('app') || cleaned.contains('project')) {
      return 'Coding';
    }
    if (cleaned.contains('trade') || cleaned.contains('finance')) {
      return 'Trading';
    }
    return 'General';
  }

  String _joinCodeFromId(String id) {
    final cleaned = id.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (cleaned.length <= 6) return cleaned;
    return cleaned.substring(0, 6);
  }

  String _communitySearchText(
    String name,
    String tag,
    String description,
    String joinCode,
  ) {
    return '${name.toLowerCase()} ${tag.toLowerCase()} ${description.toLowerCase()} ${joinCode.toLowerCase()}';
  }

  Future<void> _showJoinCodeDialog() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Join with code'),
          content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Community code',
              hintText: 'Example: ABC123',
            ),
            onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    final cleanedCode = code?.trim().toUpperCase();
    if (cleanedCode == null || cleanedCode.isEmpty) return;

    try {
      final snapshot = await _communitiesCollection
          .where('joinCode', isEqualTo: cleanedCode)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        _showSnack('No community found for code $cleanedCode.');
        return;
      }

      final user = _user;
      if (user == null) return;
      await _joinCommunity(
        _DbCommunity.fromDoc(snapshot.docs.first, currentUid: user.uid),
      );
    } on FirebaseException catch (error) {
      _showSnack('Join failed: ${error.message ?? error.code}');
    } catch (error) {
      _showSnack('Join failed: $error');
    }
  }

  Future<void> _joinCommunity(_DbCommunity community) async {
    final user = _user;
    if (user == null) {
      _showSnack('Sign in before joining a community.');
      return;
    }

    if (user.isAnonymous && !kDebugAllowGuestSocialAccess) {
      _showSnack('Use a full account before joining communities.');
      return;
    }

    if (community.joined) {
      _showSnack('You already joined ${community.name}.');
      return;
    }

    final ref = _communitiesCollection.doc(community.id);
    try {
      final didJoin = await _db.runTransaction<bool>((transaction) async {
        final snapshot = await transaction.get(ref);
        if (!snapshot.exists) {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'not-found',
            message: 'Community no longer exists.',
          );
        }

        final data = snapshot.data();
        final members = _stringListFromRaw(data?['members']).toSet();
        if (members.contains(user.uid)) return false;

        members.add(user.uid);
        transaction.update(ref, {
          'members': members.toList(),
          'memberCount': members.length,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return true;
      });

      await _usersCollection.doc(user.uid).set({
        'communityIds': FieldValue.arrayUnion([community.id]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (didJoin) {
        await _addCommunitySystemMessage(
          communityId: community.id,
          text: '${_cleanDisplayName(user.displayName, user.email)} has joined',
          eventType: 'join',
        );
      }

      _showSnack('Joined ${community.name}.');
    } on FirebaseException catch (error) {
      _showSnack('Join failed: ${error.message ?? error.code}');
    } catch (error) {
      _showSnack('Join failed: $error');
    }
  }

  Future<void> _addCommunitySystemMessage({
    required String communityId,
    required String text,
    required String eventType,
  }) async {
    final user = _user;
    if (user == null) return;

    final displayName = _cleanDisplayName(user.displayName, user.email);
    final communityRef = _communitiesCollection.doc(communityId);
    final messageRef = communityRef.collection('messages').doc();
    final batch = _db.batch();

    batch.set(messageRef, {
      'type': 'system',
      'eventType': eventType,
      'senderUid': user.uid,
      'senderName': displayName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.set(
      communityRef,
      {
        'lastMessage': text,
        'lastSenderUid': user.uid,
        'lastSenderName': displayName,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<void> _deleteOrLeaveCommunity(_DbCommunity community) async {
    final user = _user;
    if (user == null) {
      _showSnack('Sign in first.');
      return;
    }

    final isOwner = community.ownerUid == user.uid;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isOwner ? 'Delete community?' : 'Leave community?'),
          content: Text(
            isOwner
                ? 'This deletes ${community.name} for everyone.'
                : 'This removes ${community.name} from your community list.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(isOwner ? 'Delete' : 'Leave'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final ref = _communitiesCollection.doc(community.id);
    try {
      if (isOwner) {
        await ref.delete();
      } else {
        final displayName = _cleanDisplayName(user.displayName, user.email);
        final leaveText = '$displayName has left';

        await _db.runTransaction((transaction) async {
          final snapshot = await transaction.get(ref);
          if (!snapshot.exists) return;

          final members = _stringListFromRaw(snapshot.data()?['members']).toSet();
          if (!members.contains(user.uid)) return;

          members.remove(user.uid);

          final messageRef = ref.collection('messages').doc();
          transaction.set(messageRef, {
            'type': 'system',
            'eventType': 'leave',
            'senderUid': user.uid,
            'senderName': displayName,
            'text': leaveText,
            'createdAt': FieldValue.serverTimestamp(),
          });

          transaction.update(ref, {
            'members': members.toList(),
            'memberCount': members.length,
            'lastMessage': leaveText,
            'lastSenderUid': user.uid,
            'lastSenderName': displayName,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        });
      }

      await _usersCollection.doc(user.uid).set({
        'communityIds': FieldValue.arrayRemove([community.id]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _showSnack(isOwner ? '${community.name} deleted.' : 'Left ${community.name}.');
    } on FirebaseException catch (error) {
      _showSnack('Community update failed: ${error.message ?? error.code}');
    } catch (error) {
      _showSnack('Community update failed: $error');
    }
  }

  Widget _buildCommunitiesTab(BuildContext context) {
    return StreamBuilder<List<_DbCommunity>>(
      stream: _communitiesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return HelpfulErrorBox(
            title: 'Communities failed to load',
            message:
                'Check Firestore rules for communities reads. Details: ${snapshot.error}',
            actionLabel: 'OK',
            showAction: false,
          );
        }

        final groups = snapshot.data ?? const <_DbCommunity>[];
        final joined = groups.where((group) => group.joined).toList();
        final leaderboard = [...groups]
          ..sort((a, b) => b.members.compareTo(a.members));
        final topThree = leaderboard.take(3).toList();
        final communityPreview = joined.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create or join community',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w900, color: gdInk),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: widget.controller,
                      decoration: const InputDecoration(
                        labelText: 'Create a community',
                        hintText: 'Example: Midterm study group',
                      ),
                      onSubmitted: (_) => unawaited(_createCommunityFromInput()),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => unawaited(_createCommunityFromInput()),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Create'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => unawaited(_showJoinCodeDialog()),
                            icon: const Icon(Icons.login_rounded),
                            label: const Text('Join with code'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SectionTitle(title: 'Community streak leaderboard', trailing: 'TOP 3'),
            const SizedBox(height: 10),
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        snapshot.data == null)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      )
                    else if (topThree.isEmpty)
                      const HelpfulErrorBox(
                        title: 'No communities yet',
                        message: 'Create the first real community in Firestore.',
                        actionLabel: 'OK',
                        showAction: false,
                      )
                    else
                      for (var i = 0; i < topThree.length; i++)
                        _CommunityLeaderboardTile(rank: i + 1, group: topThree[i]),
                    if (leaderboard.length > 3) ...[
                      const Divider(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _openCommunityLeaderboardPage(context, leaderboard),
                          icon: const Icon(Icons.emoji_events_rounded),
                          label: const Text('View full leaderboard'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SectionTitle(title: 'My community list', trailing: '${joined.length}'),
            const SizedBox(height: 10),
            if (snapshot.connectionState == ConnectionState.waiting &&
                snapshot.data == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (joined.isEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HelpfulErrorBox(
                    title: 'No joined communities yet',
                    message: 'Find a real Firestore community or create your own group.',
                    actionLabel: 'Got it',
                    showAction: false,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openFindCommunitiesPage(context, groups),
                      icon: const Icon(Icons.travel_explore_rounded),
                      label: const Text('Find communities'),
                    ),
                  ),
                ],
              )
            else ...[
              for (final group in communityPreview)
                _CommunityListCard(
                  group: group,
                  onDetails: () => _openCommunityDetailsPage(context, group),
                  onChat: () => _openCommunityChatPage(context, group),
                  onDelete: () => unawaited(_deleteOrLeaveCommunity(group)),
                ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: gdPrimary,
                    foregroundColor: gdCardLight,
                    side: BorderSide(color: gdPrimary, width: 1.5),
                  ),
                  onPressed: () => _openAllCommunitiesPage(context, joined),
                  icon: const Icon(Icons.groups_rounded),
                  label: Text('View all communities (${joined.length})'),
                ),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 70),
          ],
        );
      },
    );
  }

  void _openFindCommunitiesPage(
    BuildContext context,
    List<_DbCommunity> communities,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FindCommunitiesPage(
          communities: communities,
          onJoin: (group) => unawaited(_joinCommunity(group)),
        ),
      ),
    );
  }

  void _openAllCommunitiesPage(
    BuildContext context,
    List<_DbCommunity> communities,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _AllCommunitiesPage(
          communities: communities,
          onChat: (group) => _openCommunityChatPage(context, group),
          onDetails: (group) => _openCommunityDetailsPage(context, group),
          onDelete: (group) => unawaited(_deleteOrLeaveCommunity(group)),
          onFindCommunities: () => _openFindCommunitiesPage(context, communities),
        ),
      ),
    );
  }

  void _openCommunityLeaderboardPage(
    BuildContext context,
    List<_DbCommunity> leaderboard,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _CommunityLeaderboardPage(leaderboard: leaderboard),
      ),
    );
  }

  void _openFindFriendsPage(BuildContext context,
      [Set<String>? currentFriendUids]) {
    if (!_canUseSocial) {
      _showSnack('Use a full account before finding friends.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FindFriendsPage(
          currentUid: _user?.uid,
          publicProfiles: _publicProfiles,
          currentFriendUids: Set<String>.from(currentFriendUids ?? const <String>{}),
          onProfileDetails: (profile) =>
              _openPublicUserDetailsPage(context, profile),
          onAddFriend: _addFriend,
        ),
      ),
    );
  }

  void _openAllFriendsPage(BuildContext context, List<_FriendProfile> friends) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _AllFriendsPage(
          friends: friends,
          onDetails: (friend) => _openUserDetailsPage(context, friend),
          onChat: (friend) => _openChatPage(context, friend),
          onAdd: (friend) => unawaited(_addFriendFromFriendProfile(friend)),
          onDelete: (friend) => unawaited(_deleteFriend(friend)),
          onFindFriends: () => _openFindFriendsPage(
            context,
            friends.where((friend) => friend.isFriend).map((friend) => friend.uid).toSet(),
          ),
        ),
      ),
    );
  }

  void _openLeaderboardPage(
      BuildContext context, List<_LeaderboardEntry> leaderboard) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => _LeaderboardPage(leaderboard: leaderboard)),
    );
  }

  void _openChatPage(BuildContext context, _FriendProfile friend) {
    if (!_canUseSocial) {
      _showSnack('Use a full account before opening chat.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _DirectChatPage(
          friend: friend,
          onAddFriend: () => _addFriendFromFriendProfile(friend),
        ),
      ),
    );
  }

  _FriendProfile _friendProfileFromPublicProfile(
    _PublicProfile profile, {
    bool isFriend = false,
  }) {
    return _FriendProfile(
      uid: profile.uid,
      displayName: profile.displayName,
      username: profile.username,
      photoUrl: profile.photoUrl,
      streak: profile.streak,
      isReal: true,
      isFriend: isFriend,
      hasChat: false,
      lastMessage: null,
      lastSenderUid: null,
      hasUnread: false,
      chatUpdatedAt: null,
    );
  }

  void _openPublicUserDetailsPage(
    BuildContext context,
    _PublicProfile profile,
  ) {
    _openUserDetailsPage(
      context,
      _friendProfileFromPublicProfile(
        profile,
        isFriend: false,
      ),
    );
  }

  void _openUserDetailsPage(BuildContext context, _FriendProfile profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _UserDetailPage(
          initialProfile: profile,
          currentUid: _user?.uid,
          onChat: (latestProfile) => _openChatPage(context, latestProfile),
          onAdd: profile.isFriend
              ? null
              : (latestProfile) =>
                  unawaited(_addFriendFromFriendProfile(latestProfile)),
          onDelete: profile.isFriend
              ? (latestProfile) => unawaited(_deleteFriend(latestProfile))
              : null,
        ),
      ),
    );
  }

  void _openCommunityChatPage(BuildContext context, _DbCommunity group) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _CommunityChatPage(group: group)),
    );
  }

  void _openCommunityDetailsPage(BuildContext context, _DbCommunity group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _CommunityDetailPage(
          initialGroup: group,
          currentUid: _user?.uid ?? '',
          onChat: (latestGroup) => _openCommunityChatPage(context, latestGroup),
          onJoin: (latestGroup) => unawaited(_joinCommunity(latestGroup)),
          onDelete: (latestGroup) => unawaited(_deleteOrLeaveCommunity(latestGroup)),
        ),
      ),
    );
  }
}

class _FullAccountLoginPage extends StatelessWidget {
  const _FullAccountLoginPage();

  Future<void> _handleEmailAuth(
    BuildContext context,
    String email,
    String password,
    String? displayName,
    bool isSignUp,
  ) async {
    final authState = context.read<AuthState>();

    if (isSignUp) {
      await authState.createAccountWithEmail(
        email: email,
        password: password,
        displayName:
            displayName?.trim().isEmpty == true ? null : displayName?.trim(),
      );
    } else {
      await authState.signInWithEmail(email, password);
    }

    if (!context.mounted) return;

    if (authState.isSignedIn) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleGoogle(BuildContext context) async {
    final authState = context.read<AuthState>();
    await authState.signInWithGoogle();

    if (!context.mounted) return;

    if (authState.isSignedIn) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState>(
      builder: (context, authState, _) {
        return Stack(
          children: [
            OnboardingScreen(
              onEmailAuth: (
                email,
                password,
                displayName,
                isSignUp,
              ) =>
                  _handleEmailAuth(
                context,
                email,
                password,
                displayName,
                isSignUp,
              ),
              onPasswordReset: authState.sendPasswordResetEmail,
              onGoogle: () => unawaited(_handleGoogle(context)),
              onGuest: () => Navigator.of(context).pop(),
              onClearError: authState.clearError,
              isLoading: authState.isLoading,
              errorMessage: authState.errorMessage,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: IconButton.filledTonal(
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FriendListCard extends StatelessWidget {
  const _FriendListCard({
    required this.friend,
    required this.onDetails,
    required this.onChat,
    required this.onAdd,
    required this.onDelete,
  });

  final _FriendProfile friend;
  final VoidCallback onDetails;
  final VoidCallback onChat;
  final VoidCallback onAdd;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final subtitle = friend.lastMessageText.isNotEmpty
        ? '${friend.chatLabel} · ${friend.lastMessageText}'
        : '${friend.username} · ${friend.streak} day streak';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: InkResponse(
          onTap: onDetails,
          radius: 28,
          child: _UnreadAvatar(
            photoUrl: friend.photoUrl,
            label: friend.displayName,
            showDot: friend.isChatOnly || friend.hasUnread,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                friend.displayName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            if (friend.isChatOnly) ...[
              const SizedBox(width: 8),
              const Chip(
                visualDensity: VisualDensity.compact,
                label: Text('Chat'),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton.filledTonal(
                  tooltip: 'Chat',
                  onPressed: onChat,
                  icon: const Icon(Icons.chat_bubble_rounded),
                ),
                if (friend.hasUnread)
                  Positioned(
                    right: 5,
                    top: 5,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: gdError,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            if (friend.isFriend)
              IconButton(
                tooltip: 'Delete friend',
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded, color: gdError),
              )
            else
              IconButton(
                tooltip: 'Add friend',
                onPressed: onAdd,
                icon: const Icon(Icons.person_add_alt_1_rounded),
              ),
          ],
        ),
      ),
    );
  }
}

class _AllFriendsPage extends StatefulWidget {
  const _AllFriendsPage({
    required this.friends,
    required this.onDetails,
    required this.onChat,
    required this.onAdd,
    required this.onDelete,
    required this.onFindFriends,
  });

  final List<_FriendProfile> friends;
  final ValueChanged<_FriendProfile> onDetails;
  final ValueChanged<_FriendProfile> onChat;
  final ValueChanged<_FriendProfile> onAdd;
  final ValueChanged<_FriendProfile> onDelete;
  final VoidCallback onFindFriends;

  @override
  State<_AllFriendsPage> createState() => _AllFriendsPageState();
}

class _AllFriendsPageState extends State<_AllFriendsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.friends.where((friend) {
      final q = _query.trim().toLowerCase();
      if (q.isEmpty) return true;
      return friend.displayName.toLowerCase().contains(q) ||
          friend.username.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All friends & chats'),
        actions: [
          IconButton(
            tooltip: 'Find friends',
            onPressed: widget.onFindFriends,
            icon: const Icon(Icons.person_search_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageScaffold(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                labelText: 'Search friends or chats',
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 16),
            for (final friend in filtered)
              _FriendListCard(
                friend: friend,
                onDetails: () => widget.onDetails(friend),
                onChat: () => widget.onChat(friend),
                onAdd: () => widget.onAdd(friend),
                onDelete: friend.isFriend ? () => widget.onDelete(friend) : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _AllCommunitiesPage extends StatefulWidget {
  const _AllCommunitiesPage({
    required this.communities,
    required this.onChat,
    required this.onDetails,
    required this.onDelete,
    required this.onFindCommunities,
  });

  final List<_DbCommunity> communities;
  final ValueChanged<_DbCommunity> onChat;
  final ValueChanged<_DbCommunity> onDetails;
  final ValueChanged<_DbCommunity> onDelete;
  final VoidCallback onFindCommunities;

  @override
  State<_AllCommunitiesPage> createState() => _AllCommunitiesPageState();
}

class _AllCommunitiesPageState extends State<_AllCommunitiesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.communities.where((group) {
      final q = _query.trim().toLowerCase();
      if (q.isEmpty) return true;
      return group.name.toLowerCase().contains(q) ||
          group.tag.toLowerCase().contains(q) ||
          group.description.toLowerCase().contains(q) ||
          group.joinCode.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All communities'),
        actions: [
          IconButton(
            tooltip: 'Find communities',
            onPressed: widget.onFindCommunities,
            icon: const Icon(Icons.travel_explore_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageScaffold(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                labelText: 'Search your communities',
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              const HelpfulErrorBox(
                title: 'No communities found',
                message:
                    'Try a different search or find a new community to join.',
                actionLabel: 'OK',
                showAction: false,
              )
            else
              for (final group in filtered)
                _CommunityListCard(
                  group: group,
                  onDetails: () => widget.onDetails(group),
                  onChat: () => widget.onChat(group),
                  onDelete: () => widget.onDelete(group),
                ),
          ],
        ),
      ),
    );
  }
}

class _FindCommunitiesPage extends StatefulWidget {
  const _FindCommunitiesPage({
    required this.communities,
    required this.onJoin,
  });

  final List<_DbCommunity> communities;
  final ValueChanged<_DbCommunity> onJoin;

  @override
  State<_FindCommunitiesPage> createState() => _FindCommunitiesPageState();
}

class _FindCommunitiesPageState extends State<_FindCommunitiesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final suggestions = [...widget.communities]
      ..sort((a, b) => b.similarity.compareTo(a.similarity));
    final filtered = suggestions.where((group) {
      if (group.joined) return false;
      if (q.isEmpty) return true;
      return group.name.toLowerCase().contains(q) ||
          group.tag.toLowerCase().contains(q) ||
          group.description.toLowerCase().contains(q) ||
          group.joinCode.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Find communities')),
      body: PageScaffold(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
          children: [
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search real communities',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: gdInk),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'These are documents from Firestore communities, not dummy data.',
                      style: TextStyle(
                          color: gdMuted, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        labelText: 'Search communities',
                        hintText: 'Example: design, fitness, exam',
                      ),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SectionTitle(title: 'Community suggestions'),
            const SizedBox(height: 10),
            if (filtered.isEmpty)
              const HelpfulErrorBox(
                title: 'No suggestions found',
                message:
                    'Create a community from the Social page or try another keyword.',
                actionLabel: 'OK',
                showAction: false,
              )
            else
              for (final group in filtered)
                _DbCommunityMatchCard(
                  group: group,
                  onJoin: () {
                    widget.onJoin(group);
                    setState(() {});
                  },
                ),
          ],
        ),
      ),
    );
  }
}

class _FindFriendsPage extends StatefulWidget {
  const _FindFriendsPage({
    required this.currentUid,
    required this.publicProfiles,
    required this.currentFriendUids,
    required this.onProfileDetails,
    required this.onAddFriend,
  });

  final String? currentUid;
  final CollectionReference<Map<String, dynamic>> publicProfiles;
  final Set<String> currentFriendUids;
  final ValueChanged<_PublicProfile> onProfileDetails;
  final Future<void> Function(_PublicProfile profile) onAddFriend;

  @override
  State<_FindFriendsPage> createState() => _FindFriendsPageState();
}

class _FindFriendsPageState extends State<_FindFriendsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _adding = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<List<_PublicProfile>> _profileStream() {
    final q = _query.trim().toLowerCase().replaceAll('@', '');

    return widget.publicProfiles.limit(80).snapshots().map((snapshot) {
      final profiles = snapshot.docs
          .map((doc) => _PublicProfile.fromUserDoc(doc))
          .where((profile) => profile.uid != widget.currentUid)
          .where((profile) => !widget.currentFriendUids.contains(profile.uid))
          .where((profile) => profile.matchesQuery(q))
          .toList();

      profiles.sort((a, b) => a.displayName.compareTo(b.displayName));
      return profiles;
    });
  }

  Future<void> _add(_PublicProfile profile) async {
    if (_adding) return;
    setState(() => _adding = true);
    try {
      await widget.onAddFriend(profile);
      if (mounted) {
        setState(() {
          widget.currentFriendUids.add(profile.uid);
        });
      }
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentUid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Find friends')),
        body: PageScaffold(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: gdPrimarySoft,
                        child: Icon(Icons.lock_outline_rounded,
                            color: gdPrimary, size: 34),
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Sign in required',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: gdInk),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Friend search needs an account so Firestore can check permissions safely.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: gdMuted, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Find friends')),
      body: PageScaffold(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
          children: [
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search users',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: gdInk),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Search real public profile documents from Firestore. Adding someone stores their uid in your users/{uid}.friends list.',
                      style: TextStyle(
                          color: gdMuted, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        labelText: 'Search name, username, or email',
                        hintText: 'Example: maya or @maya',
                      ),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<_PublicProfile>>(
              stream: _profileStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator()));
                }

                if (snapshot.hasError) {
                  return HelpfulErrorBox(
                    title: 'Friend search failed',
                    message:
                        'Check Firestore rules for reading public_profiles. Details: ${snapshot.error}',
                    actionLabel: 'OK',
                    showAction: false,
                  );
                }

                final profiles = snapshot.data ?? [];
                if (profiles.isEmpty) {
                  return const HelpfulErrorBox(
                    title: 'No profiles found',
                    message:
                        'Ask your teammate to sign in and open the Social page once, then search again.',
                    actionLabel: 'OK',
                    showAction: false,
                  );
                }

                return Column(
                  children: [
                    for (final profile in profiles)
                      AppCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: InkResponse(
                            onTap: () => widget.onProfileDetails(profile),
                            radius: 28,
                            child: _Avatar(
                              photoUrl: profile.photoUrl,
                              label: profile.displayName,
                            ),
                          ),
                          title: Text(profile.displayName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w900)),
                          subtitle: Text(
                            '${profile.username} · ${profile.streak} day streak',
                            style: TextStyle(
                                color: gdMuted, fontWeight: FontWeight.w700),
                          ),
                          trailing: FilledButton(
                            onPressed:
                                _adding ? null : () => unawaited(_add(profile)),
                            child: const Text('Add'),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedFriendsPanel extends StatelessWidget {
  const _SuggestedFriendsPanel({
    required this.suggestions,
    required this.currentFriendNames,
    required this.onSearchSuggestion,
  });

  final List<String> suggestions;
  final Set<String> currentFriendNames;
  final ValueChanged<String> onSearchSuggestion;

  @override
  Widget build(BuildContext context) {
    final filtered = suggestions
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .where((name) => !currentFriendNames.contains(name))
        .take(4)
        .toList();

    if (filtered.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Suggestions'),
        const SizedBox(height: 10),
        AppCard(
          child: Column(
            children: [
              for (var i = 0; i < filtered.length; i++) ...[
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: gdPrimarySoft,
                    child: Text(
                      filtered[i].substring(0, 1).toUpperCase(),
                      style: TextStyle(
                          color: gdPrimary, fontWeight: FontWeight.w900),
                    ),
                  ),
                  title: Text(
                    filtered[i],
                    style: TextStyle(
                        fontWeight: FontWeight.w900, color: gdInk),
                  ),
                  subtitle: Text(
                    'Suggested accountability friend',
                    style:
                        TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
                  ),
                  trailing: OutlinedButton(
                    onPressed: () => onSearchSuggestion(filtered[i]),
                    child: const Text('Search'),
                  ),
                ),
                if (i != filtered.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DirectChatPage extends StatefulWidget {
  const _DirectChatPage({
    required this.friend,
    required this.onAddFriend,
  });

  final _FriendProfile friend;
  final Future<void> Function()? onAddFriend;

  @override
  State<_DirectChatPage> createState() => _DirectChatPageState();
}

class _DirectChatPageState extends State<_DirectChatPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationRepository _notificationRepository = NotificationRepository();
  final Uuid _uuid = const Uuid();

  bool _sending = false;
  bool _addingFriend = false;
  bool _addedAsFriend = false;
  bool _chatExists = false;

  @override
  void initState() {
    super.initState();
    _chatExists = widget.friend.hasChat;
    if (_chatExists) {
      unawaited(_markChatRead());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  User? get _user => _auth.currentUser;

  String get _chatId {
    final uid = _user?.uid ?? 'guest';
    final members = [uid, widget.friend.uid]..sort();
    return members.join('_');
  }

  DocumentReference<Map<String, dynamic>> get _chatRef =>
      _db.collection('chats').doc(_chatId);

  CollectionReference<Map<String, dynamic>> get _messages =>
      _chatRef.collection('messages');

  Future<void> _markChatRead() async {
    final uid = _user?.uid;
    if (uid == null || !_chatExists) return;

    try {
      await _chatRef.update({
        'unreadBy': FieldValue.arrayRemove([uid]),
      });
    } catch (_) {
      // Opening a brand-new chat should not create an empty chat document.
    }
  }

  Future<void> _addFriendFromChat() async {
    if (widget.onAddFriend == null || _addingFriend) return;

    setState(() => _addingFriend = true);
    try {
      await widget.onAddFriend!();
      if (mounted) {
        setState(() => _addedAsFriend = true);
      }
    } finally {
      if (mounted) setState(() => _addingFriend = false);
    }
  }

  String _cleanDisplayName(String? displayName, String? email) {
    final fromName = displayName?.trim();
    if (fromName != null && fromName.isNotEmpty) return fromName;

    final fromEmail = email?.split('@').first.trim();
    if (fromEmail != null && fromEmail.isNotEmpty) return fromEmail;

    return 'Goal Digger User';
  }

  Future<void> _send() async {
    final user = _user;
    final text = _controller.text.trim();
    if (user == null) {
      _snack('Sign in before sending chat messages.');
      return;
    }

    if (user.isAnonymous && !kDebugAllowGuestSocialAccess) {
      _snack('Use a full account before sending chat messages.');
      return;
    }
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      final chatRef = _chatRef;
      final memberUids = [user.uid, widget.friend.uid]..sort();

      final chatData = <String, dynamic>{
        'type': 'direct',
        'members': memberUids,
        'memberNames': {
          user.uid: user.displayName ?? 'You',
          widget.friend.uid: widget.friend.displayName,
        },
        'lastMessage': text,
        'lastSenderUid': user.uid,
        'unreadBy': FieldValue.arrayUnion([widget.friend.uid]),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Brand-new chats cannot be read before creation under the chat rules.
      await chatRef.set(chatData, SetOptions(merge: true));
      if (!_chatExists && mounted) {
        setState(() => _chatExists = true);
      }

      await chatRef.update({
        'unreadBy': FieldValue.arrayRemove([user.uid]),
      });

      await chatRef.collection('messages').add({
        'senderUid': user.uid,
        'senderName': user.displayName ?? 'You',
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final senderName = _cleanDisplayName(user.displayName, user.email);
    final preview = text.length > 120 ? '${text.substring(0, 117)}...' : text;

    await _notificationRepository.addSocialNotification(
    recipientUid: widget.friend.uid,
    actorUid: user.uid,
    notification: AppNotification(
        id: _uuid.v4(),
        title: senderName,
        body: preview,
        type: AppNotificationType.chat,
        delivery: NotificationDelivery.inApp,
        createdAt: DateTime.now(),
        important: false,
        sourceId: chatRef.id,
        payload: {
        'actorUid': user.uid,
        'actorName': senderName,
        'route': 'chat',
        'chatId': chatRef.id,
        'senderUid': user.uid,
        },
    ),
    );

      _controller.clear();
    } on FirebaseException catch (error) {
      _snack('Message failed: ${error.message ?? error.code}');
    } catch (error) {
      _snack('Message failed: $error');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Widget _emptyMessagesPrompt() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No messages yet. Send a quick accountability update.',
          textAlign: TextAlign.center,
          style: TextStyle(color: gdMuted, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final currentUid = user?.uid;

    if (user == null || (user.isAnonymous && !kDebugAllowGuestSocialAccess)) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.friend.displayName)),
        body: PageScaffold(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: gdPrimarySoft,
                        child: Icon(Icons.lock_outline_rounded,
                            color: gdPrimary, size: 34),
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Sign in required',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: gdInk),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Chat needs an account so messages can be saved safely.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: gdMuted, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            InkResponse(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _UserDetailPage(
                      initialProfile: widget.friend,
                      currentUid: user.uid,
                      onAdd: widget.onAddFriend == null
                          ? null
                          : (_) => unawaited(_addFriendFromChat()),
                    ),
                  ),
                );
              },
              radius: 24,
              child: _Avatar(
                photoUrl: widget.friend.photoUrl,
                label: widget.friend.displayName,
                radius: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Text(widget.friend.displayName,
                    overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          if (!widget.friend.isFriend && !_addedAsFriend)
            IconButton(
              tooltip: 'Add friend',
              onPressed:
                  _addingFriend ? null : () => unawaited(_addFriendFromChat()),
              icon: _addingFriend
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.person_add_alt_1_rounded),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageScaffold(
        child: Column(
          children: [
            Expanded(
              child: _chatExists
                  ? StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _messages
                          .orderBy('createdAt', descending: true)
                          .limit(60)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: HelpfulErrorBox(
                                title: 'Chat failed to load',
                                message:
                                    'Check Firestore chat rules. Details: ${snapshot.error}',
                                actionLabel: 'OK',
                                showAction: false,
                              ),
                            ),
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return _emptyMessagesPrompt();
                        }

                        return ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].data();
                            final isMine = data['senderUid'] == currentUid;
                            return _MessageBubble(
                              text: data['text']?.toString() ?? '',
                              isMine: isMine,
                              senderName: data['senderName']?.toString() ?? '',
                            );
                          },
                        );
                      },
                    )
                  : _emptyMessagesPrompt(),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                color: gdSurface.withValues(alpha: 0.92),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Message your friend...',
                        ),
                        onSubmitted: (_) => unawaited(_send()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _sending ? null : () => unawaited(_send()),
                      icon: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityListCard extends StatelessWidget {
  const _CommunityListCard({
    required this.group,
    required this.onDetails,
    required this.onChat,
    required this.onDelete,
  });

  final _DbCommunity group;
  final VoidCallback onDetails;
  final VoidCallback onChat;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onDetails,
        leading: InkResponse(
          onTap: onDetails,
          radius: 28,
          child: CircleAvatar(
            backgroundColor: gdPrimarySoft,
            child: Icon(Icons.groups_rounded, color: gdPrimary),
          ),
        ),
        title: Text(group.name,
            style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(
          '${group.members} members · ${group.tag} · code ${group.joinCode}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton.filledTonal(
              tooltip: 'Community chat',
              onPressed: onChat,
              icon: const Icon(Icons.chat_bubble_rounded),
            ),
            IconButton(
              tooltip: group.isOwner ? 'Delete community' : 'Leave community',
              onPressed: onDelete,
              icon: Icon(
                group.isOwner
                    ? Icons.delete_outline_rounded
                    : Icons.logout_rounded,
                color: gdError,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityDetailPage extends StatelessWidget {
  const _CommunityDetailPage({
    required this.initialGroup,
    required this.currentUid,
    required this.onChat,
    required this.onJoin,
    required this.onDelete,
  });

  final _DbCommunity initialGroup;
  final String currentUid;
  final ValueChanged<_DbCommunity> onChat;
  final ValueChanged<_DbCommunity> onJoin;
  final ValueChanged<_DbCommunity> onDelete;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> _communityStream() {
    return _db.collection('communities').doc(initialGroup.id).snapshots();
  }

  Future<List<_CommunityMemberProfile>> _loadMemberProfiles(
    _DbCommunity group,
  ) async {
    final members = group.membersList
        .map((uid) => uid.trim())
        .where((uid) => uid.isNotEmpty)
        .toList();

    if (members.isEmpty) return const [];

    final profilesByUid = <String, _CommunityMemberProfile>{};

    for (final chunk in _memberChunks(members, 10)) {
      final snapshot = await _db
          .collection('public_profiles')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final email = _readString(data, const ['email']);
        final displayName = _readString(
          data,
          const ['displayName', 'name', 'fullName'],
          email.contains('@') ? email.split('@').first : 'Member',
        );
        profilesByUid[doc.id] = _CommunityMemberProfile(
          uid: doc.id,
          displayName: displayName,
          username: _readString(
            data,
            const ['username', 'handle'],
            _fallbackUsernameFor(displayName, email, doc.id),
          ),
          photoUrl: _readNullableString(
            data,
            const ['photoUrl', 'photoURL', 'avatarUrl', 'avatarURL'],
          ),
        );
      }
    }

    return [
      for (final uid in members)
        profilesByUid[uid] ??
            _CommunityMemberProfile(
              uid: uid,
              displayName: 'Member ${_shortId(uid)}',
              username: _shortId(uid),
              photoUrl: null,
            ),
    ];
  }

  List<List<T>> _memberChunks<T>(List<T> values, int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < values.length; i += size) {
      chunks.add(values.sublist(i, min(i + size, values.length)));
    }
    return chunks;
  }

  String _shortId(String value) {
    if (value.length <= 8) return value;
    return '${value.substring(0, 6)}...${value.substring(value.length - 2)}';
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Not saved yet';
    final date = timestamp.toDate().toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  void _openMemberDetails(
    BuildContext context,
    _CommunityMemberProfile member,
  ) {
    final profile = _FriendProfile(
      uid: member.uid,
      displayName: member.displayName,
      username: member.username,
      photoUrl: member.photoUrl,
      streak: 0,
      isReal: true,
      isFriend: false,
      hasChat: false,
      lastMessage: null,
      lastSenderUid: null,
      hasUnread: false,
      chatUpdatedAt: null,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _UserDetailPage(
          initialProfile: profile,
          currentUid: currentUid,
          onChat: (latestProfile) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _DirectChatPage(
                  friend: latestProfile,
                  onAddFriend: null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community info')),
      body: PageScaffold(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _communityStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(18),
                child: HelpfulErrorBox(
                  title: 'Community failed to load',
                  message:
                      'Check Firestore rules for communities reads. Details: ${snapshot.error}',
                  actionLabel: 'OK',
                  showAction: false,
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting &&
                snapshot.data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final doc = snapshot.data;
            if (doc == null || !doc.exists) {
              return const Padding(
                padding: EdgeInsets.all(18),
                child: HelpfulErrorBox(
                  title: 'Community no longer exists',
                  message: 'This community document was deleted from Firestore.',
                  actionLabel: 'OK',
                  showAction: false,
                ),
              );
            }

            final group = _DbCommunity.fromDoc(doc, currentUid: currentUid);

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
              children: [
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: gdPrimarySoft,
                              child: Icon(
                                Icons.groups_rounded,
                                color: gdPrimary,
                                size: 34,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    group.name,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: gdInk,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      Chip(label: Text(group.tag)),
                                      Chip(
                                        label: Text(
                                          group.joined ? 'Joined' : 'Not joined',
                                        ),
                                      ),
                                      if (group.isOwner)
                                        const Chip(label: Text('Owner')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          group.description,
                          style: TextStyle(
                            color: gdMuted,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (group.joined)
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () => onChat(group),
                                  icon: const Icon(Icons.chat_bubble_rounded),
                                  label: const Text('Open chat'),
                                ),
                              )
                            else
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () => onJoin(group),
                                  icon: const Icon(Icons.group_add_rounded),
                                  label: const Text('Join'),
                                ),
                              ),
                            if (group.joined) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => onDelete(group),
                                  icon: Icon(
                                    group.isOwner
                                        ? Icons.delete_outline_rounded
                                        : Icons.logout_rounded,
                                  ),
                                  label: Text(group.isOwner ? 'Delete' : 'Leave'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _CommunityInfoRow(
                          icon: Icons.confirmation_number_rounded,
                          label: 'Join code',
                          value: group.joinCode,
                        ),
                        const Divider(height: 20),
                        _CommunityInfoRow(
                          icon: Icons.person_rounded,
                          label: 'Owner',
                          value: group.ownerName,
                        ),
                        const Divider(height: 20),
                        _CommunityInfoRow(
                          icon: Icons.badge_rounded,
                          label: 'Owner UID',
                          value: _shortId(group.ownerUid),
                        ),
                        const Divider(height: 20),
                        _CommunityInfoRow(
                          icon: Icons.people_rounded,
                          label: 'Members',
                          value: '${group.members}',
                        ),
                        const Divider(height: 20),
                        _CommunityInfoRow(
                          icon: Icons.calendar_month_rounded,
                          label: 'Created',
                          value: _formatTimestamp(group.createdAt),
                        ),
                        const Divider(height: 20),
                        _CommunityInfoRow(
                          icon: Icons.update_rounded,
                          label: 'Updated',
                          value: _formatTimestamp(group.updatedAt),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SectionTitle(title: 'Members', trailing: '${group.members}'),
                const SizedBox(height: 10),
                FutureBuilder<List<_CommunityMemberProfile>>(
                  future: _loadMemberProfiles(group),
                  builder: (context, memberSnapshot) {
                    if (memberSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final members = memberSnapshot.data ?? const [];
                    if (members.isEmpty) {
                      return const HelpfulErrorBox(
                        title: 'No members found',
                        message: 'The members array is currently empty.',
                        actionLabel: 'OK',
                        showAction: false,
                      );
                    }

                    return Column(
                      children: [
                        for (final member in members)
                          AppCard(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              onTap: () => _openMemberDetails(context, member),
                              leading: InkResponse(
                                onTap: () => _openMemberDetails(context, member),
                                radius: 28,
                                child: _Avatar(
                                  photoUrl: member.photoUrl,
                                  label: member.displayName,
                                ),
                              ),
                              title: Text(
                                member.displayName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900),
                              ),
                              subtitle: Text(
                                member.username,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: gdMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              trailing: Wrap(
                                spacing: 6,
                                children: [
                                  if (member.uid == group.ownerUid)
                                    const Chip(label: Text('Owner')),
                                  if (member.uid == currentUid)
                                    const Chip(label: Text('You')),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


class _UserDetailPage extends StatelessWidget {
  const _UserDetailPage({
    required this.initialProfile,
    required this.currentUid,
    this.onChat,
    this.onAdd,
    this.onDelete,
  });

  final _FriendProfile initialProfile;
  final String? currentUid;
  final ValueChanged<_FriendProfile>? onChat;
  final ValueChanged<_FriendProfile>? onAdd;
  final ValueChanged<_FriendProfile>? onDelete;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> _profileStream() {
    return _db.collection('public_profiles').doc(initialProfile.uid).snapshots();
  }

  _FriendProfile _profileFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>>? snapshot,
  ) {
    if (snapshot == null || !snapshot.exists) return initialProfile;

    return _FriendProfile.fromUserDoc(
      snapshot,
      fallbackName: initialProfile.displayName,
      fallbackUsername: initialProfile.username,
      fallbackPhotoUrl: initialProfile.photoUrl,
      fallbackStreak: initialProfile.streak,
      isFriend: initialProfile.isFriend,
      hasChat: initialProfile.hasChat,
      lastMessage: initialProfile.lastMessage,
      lastSenderUid: initialProfile.lastSenderUid,
      hasUnread: initialProfile.hasUnread,
      chatUpdatedAt: initialProfile.chatUpdatedAt,
    );
  }

  String _shortId(String value) {
    if (value.length <= 12) return value;
    return '${value.substring(0, 8)}...${value.substring(value.length - 4)}';
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Not saved yet';
    final date = timestamp.toDate().toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile info')),
      body: PageScaffold(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _profileStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(18),
                child: HelpfulErrorBox(
                  title: 'Profile failed to load',
                  message:
                      'Check Firestore rules for public_profiles reads. Details: ${snapshot.error}',
                  actionLabel: 'OK',
                  showAction: false,
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting &&
                snapshot.data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final doc = snapshot.data;
            final data = doc?.data() ?? const <String, dynamic>{};
            final profile = _profileFromSnapshot(doc);
            final isMe = currentUid != null && currentUid == profile.uid;
            final createdAt = data['createdAt'];
            final updatedAt = data['updatedAt'];
            final hasPublicProfile = doc?.exists ?? false;
            final canShowActions = !isMe &&
                (onChat != null ||
                    (!profile.isFriend && onAdd != null) ||
                    (profile.isFriend && onDelete != null));

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
              children: [
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        _Avatar(
                          photoUrl: profile.photoUrl,
                          label: profile.displayName,
                          radius: 44,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          profile.displayName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: gdInk,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          profile.username,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: gdMuted,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            if (isMe) const Chip(label: Text('You')),
                            if (profile.isFriend)
                              const Chip(label: Text('Friend')),
                            if (profile.isChatOnly)
                              const Chip(label: Text('Chat request')),
                            if (!hasPublicProfile)
                              const Chip(label: Text('Fallback profile')),
                          ],
                        ),
                        if (canShowActions) ...[
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              if (onChat != null) ...[
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () => onChat!(profile),
                                    icon: const Icon(Icons.chat_bubble_rounded),
                                    label: const Text('Message'),
                                  ),
                                ),
                              ],
                              if (!profile.isFriend && onAdd != null) ...[
                                if (onChat != null) const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => onAdd!(profile),
                                    icon: const Icon(Icons.person_add_alt_1_rounded),
                                    label: const Text('Add friend'),
                                  ),
                                ),
                              ],
                              if (profile.isFriend && onDelete != null) ...[
                                if (onChat != null) const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => onDelete!(profile),
                                    icon: const Icon(Icons.delete_outline_rounded),
                                    label: const Text('Remove'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _CommunityInfoRow(
                          icon: Icons.badge_rounded,
                          label: 'User UID',
                          value: _shortId(profile.uid),
                        ),
                        const Divider(height: 20),
                        _CommunityInfoRow(
                          icon: Icons.alternate_email_rounded,
                          label: 'Username',
                          value: profile.username,
                        ),
                        const Divider(height: 20),
                        _CommunityInfoRow(
                          icon: Icons.local_fire_department_rounded,
                          label: 'Streak',
                          value: '${profile.streak} day streak',
                        ),
                        const Divider(height: 20),
                        _CommunityInfoRow(
                          icon: Icons.verified_user_rounded,
                          label: 'Profile source',
                          value: hasPublicProfile
                              ? 'public_profiles/${profile.uid}'
                              : 'Fallback from chat/member data',
                        ),
                        if (profile.lastMessageText.isNotEmpty) ...[
                          const Divider(height: 20),
                          _CommunityInfoRow(
                            icon: Icons.chat_bubble_rounded,
                            label: 'Last chat',
                            value: profile.lastMessageText,
                          ),
                        ],
                        const Divider(height: 20),
                        _CommunityInfoRow(
                          icon: Icons.calendar_month_rounded,
                          label: 'Created',
                          value: _formatTimestamp(
                            createdAt is Timestamp ? createdAt : null,
                          ),
                        ),
                        const Divider(height: 20),
                        _CommunityInfoRow(
                          icon: Icons.update_rounded,
                          label: 'Updated',
                          value: _formatTimestamp(
                            updatedAt is Timestamp ? updatedAt : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CommunityInfoRow extends StatelessWidget {
  const _CommunityInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: gdPrimarySoft,
          child: Icon(icon, color: gdPrimary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: gdMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              SelectableText(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  color: gdInk,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommunityMemberProfile {
  const _CommunityMemberProfile({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.photoUrl,
  });

  final String uid;
  final String displayName;
  final String username;
  final String? photoUrl;
}

class _CommunityChatPage extends StatefulWidget {
  const _CommunityChatPage({required this.group});

  final _DbCommunity group;

  @override
  State<_CommunityChatPage> createState() => _CommunityChatPageState();
}

class _CommunityChatPageState extends State<_CommunityChatPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  User? get _user => _auth.currentUser;

  DocumentReference<Map<String, dynamic>> get _communityRef =>
      _db.collection('communities').doc(widget.group.id);

  CollectionReference<Map<String, dynamic>> get _messages =>
      _communityRef.collection('messages');

  bool get _isMember {
    final uid = _user?.uid;
    if (uid == null) return false;
    return widget.group.membersList.contains(uid);
  }

  Future<void> _send() async {
    final user = _user;
    final text = _controller.text.trim();

    if (user == null) {
      _snack('Sign in before sending community messages.');
      return;
    }

    if (user.isAnonymous && !kDebugAllowGuestSocialAccess) {
      _snack('Use a full account before sending community messages.');
      return;
    }

    if (!_isMember) {
      _snack('Join this community before sending messages.');
      return;
    }

    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      final displayName = user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : user.email?.split('@').first.trim() ?? 'Member';

      final messageRef = _messages.doc();
      final batch = _db.batch();

      batch.set(messageRef, {
        'senderUid': user.uid,
        'senderName': displayName,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      batch.set(
        _communityRef,
        {
          'lastMessage': text,
          'lastSenderUid': user.uid,
          'lastSenderName': displayName,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await batch.commit();
      _controller.clear();
    } on FirebaseException catch (error) {
      _snack('Community message failed: ${error.message ?? error.code}');
    } catch (error) {
      _snack('Community message failed: $error');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final currentUid = user?.uid;

    if (user == null || (user.isAnonymous && !kDebugAllowGuestSocialAccess)) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.group.name} chat')),
        body: PageScaffold(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: gdPrimarySoft,
                        child: Icon(Icons.lock_outline_rounded,
                            color: gdPrimary, size: 34),
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Sign in required',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: gdInk),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Community chat needs an account so messages can be saved safely.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: gdMuted, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: gdPrimarySoft,
              child: Icon(Icons.groups_rounded, color: gdPrimary, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${widget.group.name} chat',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: PageScaffold(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _messages
                    .orderBy('createdAt', descending: true)
                    .limit(100)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: HelpfulErrorBox(
                          title: 'Community chat failed to load',
                          message:
                              'Check Firestore rules for communities/{communityId}/messages. Details: ${snapshot.error}',
                          actionLabel: 'OK',
                          showAction: false,
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting &&
                      snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: AppCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 34,
                                  backgroundColor: gdPrimarySoft,
                                  child: Icon(Icons.forum_rounded,
                                      color: gdPrimary, size: 34),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  widget.group.name,
                                  style:
                                      GdText.headlineMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${widget.group.members} members · code ${widget.group.joinCode}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: gdMuted,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No community messages yet. Start the first update for the group.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: gdMuted,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data();
                      final text = data['text']?.toString() ?? '';
                      final isSystemMessage = data['type'] == 'system' ||
                          data['eventType'] == 'join' ||
                          data['eventType'] == 'leave';

                      if (isSystemMessage) {
                        return _SystemMessageBubble(text: text);
                      }

                      final isMine = data['senderUid'] == currentUid;
                      return _MessageBubble(
                        text: text,
                        isMine: isMine,
                        senderName: data['senderName']?.toString() ?? '',
                      );
                    },
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                color: gdSurface.withValues(alpha: 0.92),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: _isMember,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: _isMember
                              ? 'Message the community...'
                              : 'Join this community to chat',
                        ),
                        onSubmitted: (_) => unawaited(_send()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed:
                          !_isMember || _sending ? null : () => unawaited(_send()),
                      icon: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityLeaderboardPage extends StatelessWidget {
  const _CommunityLeaderboardPage({required this.leaderboard});

  final List<_DbCommunity> leaderboard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community leaderboard')),
      body: PageScaffold(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
          children: [
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    for (var i = 0; i < leaderboard.length; i++)
                      _CommunityLeaderboardTile(
                          rank: i + 1, group: leaderboard[i]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityLeaderboardTile extends StatelessWidget {
  const _CommunityLeaderboardTile({required this.rank, required this.group});

  final int rank;
  final _DbCommunity group;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: rank == 1 ? gdAccentSoft : gdPrimarySoft,
        child:
            Text('#$rank', style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      title:
          Text(group.name, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(
        '${group.members} members · ${group.tag}',
        style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
      ),
      trailing: Chip(label: Text(group.joined ? 'Joined' : '${group.similarity}% fit')),
    );
  }
}

class _LeaderboardPage extends StatelessWidget {
  const _LeaderboardPage({required this.leaderboard});

  final List<_LeaderboardEntry> leaderboard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: PageScaffold(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
          children: [
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    for (var i = 0; i < leaderboard.length; i++)
                      _LeaderboardTile(rank: i + 1, entry: leaderboard[i]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({required this.rank, required this.entry});

  final int rank;
  final _LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: rank == 1 ? gdAccentSoft : gdPrimarySoft,
        child:
            Text('#$rank', style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      title: Text(
        entry.name,
        style: TextStyle(
            fontWeight: FontWeight.w900,
            color: entry.isYou ? gdPrimaryDark : gdInk),
      ),
      trailing: Chip(label: Text('${entry.streak} day streak')),
    );
  }
}

class _SystemMessageBubble extends StatelessWidget {
  const _SystemMessageBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return const SizedBox.shrink();

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: gdSurface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: gdPrimarySoft),
        ),
        child: Text(
          cleaned,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: gdMuted,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.text,
    required this.isMine,
    required this.senderName,
  });

  final String text;
  final bool isMine;
  final String senderName;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? gdPrimary : gdSurface,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: isMine ? const Radius.circular(4) : null,
            bottomLeft: isMine ? null : const Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMine && senderName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  senderName,
                  style: TextStyle(
                      color: gdMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w900),
                ),
              ),
            Text(
              text,
              style: TextStyle(
                  color: isMine ? Colors.white : gdInk,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar(
      {required this.photoUrl, required this.label, this.radius = 22});

  final String? photoUrl;
  final String label;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(radius: radius, backgroundImage: NetworkImage(url));
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: gdPrimarySoft,
      child: Text(
        label.trim().isEmpty ? '?' : label.trim().substring(0, 1).toUpperCase(),
        style: TextStyle(color: gdPrimary, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _UnreadAvatar extends StatelessWidget {
  const _UnreadAvatar({
    required this.photoUrl,
    required this.label,
    required this.showDot,
  });

  final String? photoUrl;
  final String label;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _Avatar(photoUrl: photoUrl, label: label),
        if (showDot)
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: gdError,
                shape: BoxShape.circle,
                border: Border.all(color: gdCardLight, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}


class _DbCommunity {
  const _DbCommunity({
    required this.id,
    required this.name,
    required this.tag,
    required this.description,
    required this.ownerUid,
    required this.ownerName,
    required this.joinCode,
    required this.membersList,
    required this.memberCount,
    required this.joined,
    required this.isOwner,
    required this.similarity,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String tag;
  final String description;
  final String ownerUid;
  final String ownerName;
  final String joinCode;
  final List<String> membersList;
  final int memberCount;
  final bool joined;
  final bool isOwner;
  final int similarity;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  int get members => max(memberCount, membersList.length);

  factory _DbCommunity.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String currentUid,
  }) {
    final data = doc.data() ?? {};
    final name = _readString(data, const ['name', 'title'], 'Untitled community');
    final tag = _readString(data, const ['tag', 'category'], 'General');
    final description = _readString(
      data,
      const ['description', 'about'],
      'No description yet.',
    );
    final members = _stringListFromRaw(data['members']);
    final memberCount = _readInt(
      data,
      const ['memberCount', 'membersCount', 'members'],
      members.length,
    );
    final ownerUid = _readString(data, const ['ownerUid', 'createdByUid', 'creatorUid']);
    final joinCode = _readString(
      data,
      const ['joinCode', 'code'],
      _fallbackJoinCode(doc.id),
    ).toUpperCase();
    final createdAt = data['createdAt'];
    final updatedAt = data['updatedAt'];

    return _DbCommunity(
      id: doc.id,
      name: name,
      tag: tag,
      description: description,
      ownerUid: ownerUid,
      ownerName: _readString(data, const ['ownerName', 'createdByName'], 'Owner'),
      joinCode: joinCode,
      membersList: members,
      memberCount: memberCount,
      joined: members.contains(currentUid),
      isOwner: ownerUid == currentUid,
      similarity: _readInt(data, const ['similarity', 'match'], 80),
      createdAt: createdAt is Timestamp ? createdAt : null,
      updatedAt: updatedAt is Timestamp ? updatedAt : null,
    );
  }

  CommunityGroup toCommunityGroup({bool? joined}) {
    return CommunityGroup(
      name: name,
      members: members,
      tag: tag,
      description: description,
      similarity: similarity,
      joined: joined ?? this.joined,
    );
  }
}

class _DbCommunityMatchCard extends StatelessWidget {
  const _DbCommunityMatchCard({
    required this.group,
    required this.onJoin,
  });

  final _DbCommunity group;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(group.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 16)),
                ),
                Chip(label: Text('${group.similarity}% match')),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${group.members} members · ${group.tag} · code ${group.joinCode}',
              style:
                  TextStyle(color: gdMuted, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(group.description,
                style: TextStyle(
                    color: gdMuted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: group.joined
                  ? const OutlinedButton(
                      onPressed: null, child: Text('Already joined'))
                  : FilledButton.icon(
                      onPressed: onJoin,
                      icon: const Icon(Icons.group_add_rounded),
                      label: const Text('Join community'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendProfile {
  const _FriendProfile({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.photoUrl,
    required this.streak,
    required this.isReal,
    required this.isFriend,
    required this.hasChat,
    required this.lastMessage,
    required this.lastSenderUid,
    required this.hasUnread,
    required this.chatUpdatedAt,
  });

  final String uid;
  final String displayName;
  final String username;
  final String? photoUrl;
  final int streak;
  final bool isReal;
  final bool isFriend;
  final bool hasChat;
  final String? lastMessage;
  final String? lastSenderUid;
  final bool hasUnread;
  final Timestamp? chatUpdatedAt;

  bool get isChatOnly => hasChat && !isFriend;

  String get lastMessageText => lastMessage?.trim() ?? '';

  String get chatLabel {
    if (hasUnread) return 'New message';
    if (isChatOnly) return 'Chat request';
    if (hasChat) return 'Last chat';
    return username;
  }

  factory _FriendProfile.fromUserDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    String? fallbackName,
    String? fallbackUsername,
    String? fallbackPhotoUrl,
    int fallbackStreak = 0,
    bool isFriend = true,
    bool hasChat = false,
    String? lastMessage,
    String? lastSenderUid,
    bool hasUnread = false,
    Timestamp? chatUpdatedAt,
  }) {
    final data = doc.data() ?? {};
    final email = _readString(data, const ['email']);
    final displayName = _readString(
      data,
      const ['displayName', 'name', 'fullName'],
      fallbackName ??
          (email.contains('@') ? email.split('@').first : 'Friend'),
    );
    final username = _readString(
      data,
      const ['username', 'handle'],
      fallbackUsername ?? _fallbackUsernameFor(displayName, email, doc.id),
    );
    final photoUrl = _readNullableString(
          data,
          const ['photoUrl', 'photoURL', 'avatarUrl', 'avatarURL'],
        ) ??
        fallbackPhotoUrl;
    final streak = _readInt(
      data,
      const ['streak', 'currentStreak', 'streakCount'],
      fallbackStreak,
    );

    return _FriendProfile(
      uid: _readString(data, const ['uid'], doc.id),
      displayName: displayName,
      username: username,
      photoUrl: photoUrl,
      streak: streak,
      isReal: true,
      isFriend: isFriend,
      hasChat: hasChat,
      lastMessage: lastMessage,
      lastSenderUid: lastSenderUid,
      hasUnread: hasUnread,
      chatUpdatedAt: chatUpdatedAt,
    );
  }

  factory _FriendProfile.fromChatSummary(
    _DirectChatSummary summary, {
    required bool isFriend,
  }) {
    final displayName = summary.otherName?.trim().isNotEmpty == true
        ? summary.otherName!.trim()
        : 'Chat user';

    return _FriendProfile(
      uid: summary.otherUid,
      displayName: displayName,
      username: _fallbackUsernameFor(displayName, '', summary.otherUid),
      photoUrl: null,
      streak: 0,
      isReal: true,
      isFriend: isFriend,
      hasChat: true,
      lastMessage: summary.lastMessage,
      lastSenderUid: summary.lastSenderUid,
      hasUnread: summary.hasUnread,
      chatUpdatedAt: summary.updatedAt,
    );
  }
}

class _DirectChatSummary {
  const _DirectChatSummary({
    required this.otherUid,
    required this.otherName,
    required this.lastMessage,
    required this.lastSenderUid,
    required this.hasUnread,
    required this.updatedAt,
  });

  final String otherUid;
  final String? otherName;
  final String? lastMessage;
  final String? lastSenderUid;
  final bool hasUnread;
  final Timestamp? updatedAt;

  static _DirectChatSummary? fromChatDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String currentUid,
  ) {
    final data = doc.data() ?? {};
    if (data['type'] != null && data['type'] != 'direct') return null;

    final rawMembers = data['members'];
    if (rawMembers is! Iterable) return null;

    final members = rawMembers
        .map((member) => member.toString().trim())
        .where((member) => member.isNotEmpty)
        .toList();

    if (!members.contains(currentUid)) return null;

    final otherUid = members.firstWhere(
      (member) => member != currentUid,
      orElse: () => '',
    );
    if (otherUid.isEmpty) return null;

    final rawNames = data['memberNames'];
    String? otherName;
    if (rawNames is Map) {
      otherName = rawNames[otherUid]?.toString();
    }

    final unreadBy = data['unreadBy'];
    final hasUnread = unreadBy is Iterable &&
        unreadBy.map((uid) => uid.toString()).contains(currentUid);

    final updatedAt = data['updatedAt'];

    return _DirectChatSummary(
      otherUid: otherUid,
      otherName: otherName,
      lastMessage: data['lastMessage']?.toString(),
      lastSenderUid: data['lastSenderUid']?.toString(),
      hasUnread: hasUnread,
      updatedAt: updatedAt is Timestamp ? updatedAt : null,
    );
  }
}

class _FriendsData {
  const _FriendsData({
    required this.currentUser,
    required this.friends,
  });

  final _FriendProfile currentUser;
  final List<_FriendProfile> friends;
}

class _PublicProfile {
  const _PublicProfile({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.photoUrl,
    required this.streak,
    required this.searchText,
  });

  final String uid;
  final String displayName;
  final String username;
  final String? photoUrl;
  final int streak;
  final String searchText;

  factory _PublicProfile.fromUserDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final email = _readString(data, const ['email']);
    final displayName = _readString(
      data,
      const ['displayName', 'name', 'fullName'],
      email.contains('@') ? email.split('@').first : 'Goal Digger User',
    );
    final username = _readString(
      data,
      const ['username', 'handle'],
      _fallbackUsernameFor(displayName, email, doc.id),
    );
    final photoUrl = _readNullableString(
      data,
      const ['photoUrl', 'photoURL', 'avatarUrl', 'avatarURL'],
    );
    final streak = _readInt(
      data,
      const ['streak', 'currentStreak', 'streakCount'],
      0,
    );
    final searchText = _readString(
      data,
      const ['searchName', 'searchText'],
      '${displayName.toLowerCase()} ${username.toLowerCase()} ${username.toLowerCase().replaceAll('@', '')} ${email.toLowerCase()}',
    );

    return _PublicProfile(
      uid: _readString(data, const ['uid'], doc.id),
      displayName: displayName,
      username: username,
      photoUrl: photoUrl,
      streak: streak,
      searchText: searchText.toLowerCase(),
    );
  }

  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase().replaceAll('@', '');
    if (q.isEmpty) return true;
    return searchText.contains(q) ||
        displayName.toLowerCase().contains(q) ||
        username.toLowerCase().contains(q) ||
        username.toLowerCase().replaceAll('@', '').contains(q);
  }
}

class _LeaderboardEntry {
  const _LeaderboardEntry(this.name, this.streak, {this.isYou = false});

  final String name;
  final int streak;
  final bool isYou;
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? gdPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : gdMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                  color: selected ? Colors.white : gdInk,
                  fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class FriendSuggestionCard extends StatelessWidget {
  const FriendSuggestionCard({
    super.key,
    required this.name,
    required this.match,
    required this.onAdd,
  });

  final String name;
  final int match;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: gdPrimarySoft,
          child: Icon(Icons.person_search_rounded, color: gdPrimary),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(
          '$match% similar goals · active this week',
          style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
        ),
        trailing: FilledButton(onPressed: onAdd, child: const Text('Add')),
      ),
    );
  }
}

class CommunityMatchCard extends StatelessWidget {
  const CommunityMatchCard({
    super.key,
    required this.group,
    required this.onJoin,
  });

  final CommunityGroup group;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(group.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 16)),
                ),
                Chip(label: Text('${group.similarity}% match')),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${group.members} members · ${group.tag}',
              style:
                  TextStyle(color: gdMuted, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(group.description,
                style: TextStyle(
                    color: gdMuted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: group.joined
                  ? const OutlinedButton(
                      onPressed: null, child: Text('Already joined'))
                  : FilledButton.icon(
                      onPressed: onJoin,
                      icon: const Icon(Icons.group_add_rounded),
                      label: const Text('Join community'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> _stringListFromRaw(dynamic raw) {
  if (raw is! Iterable) return const [];

  return raw
      .map((value) => value.toString().trim())
      .where((value) => value.isNotEmpty)
      .toList();
}

String _fallbackJoinCode(String id) {
  final cleaned = id.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
  if (cleaned.length <= 6) return cleaned;
  return cleaned.substring(0, 6);
}

String _readString(
  Map<String, dynamic> data,
  List<String> keys, [
  String fallback = '',
]) {
  for (final key in keys) {
    final value = data[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return fallback;
}

String? _readNullableString(Map<String, dynamic> data, List<String> keys) {
  final value = _readString(data, keys);
  return value.isEmpty ? null : value;
}

int _readInt(
  Map<String, dynamic> data,
  List<String> keys, [
  int fallback = 0,
]) {
  for (final key in keys) {
    final value = data[key];
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return fallback;
}

String _fallbackUsernameFor(String displayName, String email, String uid) {
  final source = email.contains('@') ? email.split('@').first : displayName;
  final cleaned = source
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  if (cleaned.isEmpty) {
    return '@user_${uid.substring(0, min(6, uid.length))}';
  }

  return cleaned.startsWith('@') ? cleaned : '@$cleaned';
}
