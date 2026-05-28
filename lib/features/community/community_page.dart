import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/gd_colors.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';

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
  final TextEditingController _communitySearchController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    unawaited(_ensurePublicProfile());
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
    _communitySearchController.dispose();
    super.dispose();
  }

  User? get _user => _auth.currentUser;

  CollectionReference<Map<String, dynamic>> get _publicProfiles =>
      _db.collection('public_profiles');

  CollectionReference<Map<String, dynamic>>? get _myFriendsCollection {
    final uid = _user?.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('friends');
  }

  Future<void> _ensurePublicProfile() async {
    final user = _user;
    if (user == null) return;

    final displayName = _cleanDisplayName(user.displayName, user.email);
    final username = _usernameFor(displayName, user.email, user.uid);

    await _publicProfiles.doc(user.uid).set({
      'uid': user.uid,
      'displayName': displayName,
      'username': username,
      'photoUrl': user.photoURL,
      'streak': widget.streak,
      'searchName': _searchIndex(displayName, username),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
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
    final base = email?.split('@').first.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_') ??
        displayName.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    final cleaned = base.replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_|_$'), '');
    if (cleaned.isEmpty) return '@user_${uid.substring(0, min(6, uid.length))}';
    return cleaned.startsWith('@') ? cleaned : '@$cleaned';
  }

  String _searchIndex(String displayName, String username) {
    return '${displayName.toLowerCase()} ${username.toLowerCase().replaceAll('@', '')} ${username.toLowerCase()}';
  }

  Stream<List<_FriendProfile>> _friendsStream() {
    final friendsCollection = _myFriendsCollection;
    if (friendsCollection == null) {
      return Stream.value(_fallbackFriends());
    }

    return friendsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final firestoreFriends = snapshot.docs
          .map((doc) => _FriendProfile.fromFriendDoc(doc))
          .where((friend) => friend.displayName.trim().isNotEmpty)
          .toList();

      if (firestoreFriends.isNotEmpty) return firestoreFriends;
      return _fallbackFriends();
    });
  }

  List<_FriendProfile> _fallbackFriends() {
    return widget.friends
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .map((name) => _FriendProfile.demo(name))
        .toList();
  }

  Future<void> _addFriend(_PublicProfile profile) async {
    final user = _user;
    final friendsCollection = _myFriendsCollection;
    if (user == null || friendsCollection == null) {
      _showSnack('Sign in first before adding real friends.');
      return;
    }

    if (profile.uid == user.uid) {
      _showSnack('That is your own profile.');
      return;
    }

    await friendsCollection.doc(profile.uid).set({
      'uid': profile.uid,
      'displayName': profile.displayName,
      'username': profile.username,
      'photoUrl': profile.photoUrl,
      'streak': profile.streak,
      'status': 'accepted',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    widget.onAddFriend(profile.displayName);
    _showSnack('${profile.displayName} added to your friends.');
  }

  Future<void> _deleteFriend(_FriendProfile friend) async {
    final friendsCollection = _myFriendsCollection;
    if (friend.isReal && friendsCollection != null) {
      await friendsCollection.doc(friend.uid).delete();
    }
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
          if (_tab == 0) _buildFriendsTab(context) else _buildCommunitiesTab(context),
        ],
      ),
    );
  }

  Widget _buildFriendsTab(BuildContext context) {
    return StreamBuilder<List<_FriendProfile>>(
      stream: _friendsStream(),
      builder: (context, snapshot) {
        final friends = snapshot.data ?? _fallbackFriends();
        final leaderboard = <_LeaderboardEntry>[
          _LeaderboardEntry('You', widget.streak, isYou: true),
          for (var i = 0; i < friends.length; i++)
            _LeaderboardEntry(
              friends[i].displayName,
              friends[i].streak > 0 ? friends[i].streak : max(2, widget.streak - i + 2),
            ),
        ]..sort((a, b) => b.streak.compareTo(a.streak));

        final topThree = leaderboard.take(3).toList();
        final friendPreview = friends.length > 5 ? friends.take(5).toList() : friends;
        final hasMoreThanFive = friends.length > 0;
        final currentFriendNames = friends.map((friend) => friend.displayName).toSet();

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
                          onPressed: () => _openLeaderboardPage(context, leaderboard),
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
            SectionTitle(title: 'My friends', trailing: '${friends.length}'),
            const SizedBox(height: 10),
            if (friends.isEmpty)
              const HelpfulErrorBox(
                title: 'No friends yet',
                message: 'Add accountability friends from Firestore profiles so progress and chat can sync.',
                actionLabel: 'Got it',
                showAction: false,
              )
            else ...[
              for (final friend in friendPreview)
                _FriendListCard(
                  friend: friend,
                  onChat: () => _openChatPage(context, friend),
                  onDelete: () => unawaited(_deleteFriend(friend)),
                ),
              if (hasMoreThanFive) ...[
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                     style: OutlinedButton.styleFrom(
                      backgroundColor: gdPrimary, // change this
                      foregroundColor: gdCardLight,   // text/icon color
                      side: const BorderSide(color: gdPrimary, width: 1.5),
                    ),
                    onPressed: () => _openAllFriendsPage(context, friends),
                    icon: const Icon(Icons.people_rounded),
                    label: Text('View all friends (${friends.length})'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              // SizedBox(
              //   width: double.infinity,
              //   child: FilledButton.icon(
              //     onPressed: () => _openFindFriendsPage(context, currentFriendNames),
              //     icon: const Icon(Icons.person_search_rounded),
              //     label: const Text('Find friends'),
              //   ),
              // ),
            ],
            if (friends.isEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _openFindFriendsPage(context, currentFriendNames),
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

  Widget _buildCommunitiesTab(BuildContext context) {
    final groups = widget.communities;
    final joined = groups.where((group) => group.joined).toList();
    final suggested = [...groups]..sort((a, b) => b.similarity.compareTo(a.similarity));
    final leaderboard = [...groups]..sort((a, b) => b.members.compareTo(a.members));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create or join community',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: gdInk),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: widget.controller,
                  decoration: const InputDecoration(
                    labelText: 'Create a community',
                    hintText: 'Example: Midterm study group',
                  ),
                  onSubmitted: (_) => widget.onAddCommunity(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: widget.onAddCommunity,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Create'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
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
                for (var i = 0; i < min(3, leaderboard.length); i++)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: gdPrimarySoft,
                      child: Text('#${i + 1}', style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                    title: Text(leaderboard[i].name, style: const TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text(
                      '${leaderboard[i].members} members',
                      style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
                    ),
                    trailing: Chip(label: Text('${leaderboard[i].similarity}% fit')),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        SectionTitle(title: 'My community list', trailing: '${joined.length}'),
        const SizedBox(height: 10),
        if (joined.isEmpty)
          const HelpfulErrorBox(
            title: 'No joined communities yet',
            message: 'Join a suggested community below or create your own group.',
            actionLabel: 'Got it',
            showAction: false,
          )
        else
          for (final group in joined.take(3))
            AppCard(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: gdPrimarySoft,
                  child: Icon(Icons.groups_rounded, color: gdPrimary),
                ),
                title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(
                  '${group.members} members · ${group.tag}',
                  style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
                ),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Community chat',
                      onPressed: () => _openCommunityChatPage(context, group),
                      icon: const Icon(Icons.chat_bubble_rounded),
                    ),
                    IconButton(
                      tooltip: 'Delete community',
                      onPressed: () => widget.onDeleteCommunity(group),
                      icon: const Icon(Icons.delete_outline_rounded, color: gdError),
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 18),
        SectionTitle(title: 'Find communities'),
        const SizedBox(height: 10),
        TextField(
          controller: _communitySearchController,
          decoration: const InputDecoration(
            labelText: 'Search communities',
            hintText: 'Example: design, fitness, exam',
          ),
          onSubmitted: (_) {},
        ),
        const SizedBox(height: 12),
        SectionTitle(title: 'Community suggestions'),
        const SizedBox(height: 10),
        ...suggested.take(5).map(
              (group) => CommunityMatchCard(
                group: group,
                onJoin: () => widget.onJoinCommunity(group),
              ),
            ),
      ],
    );
  }

  void _openFindFriendsPage(BuildContext context, [Set<String>? currentFriendNames]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FindFriendsPage(
          currentUid: _user?.uid,
          publicProfiles: _publicProfiles,
          friendSuggestions: widget.friendSuggestions,
          currentFriendNames: currentFriendNames ?? _fallbackFriends().map((friend) => friend.displayName).toSet(),
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
          onChat: (friend) => _openChatPage(context, friend),
          onDelete: (friend) => unawaited(_deleteFriend(friend)),
          onFindFriends: () => _openFindFriendsPage(
            context,
            friends.map((friend) => friend.displayName).toSet(),
          ),
        ),
      ),
    );
  }

  void _openLeaderboardPage(BuildContext context, List<_LeaderboardEntry> leaderboard) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _LeaderboardPage(leaderboard: leaderboard)),
    );
  }

  void _openChatPage(BuildContext context, _FriendProfile friend) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _DirectChatPage(friend: friend)),
    );
  }

  void _openCommunityChatPage(BuildContext context, CommunityGroup group) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _CommunityChatPage(group: group)),
    );
  }
}

