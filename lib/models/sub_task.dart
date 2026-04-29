enum TaskLoad { light, focus, stretch }

class SubTask {
  final int id;
  final int goalId;
  final String title;
  String duration;
  TaskLoad load;
  bool done;
  final int points;
  DateTime scheduledDate;

  SubTask({
    required this.id,
    required this.goalId,
    required this.title,
    required this.duration,
    required this.load,
    this.done = false,
    this.points = 10,
    required this.scheduledDate,
  });
}
