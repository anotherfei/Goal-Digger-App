enum TaskLoad { light, focus, stretch }

class SubTask {
  final int id;
  final String title;
  final int goalId;
  String duration;
  TaskLoad load;
  bool done;
  final int points;
  int scheduledDay;

  SubTask({
    required this.id,
    required this.title,
    required this.goalId,
    required this.duration,
    required this.load,
    this.done = false,
    this.points = 10,
    required this.scheduledDay,
  });
}
