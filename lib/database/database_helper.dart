import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:truesoulcards/models/category.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() {
    return instance;
  }
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'truesoulcards.db');
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE categories (
          id TEXT NOT NULL,
          title TEXT NOT NULL,
          color TEXT NOT NULL
        )
      ''');

        await db.execute('''
        CREATE TABLE questions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          text TEXT NOT NULL,
          category TEXT NOT NULL,
          predefined INTEGER NOT NULL,
          FOREIGN KEY (category) REFERENCES categories(id)
        )
      ''');
      },
    );
  }

  Future<void> insertCategory(String id, String title, int color) async {
    final db = await instance.database;
    await db.insert(
      'categories',
      {'id': id, 'title': title, 'color': color},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertQuestion(
      String text,
      String category,
      bool predefined,
      ) async {
    final db = await instance.database;
    await db.insert(
      'questions',
      {
        'text': text,
        'category': category,
        'predefined': predefined ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllQuestions() async {
    final db = await database;
    return await db.query('questions');
  }

  Future<void> clearTable(String tableName) async {
    final db = await database;
    await db.delete(tableName);
  }

  Future<List<Map<String, dynamic>>> getAllQuestionsInCategory() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT q.id, q.question_text, c.name AS category_name
      FROM questions q
      JOIN categories c ON q.category_id = c.id
      WHERE c.id = ?
    ''', [1]);
    }

  Future<List<Category>> getAllCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');
    return result.map((map) => Category.fromJson(map)).toList();
  }
 }
