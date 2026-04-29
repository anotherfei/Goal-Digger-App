import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/glass_card.dart';

class _LeaderboardEntry {
  final String name;
  final int streak, score;
  final String pace;
  const _LeaderboardEntry({required this.name, required this.streak, required this.score, required this.pace});
}

class _Friend {
  final String name, status;
  final Color color;
  const _Friend({required this.name, required this.status, required this.color});
}

const _leaderboard = [
  _LeaderboardEntry(name: 'Maya', streak: 19, score: 2840, pace: '+12%'),
  _LeaderboardEntry(name: 'Ari', streak: 16, score: 2695, pace: '+8%'),
  _LeaderboardEntry(name: 'Jon', streak: 12, score: 2310, pace: '+4%'),
  _LeaderboardEntry(name: 'Nia', streak: 9, score: 2055, pace: '+3%'),
];

final _friends = [
  _Friend(name: 'Sam', status: 'Finished 3 tiny wins', color: AppColors.skyBlue),
  _Friend(name: 'Lee', status: 'Needs a gentle nudge', color: AppColors.amberWarm),
  _Friend(name: 'Zoe', status: 'Planning tomorrow', color: AppColors.violet),
];

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LEADERBOARDS & FRIENDS', style: AppTextStyles.labelTeal),
          const SizedBox(height: 16),
          Text('Community', style: AppTextStyles.heading1),
          const SizedBox(height: 16),
          Text('Friendly momentum without shame. Celebrate consistency, send support, and keep going together.', style: AppTextStyles.body),

          const SizedBox(height: 28),

          // Leaderboard
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Weekly leaderboard', style: AppTextStyles.heading3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.emerald.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100)),
                    child: const Text('Kind mode', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.emerald)),
                  ),
                ]),
                const SizedBox(height: 16),
                ..._leaderboard.asMap().entries.map((e) {
                  final p = e.value;
                  final r = e.key + 1;
                  final isUser = p.name == 'Ari';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.dark : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(children: [
                      Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: isUser ? Colors.white : AppColors.dark),
                        child: Center(child: Text('$r', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: isUser ? AppColors.dark : Colors.white)))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isUser ? Colors.white : AppColors.textPrimary)),
                        Text('${p.streak} day streak', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isUser ? Colors.white54 : AppColors.textTertiary)),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('${p.score}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isUser ? Colors.white : AppColors.textPrimary)),
                        Text(p.pace, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isUser ? const Color(0xFFA7F3D0) : AppColors.emerald)),
                      ]),
                    ]),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Friends
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Friends', style: AppTextStyles.heading3),
                const SizedBox(height: 16),
                ..._friends.map((f) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: f.color)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(f.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                      Text(f.status, style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                    ])),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(100)),
                        child: const Text('Cheer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ),
                  ]),
                )),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── COMMUNITY FINDER ──
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Community Finder', style: AppTextStyles.heading3),
                  Container(
                    width: 36, height: 36,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.dark),
                    child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 18),
                  ),
                ]),
                const SizedBox(height: 8),
                Text('Find users with similar goals and habits.', style: AppTextStyles.bodySmall),
                const SizedBox(height: 16),
                ...AppState.communityUsers.map((u) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.dark.withValues(alpha: 0.1)),
                      child: Center(child: Text(u.avatar, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textSecondary))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(u.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary))),
                    if (u.compatibility != null) ...[
                      SizedBox(
                        width: 50, height: 8,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: u.compatibility! / 100,
                            backgroundColor: AppColors.dark.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation(
                              u.compatibility! >= 70 ? AppColors.emerald : u.compatibility! >= 40 ? AppColors.amberWarm : Colors.red,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${u.compatibility}%', style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w900,
                        color: u.compatibility! >= 70 ? AppColors.emerald : u.compatibility! >= 40 ? AppColors.amberWarm : Colors.red,
                      )),
                    ] else
                      Text('No data', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                  ]),
                )),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Team challenge
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFFFFF2D6), borderRadius: BorderRadius.circular(28)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('TEAM CHALLENGE', style: AppTextStyles.label.copyWith(color: const Color(0xFF92400E))),
              const SizedBox(height: 10),
              const Text('Complete 25 tiny wins together', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.8, color: AppColors.textPrimary)),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(value: 0.68, minHeight: 10, backgroundColor: const Color(0xFF78350F).withValues(alpha: 0.1), valueColor: const AlwaysStoppedAnimation(AppColors.amberWarm)),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
