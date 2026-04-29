import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/pet_widget.dart';
import '../models/sub_task.dart';
import '../models/routine.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool _showAddRoutine = false;
  String _name = '';
  String _time = '08:00';
  String _freq = 'Daily';
  String _custom = '';

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final pet = s.activePet;
    final months = ['January','February','March','April','May','June','July','August','September','October','November','December'];

    // Build grid
    final year = s.viewYear;
    final month = s.viewMonth;
    final first = DateTime(year, month + 1, 1);
    final offset = (first.weekday - 1) % 7;
    final dim = DateTime(year, month + 2, 0).day;
    final dip = DateTime(year, month + 1, 0).day;

    final cells = List.generate(42, (i) {
      final d = i - offset + 1;
      if (d < 1) return _Cell(date: DateTime(year, month, dip + d), display: dip + d, outside: true);
      if (d > dim) return _Cell(date: DateTime(year, month + 2, d - dim), display: d - dim, outside: true);
      return _Cell(date: DateTime(year, month + 1, d), display: d, outside: false);
    });

    // Tasks & routines by date
    final allSubs = s.goals.expand((g) => g.subtasks).toList();
    Map<String, List<SubTask>> tasksByDate = {};
    for (final t in allSubs) {
      final k = '${t.scheduledDate.year}-${t.scheduledDate.month}-${t.scheduledDate.day}';
      (tasksByDate[k] ??= []).add(t);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Buddy
        _PageBuddy(from: pet.from, to: pet.to, accent: pet.accent,
          title: 'Time Keeper', text: 'Tap a date to preview its plan — view-only.'),
        const SizedBox(height: 16),

        // Month nav
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              GestureDetector(onTap: () => s.navigateMonth(-1), child: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(100)),
                child: const Center(child: Text('‹', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))))),
              const SizedBox(width: 8),
              Text('${months[month]} $year', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const SizedBox(width: 8),
              GestureDetector(onTap: () => s.navigateMonth(1), child: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(100)),
                child: const Center(child: Text('›', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))))),
            ]),
            GestureDetector(onTap: s.jumpToToday, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: AppColors.amberWarm, borderRadius: BorderRadius.circular(100)),
              child: const Text('Today', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF78350F))),
            )),
          ]),
        ),
        const SizedBox(height: 12),

        // Calendar grid
        GlassCard(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Row(children: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'].map((d) => Expanded(
              child: Center(child: Text(d, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.textTertiary))),
            )).toList()),
            const SizedBox(height: 6),
            ...List.generate(6, (week) {
              final weekCells = cells.skip(week * 7).take(7).toList();
              return Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(
                children: weekCells.map((c) {
                  final isToday = c.date.year == today.year && c.date.month == today.month && c.date.day == today.day;
                  final k = '${c.date.year}-${c.date.month}-${c.date.day}';
                  final items = tasksByDate[k] ?? [];
                  final dayRoutines = s.routinesForDate(c.date);

                  return Expanded(child: GestureDetector(
                    onTap: () => _showDayPopup(context, s, c.date, items, dayRoutines),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minHeight: 70),
                      decoration: BoxDecoration(
                        color: c.outside ? Colors.white.withValues(alpha: 0.25) : isToday ? const Color(0xFFFEF3C7) : Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: isToday ? Border.all(color: AppColors.amberWarm, width: 2) : null,
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${c.display}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
                          color: c.outside ? AppColors.textTertiary.withValues(alpha: 0.4) : AppColors.textSecondary)),
                        if (items.isNotEmpty) Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [s.goals.firstWhere((g) => g.id == items.first.goalId).startColor, s.goals.firstWhere((g) => g.id == items.first.goalId).endColor]),
                            borderRadius: BorderRadius.circular(4)),
                          child: Text(items.first.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: Colors.white)),
                        ),
                        if (dayRoutines.isNotEmpty) Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), border: Border.all(color: AppColors.amberWarm.withValues(alpha: 0.7)), borderRadius: BorderRadius.circular(4)),
                          child: Text('🔔 ${dayRoutines.first.title}', maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: Color(0xFF92400E))),
                        ),
                        if (items.length + dayRoutines.length > 2) Text('+${items.length + dayRoutines.length - 2}', style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: AppColors.textTertiary)),
                      ]),
                    ),
                  ));
                }).toList(),
              ));
            }),
          ]),
        ),
        const SizedBox(height: 16),

        // Routines
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Routines', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            Text('REMINDER ONLY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.textTertiary)),
          ]),
          const SizedBox(height: 12),
          ...s.routines.map((r) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Container(width: 36, height: 36,
                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.amberWarm, Colors.pink.shade300]), borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text('🔔', style: TextStyle(fontSize: 16)))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                Text('${r.time} · ${r.frequency}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
              ])),
              GestureDetector(onTap: () => s.removeRoutine(r.id), child: Container(width: 28, height: 28,
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Center(child: Text('✕', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.red))))),
            ]),
          )),

          GestureDetector(
            onTap: () => setState(() => _showAddRoutine = !_showAddRoutine),
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.dark.withValues(alpha: _showAddRoutine ? 1 : 0.2), width: 2),
                borderRadius: BorderRadius.circular(16),
                color: _showAddRoutine ? AppColors.dark.withValues(alpha: 0.05) : null,
              ),
              child: Center(child: Text(_showAddRoutine ? '✕ Cancel' : '+ Add new routine',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: _showAddRoutine ? AppColors.textPrimary : AppColors.textTertiary))),
            ),
          ),

          if (_showAddRoutine) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                TextField(
                  onChanged: (v) => _name = v,
                  decoration: InputDecoration(hintText: 'Routine name', filled: true, fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(
                    onChanged: (v) => _time = v,
                    decoration: InputDecoration(hintText: '08:00', filled: true, fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: DropdownButtonFormField<String>(
                    value: _freq,
                    items: ['Daily','Weekly','Monthly','Once','Custom'].map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)))).toList(),
                    onChanged: (v) => setState(() => _freq = v ?? 'Daily'),
                    decoration: InputDecoration(filled: true, fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  )),
                ]),
                if (_freq == 'Custom') ...[
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (v) => _custom = v,
                    decoration: InputDecoration(hintText: 'e.g. Every 3 days', filled: true, fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    if (_name.trim().isEmpty) return;
                    final freq = _freq == 'Custom' && _custom.trim().isNotEmpty ? _custom : _freq;
                    s.addRoutine(Routine(id: DateTime.now().millisecondsSinceEpoch, title: _name, time: _time, frequency: freq));
                    setState(() { _showAddRoutine = false; _name = ''; });
                  },
                  child: Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.teal, AppColors.emerald]), borderRadius: BorderRadius.circular(100)),
                    child: const Center(child: Text('Add routine', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white))),
                  ),
                ),
              ]),
            ),
          ],
        ])),
      ]),
    );
  }

  void _showDayPopup(BuildContext context, AppState s, DateTime date, List<SubTask> tasks, List<Routine> routines) {
    final pet = s.activePet;
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Day preview', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppColors.textTertiary)),
              Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              Container(margin: const EdgeInsets.only(top: 6), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100)),
                child: Text('VIEW ONLY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.teal))),
            ]),
            GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, size: 20)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.dark.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14)),
              child: Column(children: [Text('${tasks.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)), Text('Tasks', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.textTertiary))]))),
            const SizedBox(width: 8),
            Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.amberWarm.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: Column(children: [Text('${routines.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF92400E))), Text('Routines', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, color: const Color(0xFF92400E)))]))),
          ]),
          const SizedBox(height: 12),
          if (tasks.isEmpty && routines.isEmpty) ...[
            Center(child: Column(children: [
              PetWidget(size: 80, from: pet.from, to: pet.to, accent: pet.accent, animate: false),
              const SizedBox(height: 10),
              const Text('No tasks for this day', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
            ])),
          ],
          if (tasks.isNotEmpty) ...[
            Text('TASKS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.textTertiary)),
            const SizedBox(height: 8),
            ...tasks.map((t) {
              final goal = s.goals.firstWhere((g) => g.id == t.goalId);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(color: t.done ? AppColors.emerald.withValues(alpha: 0.05) : Colors.white, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.done ? AppColors.emerald.withValues(alpha: 0.2) : AppColors.dark.withValues(alpha: 0.05))),
                child: Column(children: [
                  Container(height: 3, decoration: BoxDecoration(gradient: LinearGradient(colors: [goal.startColor, goal.endColor]), borderRadius: const BorderRadius.vertical(top: Radius.circular(16)))),
                  Padding(padding: const EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(t.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: t.done ? AppColors.textTertiary : AppColors.textPrimary, decoration: t.done ? TextDecoration.lineThrough : null)),
                      Text('${goal.title} · ${t.duration}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
                    ])),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: t.done ? AppColors.emerald.withValues(alpha: 0.1) : AppColors.dark.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(100)),
                      child: Text(t.done ? 'Completed' : 'Planned', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: t.done ? AppColors.emerald : AppColors.textTertiary))),
                  ])),
                ]),
              );
            }),
          ],
          if (routines.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('ROUTINE REMINDERS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: const Color(0xFF92400E))),
            const SizedBox(height: 8),
            ...routines.map((r) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFEF3C7).withValues(alpha: 0.8), borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.amberWarm.withValues(alpha: 0.5), style: BorderStyle.solid)),
              child: Row(children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.amberWarm, Colors.pink.shade300]), borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Text('🔔', style: TextStyle(fontSize: 16)))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  Text('${r.time} · ${r.frequency}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
                  child: Text('Reminder', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, color: const Color(0xFF92400E)))),
              ]),
            )),
          ],
        ]),
      ),
    );
  }
}

class _Cell { final DateTime date; final int display; final bool outside; _Cell({required this.date, required this.display, required this.outside}); }

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
