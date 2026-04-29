import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/pet_widget.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final pet = s.activePet;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _PageBuddy(from: pet.from, to: pet.to, accent: pet.accent, title: 'Social Friend',
          text: "I'll match you with friends and groups that share your goals."),
        const SizedBox(height: 16),

        // Leaderboard
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Weekly leaderboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.emerald.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100)),
              child: Text('Kind mode', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.emerald))),
          ]),
          const SizedBox(height: 12),
          ...[('Maya', 19, 2840, '+12%'), ('Ari', 16, 2695, '+8%'), ('Jon', 12, 2310, '+4%')].asMap().entries.map((e) {
            final isUser = e.value.$1 == 'Ari';
            return Container(
              margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: isUser ? AppColors.dark : Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(24)),
              child: Row(children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: isUser ? Colors.white : AppColors.dark),
                  child: Center(child: Text('${e.key + 1}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: isUser ? AppColors.dark : Colors.white)))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e.value.$1, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: isUser ? Colors.white : AppColors.textPrimary)),
                  Text('${e.value.$2} day streak', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isUser ? Colors.white54 : AppColors.textTertiary)),
                ])),
                Text('${e.value.$3}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isUser ? Colors.white : AppColors.textPrimary)),
              ]),
            );
          }),
        ])),
        const SizedBox(height: 16),

        // My friends
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('My friends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...s.myFriends.map((f) => Container(
            margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.emerald.withValues(alpha: 0.15)),
                child: Center(child: Text(f.name[0], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.emerald)))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                Text(f.status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
              ])),
              GestureDetector(onTap: () => s.removeFriend(f.name), child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100)),
                child: const Text('Remove', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.red)))),
            ]),
          )),
        ])),
        const SizedBox(height: 16),

        // My community
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('My community', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...s.myCommunities.map((c) => Container(
            margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(20)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                Text('by ${c.creator} · ${c.created}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
                const SizedBox(height: 4),
                Text(c.about, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.5, color: AppColors.textSecondary)),
              ])),
              GestureDetector(onTap: () => s.removeCommunity(c.name), child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100)),
                child: const Text('Remove', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.red)))),
            ]),
          )),
        ])),
        const SizedBox(height: 16),

        // Friends suggestions
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Friends suggestions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...s.friendSuggestions.map((u) => Container(
            margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              Container(width: 36, height: 36, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFFA78BFA), Color(0xFF38BDF8)])),
                child: Center(child: Text(u.avatar, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)))),
              const SizedBox(width: 10),
              Expanded(child: Text(u.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary))),
              if (u.compatibility != null) Text('${u.compatibility}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
                color: u.compatibility! >= 70 ? AppColors.emerald : u.compatibility! >= 40 ? AppColors.amberWarm : Colors.red)),
              const SizedBox(width: 8),
              GestureDetector(onTap: () => s.addFriend(u), child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.emerald, AppColors.teal]), borderRadius: BorderRadius.circular(100)),
                child: const Text('+ Add', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)))),
            ]),
          )),
        ])),
        const SizedBox(height: 16),

        // Community Finder
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Community Finder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(
              onChanged: (v) {},
              decoration: InputDecoration(hintText: 'Group name...', filled: true, fillColor: const Color(0xFFFFFAF2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            )),
            const SizedBox(width: 8),
            GestureDetector(onTap: () {}, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: AppColors.emerald, borderRadius: BorderRadius.circular(100)),
              child: const Text('Join', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)))),
            const SizedBox(width: 6),
            GestureDetector(onTap: () {}, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(100)),
              child: const Text('Create', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)))),
          ]),
          const SizedBox(height: 14),
          Text('SUGGESTIONS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.textTertiary)),
          const SizedBox(height: 8),
          ...s.communitySuggestions.map((g) => Container(
            margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(g.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                Text('${g.tag} · ${g.members} members', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
              ])),
              GestureDetector(onTap: () => s.joinCommunity(g), child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(100)),
                child: const Text('Join', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)))),
            ]),
          )),
        ])),
      ]),
    );
  }
}

class _PageBuddy extends StatelessWidget {
  final Color from, to, accent;
  final String title, text;
  const _PageBuddy({required this.from, required this.to, required this.accent, required this.title, required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(gradient: LinearGradient(colors: [from.withValues(alpha: 0.15), to.withValues(alpha: 0.1)]), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white.withValues(alpha: 0.7))),
    child: Row(children: [
      PetWidget(size: 72, from: from, to: to, accent: accent, animate: false),
      const SizedBox(width: 12),
      Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: from)),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, height: 1.5, color: AppColors.textSecondary)),
        ]))),
    ]),
  );
}
