import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class LocalStorageService {
  static const String _tasksKey = 'tasks';

  Future<List<Task>> getTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? data = prefs.getString(_tasksKey);

      if (data == null || data.isEmpty) return [];

      final List<dynamic> decoded = jsonDecode(data);

      return decoded
          .map((item) => Task.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();

    final String encoded = jsonEncode(
      tasks.map((task) => task.toMap()).toList(),
    );

    await prefs.setString(_tasksKey, encoded);
  }

  Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
  }
}