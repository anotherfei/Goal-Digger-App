import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/pet_widget.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});
  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  int? _expanded;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final pet = s.activePet;
    final allDone = s.todayTasks.isNotEmpty && s.todayDone == s.todayTasks.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Page buddy
        _PageBuddy(from: pet.from, to: pet.to, accent: pet.accent,
          title: 'Focus Buddy',
          text: 'Tap a task to see how to start. Mood changes reshape today\'s plan in real time.'),
        const SizedBox(height: 16),

        // ATS card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(32),
            boxShadow: [BoxShadow(color: AppColors.dark.withValues(alpha: 0.3), blurRadius: 70, offset: const Offset(0, 24))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ADAPTIVE TASK SUGGESTIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white.withValues(alpha: 0.5))),
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              child: Text(s.adaptiveText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.5, color: Colors.white))),
            const SizedBox(height: 14),
            Text('MOOD CHECK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white.withValues(alpha: 0.5))),
            const SizedBox(height: 8),
            Row(children: [
              _moodBtn(s, Mood.great, '😊', 'Great'),
              const SizedBox(width: 8),
              _moodBtn(s, Mood.okay, '😐', 'Okay'),
              const SizedBox(width: 8),
              _moodBtn(s, Mood.tired, '😔', 'Tired'),
            ]),
          ]),
        ),
        const SizedBox(height: 16),

        // Progress + task list
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Progress circle (simplified for Flutter)
          Expanded(flex: 4, child: GlassCard(child: Column(children: [
            const SizedBox(height: 8),
            SizedBox(width: 140, height: 140, child: Stack(alignment: Alignment.center, children: [
              SizedBox(width: 140, height: 140, child: CircularProgressIndicator(
                value: s.todayPercent / 100, strokeWidth: 10, strokeCap: StrokeCap.round,
                backgroundColor: AppColors.dark.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(s.todayPercent < 30 ? Colors.red : s.todayPercent < 70 ? AppColors.amberWarm : AppColors.teal),
              )),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${s.todayPercent}%', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                Text('${s.todayDone}/${s.todayTasks.length}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
              ]),
            ])),
            if (allDone && s.hasMoreTasks) ...[
              const SizedBox(height: 12),
              GestureDetector(onTap: s.addMoreTask, child: Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(100)),
                child: const Center(child: Text('+ Add more', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white))),
              )),
            ],
          ]))),
        ]),
        const SizedBox(height: 16),

        // Today task list
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Today', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...s.todayTasks.map((t) {
            final goal = s.goals.firstWhere((g) => g.id == t.goalId);
            final isExpanded = _expanded == t.id && !t.done;
            final guide = AppState.guidance[t.title] ?? AppState.defaultGuidance;
            return Padding(padding: const EdgeInsets.only(bottom: 10), child: Container(
              decoration: BoxDecoration(
                color: t.done ? AppColors.emerald.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(children: [
                Padding(padding: const EdgeInsets.all(14), child: Row(children: [
                  GestureDetector(onTap: () => s.toggleTask(t.id), child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                      color: t.done ? AppColors.emerald : AppColors.dark.withValues(alpha: 0.05),
                      border: Border.all(color: t.done ? AppColors.emerald : AppColors.dark.withValues(alpha: 0.1))),
                    child: t.done ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: GestureDetector(
                    onTap: () => setState(() => _expanded = isExpanded ? null : t.id),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(t.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                        color: t.done ? AppColors.textTertiary : AppColors.textPrimary,
                        decoration: t.done ? TextDecoration.lineThrough : null)),
                      const SizedBox(height: 4),
                      Wrap(spacing: 6, children: [
                        Text(t.duration, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [goal.startColor, goal.endColor]), borderRadius: BorderRadius.circular(100)),
                          child: Text(goal.title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white))),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.amberWarm.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(100)),
                          child: Text('+${t.points}pts', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF92400E)))),
                      ]),
                    ]),
                  )),
                  if (!t.done && s.hasMoreTasks) GestureDetector(
                    onTap: () => s.swapTask(t.id),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100), border: Border.all(color: AppColors.dark.withValues(alpha: 0.1))),
                      child: const Text('Swap', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textSecondary))),
                  ),
                ])),
                if (isExpanded) Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.05),
                    border: Border(top: BorderSide(color: AppColors.dark.withValues(alpha: 0.05))),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('💡', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('HOW TO DO THIS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.teal.withValues(alpha: 0.8))),
                      const SizedBox(height: 6),
                      Text(guide, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.5, color: AppColors.textSecondary)),
                    ])),
                  ]),
                ),
              ]),
            ));
          }),
        ])),
      ]),
    );
  }

  Widget _moodBtn(AppState s, Mood m, String emoji, String label) {
    final active = s.mood == m;
    return Expanded(child: GestureDetector(
      onTap: () => s.setMood(m),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: active ? Colors.white : Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: active ? AppColors.dark : Colors.white70)),
        ]),
      ),
    ));
  }
}

class _PageBuddy extends StatelessWidget {
  final Color from, to, accent;
  final String title, text;
  const _PageBuddy({required this.from, required this.to, required this.accent, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [from.withValues(alpha: 0.15), to.withValues(alpha: 0.1)]),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
      ),
      child: Row(children: [
        PetWidget(size: 72, from: from, to: to, accent: accent),
        const SizedBox(width: 12),
        Expanded(child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: from)),
            const SizedBox(height: 4),
            Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, height: 1.5, color: AppColors.textSecondary)),
          ]),
        )),
      ]),
    );
  }
}
