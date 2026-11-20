import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/task.dart';
import '../services/local_storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalStorageService _storage = LocalStorageService();
  final Uuid _uuid = const Uuid();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  List<Task> _tasks = [];
  bool _isLoading = true;

  List<Task> get _activeTasks =>
      _tasks.where((task) => !task.completed).toList();

  List<Task> get _completedTasks =>
      _tasks.where((task) => task.completed).toList();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final tasks = await _storage.getTasks();

    if (!mounted) return;

    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _saveTasks() async {
    await _storage.saveTasks(_tasks);
  }

  Future<void> _addTask() async {
    final title = _titleController.text.trim();
    final note = _noteController.text.trim();

    if (title.isEmpty) return;

    final task = Task(
      id: _uuid.v4(),
      title: title,
      note: note.isEmpty ? null : note,
      createdAt: DateTime.now(),
    );

    setState(() {
      _tasks.insert(0, task);
    });

    _titleController.clear();
    _noteController.clear();

    Navigator.pop(context);

    await _saveTasks();
  }

  Future<void> _toggleTask(Task task) async {
    setState(() {
      task.toggleCompleted();
    });

    await _saveTasks();
  }

  Future<void> _deleteTask(Task task) async {
    setState(() {
      _tasks.removeWhere((item) => item.id == task.id);
    });

    await _saveTasks();
  }

  void _showAddTaskDialog() {
    _titleController.clear();
    _noteController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Task',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Task title',
                  hintText: 'What needs to be done?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'Add some details...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _addTask,
                  child: const Text('Add Task'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskItem(Task task) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => _deleteTask(task),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: Checkbox(
            value: task.completed,
            onChanged: (_) => _toggleTask(task),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.completed
                  ? TextDecoration.lineThrough
                  : null,
              color: task.completed ? Colors.grey : null,
            ),
          ),
          subtitle: task.note != null ? Text(task.note!) : null,
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteTask(task),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Task> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '$title (${tasks.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No tasks here',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          )
        else
          ...tasks.map(_buildTaskItem),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hibi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'My Tasks',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_activeTasks.length} tasks remaining',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                _buildSection('Active', _activeTasks),
                const SizedBox(height: 16),
                _buildSection('Completed', _completedTasks),
                const SizedBox(height: 80),
              ],
            ),
    );
  }
}
