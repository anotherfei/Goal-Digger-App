import '../core/theme/gd_design.dart';
import '../core/utils/date_helpers.dart';
import '../models/models.dart';

List<GoalProject> seedGoals(DateTime today) {
  return [
    GoalProject(
      id: 1,
      title: 'Launch portfolio',
      importance: 5,
      category: 'Career',
      deadline: addDays(today, 7),
      from: gdGradientCareerFrom,
      to: gdGradientCareerTo,
      tasks: [
        MicroTask(
          id: 101,
          goalId: 1,
          title: 'Draft project outline',
          durationMinutes: 12,
          load: TaskLoad.focus,
          scheduledDate: today,
          done: true,
        ),
        MicroTask(
          id: 102,
          goalId: 1,
          title: 'Sketch homepage layout',
          durationMinutes: 15,
          load: TaskLoad.focus,
          scheduledDate: today,
        ),
        MicroTask(
          id: 103,
          goalId: 1,
          title: 'Write project descriptions',
          durationMinutes: 20,
          load: TaskLoad.stretch,
          scheduledDate: addDays(today, 1),
        ),
        MicroTask(
          id: 104,
          goalId: 1,
          title: 'Deploy first draft',
          durationMinutes: 20,
          load: TaskLoad.focus,
          scheduledDate: addDays(today, 3),
        ),
      ],
    ),
    GoalProject(
      id: 2,
      title: 'Exam prep',
      importance: 4,
      category: 'Study',
      deadline: addDays(today, 12),
      from: gdGradientStudyFrom,
      to: gdGradientStudyTo,
      tasks: [
        MicroTask(
          id: 201,
          goalId: 2,
          title: 'Review chapter notes',
          durationMinutes: 10,
          load: TaskLoad.light,
          scheduledDate: today,
        ),
        MicroTask(
          id: 202,
          goalId: 2,
          title: 'Solve 5 practice problems',
          durationMinutes: 25,
          load: TaskLoad.stretch,
          scheduledDate: addDays(today, 1),
        ),
        MicroTask(
          id: 203,
          goalId: 2,
          title: 'Make flashcards',
          durationMinutes: 15,
          load: TaskLoad.focus,
          scheduledDate: addDays(today, 2),
        ),
      ],
    ),
  ];
}
