import 'database.dart';
import '../models/models.dart';

class ToDoListService {
  static Future<List<Task>> getTasks() async {
    final db = await ToDoManagerDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  static Future<int> updateTask(int id, String title, DateTime date) async {
    final db = await ToDoManagerDatabase.database;
    return await db.update(
      'tasks',
      {
        'title': title,
        'date': date.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteTask(int id) async {
    final db = await ToDoManagerDatabase.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> markTaskAsCompleted(int id) async {
    final db = await ToDoManagerDatabase.database;
    final task = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    final currentTask = task.first;
    final currentStatus = currentTask['isCompleted'] as int;
    final newStatus = currentStatus == 1 ? 0 : 1;

    return await db.update(
      'tasks',
      {'isCompleted': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> insertTask(String title, DateTime date, int isCompleted) async {
    final db = await ToDoManagerDatabase.database;
    return await db.insert(
      'tasks',
      {
        'title': title,
        'date': date.toIso8601String(),
        'isCompleted': isCompleted,
      },
    );
  }
}