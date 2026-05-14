part of goal_digger;

class _CommunityPage extends StatefulWidget {
  const _CommunityPage({
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
  State<_CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<_CommunityPage> {
  int _tab = 0;
  final TextEditingController _friendSearchController = TextEditingController();
  final TextEditingController _communitySearchController = TextEditingController();

  @override
  void dispose() {
    _friendSearchController.dispose();
    _communitySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 112),
        children: [
          // const PageHero(
          //   icon: Icons.groups_rounded,
          //   title: 'Social',
          //   subtitle: 'Manage accountability friends on the left tab and goal communities on the right tab.',
          // ),
          const SizedBox(height: 14),
          AppCard(
            color: gdCardLight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                Expanded(child: _SegmentButton(label: 'Friends', icon: Icons.person_add_alt_1_rounded, selected: _tab == 0, onTap: () => setState(() => _tab = 0))),
                Expanded(child: _SegmentButton(label: 'Communities', icon: Icons.groups_rounded, selected: _tab == 1, onTap: () => setState(() => _tab = 1))),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          if (_tab == 0) _buildFriendsTab(context) else _buildCommunitiesTab(context),
        ],
      ),
    );
  }

  Widget _buildFriendsTab(BuildContext context) {
    final leaderboard = <MapEntry<String, int>>[
      MapEntry('You', widget.streak),
      for (var i = 0; i < widget.friends.length; i++) MapEntry(widget.friends[i], max(2, widget.streak - i + 2)),
    ]..sort((a, b) => b.value.compareTo(a.value));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionTitle(title: 'Friend streak leaderboard'),
      const SizedBox(height: 10),
      AppCard(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            for (var i = 0; i < leaderboard.length; i++)
              ListTile(
                leading: CircleAvatar(backgroundColor: i == 0 ? gdAccentSoft : gdPrimarySoft, child: Text('#${i + 1}', style: const TextStyle(fontWeight: FontWeight.w900))),
                title: Text(leaderboard[i].key, style: const TextStyle(fontWeight: FontWeight.w900)),
                trailing: Chip(label: Text('${leaderboard[i].value} day streak')),
              ),
          ]),
        ),
      ),
      const SizedBox(height: 18),
      SectionTitle(title: 'My friend list', trailing: '${widget.friends.length}'),
      const SizedBox(height: 10),
      for (final friend in widget.friends)
        AppCard(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(Icons.person_rounded, color: gdPrimary)),
            title: Text(friend, style: const TextStyle(fontWeight: FontWeight.w900)),
            subtitle: const Text('Accountability friend · progress visible', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
            trailing: Wrap(spacing: 4, children: [
              IconButton.filledTonal(tooltip: 'Chat', onPressed: () => _showSimpleChat(context, friend, isCommunity: false), icon: const Icon(Icons.chat_bubble_rounded)),
              IconButton(tooltip: 'Delete friend', onPressed: () => widget.onDeleteFriend(friend), icon: const Icon(Icons.delete_outline_rounded, color: gdError)),
            ]),
          ),
        ),
      const SizedBox(height: 18),
      SectionTitle(title: 'Find friends'),
      const SizedBox(height: 10),
      TextField(controller: _friendSearchController, decoration: const InputDecoration(labelText: 'Search friend username', hintText: 'Example: @maya'), onSubmitted: (value) { if (value.trim().isNotEmpty) widget.onAddFriend(value.trim()); }),
      const SizedBox(height: 12),
      SectionTitle(title: 'Friend suggestions'),
      const SizedBox(height: 10),
      for (final name in widget.friendSuggestions.where((name) => !widget.friends.contains(name)))
        FriendSuggestionCard(name: name, match: 90 - widget.friendSuggestions.indexOf(name) * 6, onAdd: () => widget.onAddFriend(name)),
    ]);
  }

  Widget _buildCommunitiesTab(BuildContext context) {
    final joined = widget.communities.where((group) => group.joined).toList();
    final suggested = [...widget.communities]..sort((a, b) => b.similarity.compareTo(a.similarity));
    final leaderboard = [...widget.communities]..sort((a, b) => b.members.compareTo(a.members));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AppCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Create or join community', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: gdInk)),
            const SizedBox(height: 10),
            TextField(controller: widget.controller, decoration: const InputDecoration(labelText: 'Create a community', hintText: 'Example: Midterm study group'), onSubmitted: (_) => widget.onAddCommunity()),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: FilledButton.icon(onPressed: widget.onAddCommunity, icon: const Icon(Icons.add_rounded), label: const Text('Create'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.login_rounded), label: const Text('Join with code'))),
            ]),
          ]),
        ),
      ),
      const SizedBox(height: 18),
      SectionTitle(title: 'Community streak leaderboard'),
      const SizedBox(height: 10),
      AppCard(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            for (var i = 0; i < min(3, leaderboard.length); i++)
              ListTile(
                leading: CircleAvatar(backgroundColor: gdPrimarySoft, child: Text('#${i + 1}', style: const TextStyle(fontWeight: FontWeight.w900))),
                title: Text(leaderboard[i].name, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('${leaderboard[i].members} members', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                trailing: Chip(label: Text('${leaderboard[i].similarity}% fit')),
              ),
          ]),
        ),
      ),
      const SizedBox(height: 18),
      SectionTitle(title: 'My community list', trailing: '${joined.length}'),
      const SizedBox(height: 10),
      if (joined.isEmpty)
        const HelpfulErrorBox(title: 'No joined communities yet', message: 'Join a suggested community below or create your own group.', actionLabel: 'Got it', showAction: false)
      else
        for (final group in joined)
          AppCard(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(Icons.groups_rounded, color: gdPrimary)),
              title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text('${group.members} members · ${group.tag}', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
              trailing: Wrap(spacing: 4, children: [
                IconButton.filledTonal(tooltip: 'Chat', onPressed: () => _showSimpleChat(context, group.name, isCommunity: true), icon: const Icon(Icons.chat_bubble_rounded)),
                IconButton(tooltip: 'Delete community', onPressed: () => widget.onDeleteCommunity(group), icon: const Icon(Icons.delete_outline_rounded, color: gdError)),
              ]),
            ),
          ),
      const SizedBox(height: 18),
      SectionTitle(title: 'Find communities'),
      const SizedBox(height: 10),
      TextField(controller: _communitySearchController, decoration: const InputDecoration(labelText: 'Search communities', hintText: 'Example: design, fitness, exam'), onSubmitted: (_) {}),
      const SizedBox(height: 12),
      SectionTitle(title: 'Community suggestions'),
      const SizedBox(height: 10),
      ...suggested.map((group) => CommunityMatchCard(group: group, onJoin: () => widget.onJoinCommunity(group))),
    ]);
  }

  void _showSimpleChat(BuildContext context, String title, {required bool isCommunity}) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: gdSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isCommunity ? '$title chat' : 'Chat with $title', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            AppCard(color: gdCardLight, child: const Padding(padding: EdgeInsets.all(16), child: Text('Say hi, share your goal update, or ask for accountability.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)))),
            const SizedBox(height: 12),
            TextField(controller: controller, decoration: const InputDecoration(labelText: 'Message', hintText: 'Write a message...')),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.send_rounded), label: const Text('Send'))),
          ]),
        ),
      ),
    ).whenComplete(controller.dispose);
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({required this.label, required this.icon, required this.selected, required this.onTap});
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
        decoration: BoxDecoration(color: selected ? gdPrimary : Colors.transparent, borderRadius: BorderRadius.circular(18)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: selected ? Colors.white : gdMuted), const SizedBox(width: 8), Text(label, style: TextStyle(color: selected ? Colors.white : gdInk, fontWeight: FontWeight.w900))]),
      ),
    );
  }
}

class FriendSuggestionCard extends StatelessWidget {
  const FriendSuggestionCard({super.key, required this.name, required this.match, required this.onAdd});
  final String name;
  final int match;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(Icons.person_search_rounded, color: gdPrimary)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text('$match% similar goals · active this week', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
        trailing: FilledButton(onPressed: onAdd, child: const Text('Add')),
      ),
    );
  }
}

class CommunityMatchCard extends StatelessWidget {
  const CommunityMatchCard({super.key, required this.group, required this.onJoin});
  final CommunityGroup group;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))), Chip(label: Text('${group.similarity}% match'))]),
          const SizedBox(height: 6),
          Text('${group.members} members · ${group.tag}', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(group.description, style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: group.joined ? const OutlinedButton(onPressed: null, child: Text('Already joined')) : FilledButton.icon(onPressed: onJoin, icon: const Icon(Icons.group_add_rounded), label: const Text('Join community'))),
        ]),
      ),
    );
  }
}
