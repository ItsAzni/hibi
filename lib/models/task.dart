class Task {
  final String id;
  String title;
  String? note;
  bool completed;
  final DateTime createdAt;
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.note,
    this.completed = false,
    required this.createdAt,
    this.completedAt
  });

  void toggleCompleted() {
    completed = !completed;
    if (completed) {
      completedAt = DateTime.now();
    } else {
      completedAt = null;
    }
  }

  void updateTitle(String title) {
    this.title = title.trim();
  }

  void updateNote(String note) {
    this.note = note.trim();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'completed': completed,
      'createdAt': createdAt,
      'completedAt': completedAt,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      note: map['note'],
      completed: map['completed'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null
    );
  }
}
