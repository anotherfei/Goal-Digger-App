part of goal_digger;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gdBackground,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Settings'),
        leading: IconButton(
          tooltip: 'Close settings',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('App preferences', style: TextStyle(color: gdInk, fontSize: 20, fontWeight: FontWeight.w900)),
                    SizedBox(height: 6),
                    Text('The whole app uses the same calm Goal Digger theme: soft background, white cards, readable slate text, and one primary blue for actions.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700, height: 1.4)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: true,
                    onChanged: (_) {},
                    activeColor: gdPrimary,
                    title: const Text('Goal reminders', style: TextStyle(color: gdInk, fontWeight: FontWeight.w900)),
                    subtitle: const Text('Nudge me before scheduled tasks.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    value: true,
                    onChanged: (_) {},
                    activeColor: gdPrimary,
                    title: const Text('Friend progress sharing', style: TextStyle(color: gdInk, fontWeight: FontWeight.w900)),
                    subtitle: const Text('Show my streak to approved friends.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                children: const [
                  ListTile(
                    leading: CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(Icons.palette_rounded, color: gdPrimary)),
                    title: Text('Appearance', style: TextStyle(color: gdInk, fontWeight: FontWeight.w900)),
                    subtitle: Text('Readable colors and calm contrast enabled.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(Icons.notifications_active_rounded, color: gdPrimary)),
                    title: Text('Notifications', style: TextStyle(color: gdInk, fontWeight: FontWeight.w900)),
                    subtitle: Text('Focus, routine, friend, and streak notification controls.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: CircleAvatar(backgroundColor: gdPrimarySoft, child: Icon(Icons.lock_rounded, color: gdPrimary)),
                    title: Text('Privacy and account', style: TextStyle(color: gdInk, fontWeight: FontWeight.w900)),
                    subtitle: Text('Manage login, visibility, and connected accounts.', style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
