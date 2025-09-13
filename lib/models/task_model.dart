class Task {
  String title;
  DateTime dueDate;
  bool isDone;

  Task({
    required this.title,
    required this.dueDate,
    this.isDone = false,
  });
}
