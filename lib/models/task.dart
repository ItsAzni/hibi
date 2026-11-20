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
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      note: map['note'] as String?,
      completed: map['completed'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
    );
  }
}
