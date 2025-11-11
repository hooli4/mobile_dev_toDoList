import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class ToDoManagerDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'ToDoListDatabase.db');

    bool dbExists = await File(path).exists();

    print('Путь к БД: $path');
    print('Файл БД существует: $dbExists');

    if (dbExists) {
      print('Открываем существующую БД');
      return await openDatabase(
        path,
        version: 1,
        onOpen: (db) {
          print('Существующая БД успешно открыта');
        },
      );
    } else {
      print('Создаем новую БД');
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          print('Создаем таблицы...');
          await db.execute('''
            CREATE TABLE tasks(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              date TEXT NOT NULL,
              isCompleted INTEGER NOT NULL DEFAULT 0
            )
          ''');

          await _insertInitialData(db);
        },
      );
    }
  }

  static Future<void> _insertInitialData(Database db) async {
    await db.insert('tasks', {
      'title': 'Пример задачи',
      'date': DateTime.now().toIso8601String(),
      'isCompleted': 0
    });
    print('Добавлены начальные данные');
  }

  static Future<bool> checkDatabaseExists() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'ToDoListDatabase.db');
    return await File(path).exists();
  }

  static Future<void> deleteDatabases() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'ToDoListDatabase.db');
    await deleteDatabase(path);
    _database = null;
    print('БД удалена');
  }
}