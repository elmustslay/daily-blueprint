import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteDb {
  static Database? _database;

  static Future<Database> get instance async {
    if (_database != null) return _database!;
    _database = await _initDB('gym_logs.db');
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            exercise_id TEXT NOT NULL,
            weight REAL NOT NULL,
            date TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE body_weight (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            weight REAL NOT NULL,
            date TEXT NOT NULL UNIQUE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE body_weight (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              weight REAL NOT NULL,
              date TEXT NOT NULL UNIQUE
            )
          ''');
        }
      },
    );
  }
}
