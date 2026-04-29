import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/glass_card.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI ASSISTANT · MAIN PAGE', style: AppTextStyles.labelTeal),
          const SizedBox(height: 16),
          Text('Planner', style: AppTextStyles.heading1),
          const SizedBox(height: 16),
          Text(
            "Set your goals' importance and deadlines. The Adaptive engine builds your daily plan, your calendar, and adjusts in real-time to your energy.",
            style: AppTextStyles.body,
          ),

          const SizedBox(height: 28),

          // ── ADAPTIVE TASK SUGGESTIONS (with embedded Energy Matcher) ──
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.circular(36),
              boxShadow: [BoxShadow(color: AppColors.dark.withValues(alpha: 0.32), blurRadius: 90, offset: const Offset(0, 30))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ADAPTIVE TASK SUGGESTIONS', style: AppTextStyles.label.copyWith(color: Colors.white38)),
                          const SizedBox(height: 10),
                          const Text("Today's plan, built for you",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.8, color: Colors.white)),
                        ],
                      ),
                    ),
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                  child: Text(state.adaptiveMessage,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.5, color: Colors.white)),
                ),

                // Embedded Energy Matcher
                const SizedBox(height: 20),
                Text('ENERGY MATCHER · REAL-TIME', style: AppTextStyles.label.copyWith(color: Colors.white38)),
                const SizedBox(height: 6),
                Text("How is your mood? I'll re-prioritize your tasks instantly.",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _MoodChip(emoji: '😊', label: 'Great', isActive: state.mood == Mood.great, onTap: () => state.setMood(Mood.great)),
                    const SizedBox(width: 8),
                    _MoodChip(emoji: '😐', label: 'Okay', isActive: state.mood == Mood.okay, onTap: () => state.setMood(Mood.okay)),
                    const SizedBox(width: 8),
                    _MoodChip(emoji: '😔', label: 'Tired', isActive: state.mood == Mood.tired, onTap: () => state.setMood(Mood.tired)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: Energy.values.map((e) {
                    final isActive = state.energy == e;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => state.setEnergy(e),
                        child: Container(
                          margin: EdgeInsets.only(right: e != Energy.high ? 6 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.teal : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(child: Text(
                            '${e.name} energy',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
                                color: isActive ? AppColors.dark : Colors.white.withValues(alpha: 0.5)),
                          )),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Generated tasks preview
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('GENERATED FOR TODAY · ${state.todayCompletedCount}/${state.todayTasks.length} DONE',
                          style: AppTextStyles.label.copyWith(color: Colors.white38, fontSize: 9)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.emerald.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(100)),
                      child: Text('${state.todayCompletionPercent}%',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF6EE7B7))),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...state.todayTasks.take(4).map((t) {
                  final goal = state.goals.firstWhere((g) => g.id == t.goalId);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => state.toggleTask(t.id),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: t.done ? AppColors.emerald.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: t.done ? AppColors.emerald : Colors.white.withValues(alpha: 0.15),
                              ),
                              child: Center(
                                child: t.done
                                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                                    : Text('${goal.importance}',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.title,
                                    style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w900,
                                      color: t.done ? Colors.white.withValues(alpha: 0.4) : Colors.white,
                                      decoration: t.done ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${t.duration} · ${goal.title}',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.5)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                if (state.todayTasks.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text('No active goals yet — add one below.',
                        style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.4)))),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── GOALS WITH IMPORTANCE/DEADLINE ──
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOUR GOALS · IMPORTANCE & DEADLINE', style: AppTextStyles.label),
                const SizedBox(height: 6),
                Text('ATS uses these to decide task frequency and priority each day.', style: AppTextStyles.bodySmall),
                const SizedBox(height: 16),
                ...state.goals.map((g) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(g.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [g.startColor, g.endColor]),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text('★ ${g.importance}/5',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('IMPORTANCE', style: AppTextStyles.label.copyWith(fontSize: 9)),
                          Text('${g.importance}', style: AppTextStyles.label.copyWith(fontSize: 9)),
                        ],
                      ),
                      Slider(
                        value: g.importance.toDouble(),
                        min: 1, max: 5, divisions: 4,
                        activeColor: AppColors.teal,
                        onChanged: (v) => state.updateGoalImportance(g.id, v.round()),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('DEADLINE', style: AppTextStyles.label.copyWith(fontSize: 9)),
                          Text('April ${g.deadlineDay}', style: AppTextStyles.label.copyWith(fontSize: 9)),
                        ],
                      ),
                      Slider(
                        value: g.deadlineDay.toDouble().clamp((AppState.todayDay + 1).toDouble(), 30),
                        min: (AppState.todayDay + 1).toDouble(), max: 30, divisions: 30 - AppState.todayDay - 1,
                        activeColor: AppColors.amber,
                        onChanged: (v) => state.updateGoalDeadline(g.id, v.round()),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── GOAL DECONSTRUCTOR ──
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: state.toggleGoalDeconstructor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('GOAL DECONSTRUCTOR', style: AppTextStyles.label),
                          const SizedBox(height: 4),
                          const Text('Add a new goal',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                        ],
                      ),
                      AnimatedRotation(
                        turns: state.showGoalDeconstructor ? 0.125 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          width: 36, height: 36,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.dark),
                          child: const Center(child: Text('+', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.showGoalDeconstructor) ...[
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppColors.dark.withValues(alpha: 0.1)),
                    ),
                    child: TextField(
                      onChanged: state.setDeconGoalInput,
                      controller: TextEditingController(text: state.deconGoalInput),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        border: InputBorder.none,
                        hintText: 'e.g. Become a YouTuber',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.dark.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('IMPORTANCE', style: AppTextStyles.label.copyWith(fontSize: 9)),
                        Text('${state.deconGoalImportance}/5', style: AppTextStyles.label.copyWith(fontSize: 9)),
                      ]),
                      Slider(
                        value: state.deconGoalImportance.toDouble(),
                        min: 1, max: 5, divisions: 4,
                        activeColor: AppColors.teal,
                        onChanged: (v) => state.setDeconGoalImportance(v.round()),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.dark.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('DEADLINE', style: AppTextStyles.label.copyWith(fontSize: 9)),
                        Text('April ${state.deconGoalDeadline}', style: AppTextStyles.label.copyWith(fontSize: 9)),
                      ]),
                      Slider(
                        value: state.deconGoalDeadline.toDouble().clamp((AppState.todayDay + 1).toDouble(), 30),
                        min: (AppState.todayDay + 1).toDouble(), max: 30, divisions: 30 - AppState.todayDay - 1,
                        activeColor: AppColors.amber,
                        onChanged: (v) => state.setDeconGoalDeadline(v.round()),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: state.deconstructGoal,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(100)),
                      child: const Center(child: Text('Break down & schedule', style: AppTextStyles.buttonPrimary)),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Trigger reminder button
          GestureDetector(
            onTap: () => state.showReminder(Reminder(
              id: 99, title: 'Test reminder!', time: 'Now',
              taskId: state.todayTasks.isNotEmpty ? state.todayTasks.first.id : null,
            )),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.dark.withValues(alpha: 0.1)),
              ),
              child: Center(child: Text('🔔 Trigger test reminder', style: AppTextStyles.buttonSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _MoodChip({required this.emoji, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isActive ? AppColors.dark : Colors.white.withValues(alpha: 0.7))),
            ],
          ),
        ),
      ),
    );
  }
}
