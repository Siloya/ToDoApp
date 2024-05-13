import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static final _tableName = 'todo_items';
  static final _columnStatus = 'status';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'todo_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            title TEXT,
            category TEXT,
            dueDate TEXT,
            estimate TEXT,
            unit TEXT,
            importance TEXT,
            status TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insertTodoItem(Map<String, dynamic> item) async {
    Database db = await database;
    return await db.insert(_tableName, item);
  }

  static Future<List<Map<String, dynamic>>> getTodoItems(String status) async {
    Database db = await database;
    return await db.query(_tableName, where: 'status = ?', whereArgs: [status]);
  }

  static Future<int> updateTodoItem(Map<String, dynamic> item) async {
    Database db = await database;
    return await db
        .update(_tableName, item, where: 'id = ?', whereArgs: [item['id']]);
  }

// new one
  static Future<void> updateTodoItemStatus(String id, String newStatus) async {
    Database db = await database;
    await db.update(
      _tableName,
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
