import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:truesoulcards/models/category.dart';
import 'package:truesoulcards/models/question.dart';

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
          subcategory TEXT NOT NULL,
          color INTEGER NOT NULL,
          img TEXT NOT NULL
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

  Future<void> insertCategory(
    String id,
    String title,
    String subcategory,
    int color,
    String img,
  ) async {
    final db = await instance.database;
    await db.insert('categories', {
      'id': id,
      'title': title,
      'color': color,
      'subcategory': subcategory,
      'img': img,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertQuestion(
    String text,
    String category,
    bool predefined,
  ) async {
    final db = await instance.database;
    await db.insert('questions', {
      'text': text,
      'category': category,
      'predefined': predefined ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Question>> getAllQuestions() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT 
      questions.id, 
      questions.text, 
      questions.category, 
      questions.predefined, 
      categories.color
    FROM questions
    INNER JOIN categories ON questions.category = categories.id
  ''');
    return result.map((map) => Question.fromMap(map)).toList();
  }

  Future<void> clearTable(String tableName) async {
    final db = await database;
    await db.delete(tableName);
  }

  Future<List<Question>> getAllQuestionsInCategory(String categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT
      questions.id,
      questions.text,
      questions.category,
      questions.predefined,
      categories.color
    FROM questions
    INNER JOIN categories ON questions.category = categories.id
    WHERE questions.category = ?
  ''', [categoryId]);
    return result.map((map) => Question.fromMap(map)).toList();
  }

  Future<List<Category>> getAllCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');
    return result.map((map) => Category.fromJson(map)).toList();
  }

  Future<bool> isDatabaseEmpty() async {
    final db = await database;
    final result = await db.query('categories', limit: 1);
    return result.isEmpty;
  }
}