class _FriendListCard extends StatelessWidget {
  const _FriendListCard({
    required this.friend,
    required this.onChat,
    required this.onDelete,
  });

  final _FriendProfile friend;
  final VoidCallback onChat;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: _Avatar(photoUrl: friend.photoUrl, label: friend.displayName),
        title: Text(friend.displayName, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(
          '${friend.username} · ${friend.streak} day streak',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton.filledTonal(
              tooltip: 'Chat',
              onPressed: onChat,
              icon: const Icon(Icons.chat_bubble_rounded),
            ),
            IconButton(
              tooltip: 'Delete friend',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, color: gdError),
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
    required this.onChat,
    required this.onDelete,
    required this.onFindFriends,
  });

  final List<_FriendProfile> friends;
  final ValueChanged<_FriendProfile> onChat;
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
      return friend.displayName.toLowerCase().contains(q) || friend.username.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All friends'),
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
                labelText: 'Search your friends',
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 16),
            for (final friend in filtered)
              _FriendListCard(
                friend: friend,
                onChat: () => widget.onChat(friend),
                onDelete: () => widget.onDelete(friend),
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
    required this.friendSuggestions,
    required this.currentFriendNames,
    required this.onAddFriend,
  });

  final String? currentUid;
  final CollectionReference<Map<String, dynamic>> publicProfiles;
  final List<String> friendSuggestions;
  final Set<String> currentFriendNames;
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

    Query<Map<String, dynamic>> query;
    if (q.isEmpty) {
      query = widget.publicProfiles.orderBy('updatedAt', descending: true).limit(20);
    } else {
      query = widget.publicProfiles
          .orderBy('searchName')
          .startAt([q])
          .endAt(['$q\uf8ff'])
          .limit(20);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => _PublicProfile.fromDoc(doc))
          .where((profile) => profile.uid != widget.currentUid)
          .toList();
    });
  }

  Future<void> _add(_PublicProfile profile) async {
    if (_adding) return;
    setState(() => _adding = true);
    try {
      await widget.onAddFriend(profile);
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      'Search Firestore profiles',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: gdInk),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Users appear here after they open the Social page once. This keeps private user data out of public search.',
                      style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        labelText: 'Search name or username',
                        hintText: 'Example: maya or @maya',
                      ),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SuggestedFriendsPanel(
              suggestions: widget.friendSuggestions,
              currentFriendNames: widget.currentFriendNames,
              onSearchSuggestion: (name) {
                _searchController.text = name;
                setState(() => _query = name);
              },
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<_PublicProfile>>(
              stream: _profileStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
                }

                if (snapshot.hasError) {
                  return HelpfulErrorBox(
                    title: 'Friend search failed',
                    message: 'Check Firestore rules and public_profiles indexes. Details: ${snapshot.error}',
                    actionLabel: 'OK',
                    showAction: false,
                  );
                }

                final profiles = snapshot.data ?? [];
                if (profiles.isEmpty) {
                  return const HelpfulErrorBox(
                    title: 'No profiles found',
                    message: 'Ask your teammate to sign in and open the Social page once, then search again.',
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
                          leading: _Avatar(photoUrl: profile.photoUrl, label: profile.displayName),
                          title: Text(profile.displayName, style: const TextStyle(fontWeight: FontWeight.w900)),
                          subtitle: Text(
                            '${profile.username} · ${profile.streak} day streak',
                            style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
                          ),
                          trailing: FilledButton(
                            onPressed: _adding ? null : () => unawaited(_add(profile)),
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
                      style: const TextStyle(color: gdPrimary, fontWeight: FontWeight.w900),
                    ),
                  ),
                  title: Text(
                    filtered[i],
                    style: const TextStyle(fontWeight: FontWeight.w900, color: gdInk),
                  ),
                  subtitle: const Text(
                    'Suggested accountability friend',
                    style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
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
  const _DirectChatPage({required this.friend});

  final _FriendProfile friend;

  @override
  State<_DirectChatPage> createState() => _DirectChatPageState();
}

class _DirectChatPageState extends State<_DirectChatPage> {
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

  String get _chatId {
    final uid = _user?.uid ?? 'guest';
    final members = [uid, widget.friend.uid]..sort();
    return members.join('_');
  }

  CollectionReference<Map<String, dynamic>> get _messages =>
      _db.collection('chats').doc(_chatId).collection('messages');

  Future<void> _send() async {
    final user = _user;
    final text = _controller.text.trim();
    if (user == null) {
      _snack('Sign in before sending chat messages.');
      return;
    }
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      final chatRef = _db.collection('chats').doc(_chatId);
      await chatRef.set({
        'type': 'direct',
        'members': [user.uid, widget.friend.uid],
        'memberNames': {
          user.uid: user.displayName ?? 'You',
          widget.friend.uid: widget.friend.displayName,
        },
        'lastMessage': text,
        'lastSenderUid': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await chatRef.collection('messages').add({
        'senderUid': user.uid,
        'senderName': user.displayName ?? 'You',
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _controller.clear();
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
    final currentUid = _user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            _Avatar(photoUrl: widget.friend.photoUrl, label: widget.friend.displayName, radius: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(widget.friend.displayName, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
      body: PageScaffold(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _messages.orderBy('createdAt', descending: true).limit(60).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: HelpfulErrorBox(
                          title: 'Chat failed to load',
                          message: 'Check Firestore chat rules. Details: ${snapshot.error}',
                          actionLabel: 'OK',
                          showAction: false,
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
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
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                color: gdSurface.withOpacity(0.92),
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
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
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

class _CommunityChatPage extends StatelessWidget {
  const _CommunityChatPage({required this.group});

  final CommunityGroup group;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${group.name} chat')),
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
                    const CircleAvatar(
                      radius: 34,
                      backgroundColor: gdPrimarySoft,
                      child: Icon(Icons.forum_rounded, color: gdPrimary, size: 34),
                    ),
                    const SizedBox(height: 14),
                    Text(group.name, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    const Text(
                      'Community chat is now a separate page. Wire this to chats/{communityId}/messages later if your demo needs group chat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
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
        child: Text('#$rank', style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      title: Text(
        entry.name,
        style: TextStyle(fontWeight: FontWeight.w900, color: entry.isYou ? gdPrimaryDark : gdInk),
      ),
      trailing: Chip(label: Text('${entry.streak} day streak')),
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
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
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
              color: Colors.black.withOpacity(0.06),
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
                  style: const TextStyle(color: gdMuted, fontSize: 12, fontWeight: FontWeight.w900),
                ),
              ),
            Text(
              text,
              style: TextStyle(color: isMine ? Colors.white : gdInk, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl, required this.label, this.radius = 22});

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
        style: const TextStyle(color: gdPrimary, fontWeight: FontWeight.w900),
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
  });

  final String uid;
  final String displayName;
  final String username;
  final String? photoUrl;
  final int streak;
  final bool isReal;

  factory _FriendProfile.fromFriendDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return _FriendProfile(
      uid: (data['uid'] ?? doc.id).toString(),
      displayName: (data['displayName'] ?? data['name'] ?? 'Friend').toString(),
      username: (data['username'] ?? '@friend').toString(),
      photoUrl: data['photoUrl']?.toString(),
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      isReal: true,
    );
  }

  factory _FriendProfile.demo(String name) {
    final cleaned = name.trim();
    return _FriendProfile(
      uid: 'demo_${cleaned.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
      displayName: cleaned,
      username: '@${cleaned.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
      photoUrl: null,
      streak: 2,
      isReal: false,
    );
  }
}

class _PublicProfile {
  const _PublicProfile({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.photoUrl,
    required this.streak,
  });

  final String uid;
  final String displayName;
  final String username;
  final String? photoUrl;
  final int streak;

  factory _PublicProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return _PublicProfile(
      uid: (data['uid'] ?? doc.id).toString(),
      displayName: (data['displayName'] ?? 'Goal Digger User').toString(),
      username: (data['username'] ?? '@user').toString(),
      photoUrl: data['photoUrl']?.toString(),
      streak: (data['streak'] as num?)?.toInt() ?? 0,
    );
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
              style: TextStyle(color: selected ? Colors.white : gdInk, fontWeight: FontWeight.w900),
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
        leading: const CircleAvatar(
          backgroundColor: gdPrimarySoft,
          child: Icon(Icons.person_search_rounded, color: gdPrimary),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(
          '$match% similar goals · active this week',
          style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
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
                  child: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ),
                Chip(label: Text('${group.similarity}% match')),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${group.members} members · ${group.tag}',
              style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(group.description, style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: group.joined
                  ? const OutlinedButton(onPressed: null, child: Text('Already joined'))
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
