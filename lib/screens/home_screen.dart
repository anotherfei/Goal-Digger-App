import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal_item.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/pet_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final pet = s.activePet;
    final cats = ['Career','Study','Work','Wellness','Hobby','Creative','Family','Finance','Other'];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Goal deconstructor
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.dark, borderRadius: BorderRadius.circular(36),
              boxShadow: [BoxShadow(color: AppColors.dark.withValues(alpha: 0.32), blurRadius: 90, offset: const Offset(0, 30))],
            ),
            child: Column(children: [
              // Speech bubble
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: const Text('Tell me your next big goal. I will break it down, schedule it, and keep it kind.',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              ),
              const SizedBox(height: 12),
              PetWidget(size: 160, from: pet.from, to: pet.to, accent: pet.accent),
              const SizedBox(height: 16),

              // Pet energy bar
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Pet energy', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                    Text('${s.petHunger}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                  ]),
                  const SizedBox(height: 8),
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
                    value: s.petHunger / 100, minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(s.petHunger < 30 ? Colors.red : s.petHunger < 60 ? AppColors.amberWarm : AppColors.emerald),
                  )),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: s.feedPet,
                    child: Container(
                      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
                      child: Center(child: Text(s.petHunger >= 100 ? 'Pet is full' : s.earnedToday < 10 ? 'Complete tasks to feed' : 'Feed pet (10 coins)',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.dark))),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              // Goal input
              TextField(
                onChanged: (v) => s.deconTitle = v,
                controller: TextEditingController(text: s.deconTitle),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g. Become a YouTuber', hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                  filled: true, fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
              const SizedBox(height: 12),

              // Category chips
              Wrap(spacing: 6, runSpacing: 6, children: cats.map((c) => GestureDetector(
                onTap: () { s.deconCategory = c; s.notifyListeners(); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: s.deconCategory == c ? Colors.white : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(c, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: s.deconCategory == c ? AppColors.dark : Colors.white60)),
                ),
              )).toList()),
              const SizedBox(height: 12),

              // Importance stars
              Row(children: [1, 2, 3, 4, 5].map((n) => Expanded(
                child: GestureDetector(
                  onTap: () { s.deconImportance = n; s.notifyListeners(); },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2), padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: n <= s.deconImportance ? AppColors.teal : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: Text('★', style: TextStyle(fontSize: 16))),
                  ),
                ),
              )).toList()),
              const SizedBox(height: 12),

              // Deadline
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: s.deconDeadline, firstDate: DateTime.now(), lastDate: DateTime(2030));
                  if (d != null) { s.deconDeadline = d; s.notifyListeners(); }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    const Icon(Icons.calendar_month, color: Colors.white60, size: 20),
                    const SizedBox(width: 10),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('DEADLINE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white.withValues(alpha: 0.4))),
                      Text('${s.deconDeadline.day} ${['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][s.deconDeadline.month - 1]} ${s.deconDeadline.year}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                    ]),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: s.deconTitle.trim().isNotEmpty ? s.deconstructGoal : null,
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
                  child: const Center(child: Text('Break down & schedule', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.dark))),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // My goals
          Text('My goals', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...s.goals.map((g) => _GoalCard(goal: g, state: s)),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalItem goal;
  final AppState state;
  const _GoalCard({required this.goal, required this.state});

  @override
  Widget build(BuildContext context) {
    final g = goal;
    final dl = g.deadline.difference(today).inDays;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8))]),
      child: Column(children: [
        Container(height: 5, decoration: BoxDecoration(
          gradient: LinearGradient(colors: [g.startColor, g.endColor]),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        )),
        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(g.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              Text('${g.doneCount}/${g.subtasks.length} · ${g.percent}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
            ])),
            GestureDetector(
              onTap: () => state.removeGoal(g.id),
              child: Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: const Center(child: Text('✕', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.red)))),
            ),
          ]),
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(
            value: g.percent / 100, minHeight: 8,
            backgroundColor: AppColors.dark.withValues(alpha: 0.05),
            valueColor: AlwaysStoppedAnimation(g.startColor),
          )),
          const SizedBox(height: 10),
          Row(children: [1, 2, 3, 4, 5].map((n) => Expanded(
            child: GestureDetector(
              onTap: () => state.updateGoalImportance(g.id, n),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1), padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  gradient: n <= g.importance ? LinearGradient(colors: [g.startColor, g.endColor]) : null,
                  color: n > g.importance ? AppColors.dark.withValues(alpha: 0.05) : null,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(child: Text('★', style: TextStyle(fontSize: 14, color: n <= g.importance ? Colors.white : AppColors.textTertiary))),
              ),
            ),
          )).toList()),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: g.deadline, firstDate: DateTime.now(), lastDate: DateTime(2030));
              if (d != null) state.updateGoalDeadline(g.id, d);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.dark.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                const Icon(Icons.calendar_month, size: 18, color: AppColors.textTertiary),
                const SizedBox(width: 8),
                Text('${g.deadline.day}/${g.deadline.month}/${g.deadline.year}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: dl <= 3 ? Colors.red.withValues(alpha: 0.15) : dl <= 7 ? AppColors.amberWarm.withValues(alpha: 0.15) : AppColors.emerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text('${dl}d', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: dl <= 3 ? Colors.red : dl <= 7 ? AppColors.amberWarm : AppColors.emerald)),
                ),
              ]),
            ),
          ),
        ])),
      ]),
    );
  }
}
