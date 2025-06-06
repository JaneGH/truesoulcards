import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/data/models/question.dart';
import 'package:collection/collection.dart';

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
          subcategory TEXT NOT NULL,
          color INTEGER NOT NULL,
          img TEXT NOT NULL,
          isPremium INTEGER NOT NULL DEFAULT 0
        )
      ''');

        await db.execute('''
        CREATE TABLE questions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          predefined INTEGER NOT NULL,
          FOREIGN KEY (category) REFERENCES categories(id)
        )
      ''');

        await db.execute('''
        CREATE TABLE question_translations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          question_id INTEGER NOT NULL,
          language_code TEXT NOT NULL,
          text TEXT NOT NULL,
          FOREIGN KEY (question_id) REFERENCES questions(id)
        );
        ''');

        await db.execute('''
        CREATE TABLE category_translations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category_id TEXT NOT NULL,
          language_code TEXT NOT NULL,
          title TEXT,
          FOREIGN KEY (category_id) REFERENCES categories(id)
        );
      ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {}
      },
    );
  }

  Future<void> insertCategory(
    String categoryId,
    Map<String, String> titleTranslations,
    String subcategory,
    int color,
    bool isPremium,
    String img,
  ) async {
    final db = await instance.database;
    await db.insert('categories', {
      'id': categoryId,
      'color': color,
      'img': img,
      'isPremium': isPremium ? 1 : 0,
      'subcategory': subcategory,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    for (var entry in titleTranslations.entries) {
      await insertCategoryTranslation(categoryId, entry.key, entry.value);
    }
  }

  Future<void> insertCategoryTranslation(
    String categoryId,
    String languageCode,
    String title,
  ) async {
    final db = await instance.database;
    await db.insert('category_translations', {
      'category_id': categoryId,
      'language_code': languageCode,
      'title': title,
    });
  }

  Future<void> deleteQuestion(int questionId) async {
    final db = await instance.database;

    await db.delete(
      'question_translations',
      where: 'question_id = ?',
      whereArgs: [questionId],
    );

    await db.delete('questions', where: 'id = ?', whereArgs: [questionId]);
  }

  Future<void> insertQuestion(
    String category,
    bool predefined,
    Map<String, String> translations,
  ) async {
    final db = await instance.database;
    final questionId = await db.insert('questions', {
      'category': category,
      'predefined': predefined,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    for (var entry in translations.entries) {
      await insertQuestionTranslation(questionId, entry.key, entry.value);
    }
  }

  Future<void> insertQuestionTranslation(
    int questionId,
    String languageCode,
    String text,
  ) async {
    final db = await instance.database;
    await db.insert('question_translations', {
      'question_id': questionId,
      'language_code': languageCode,
      'text': text,
    });
  }

  Future<List<Question>> getQuestions({String? categoryId}) async {
    final db = await database;

    final whereClause = categoryId != null ? 'WHERE q.category = ?' : '';
    final args = categoryId != null ? [categoryId] : [];

    final result = await db.rawQuery('''
    SELECT 
      q.id,
      q.category,
      q.predefined,
      c.color,
      qt.language_code,
      qt.text
    FROM questions q
    JOIN categories c ON q.category = c.id
    JOIN question_translations qt ON qt.question_id = q.id
    $whereClause
  ''', args);

    final grouped = groupBy(result, (row) => row['id'] as int);

    return grouped.entries.map((entry) {
      final rows = entry.value;
      final first = rows.first;

      final translations = {
        for (var row in rows)
          row['language_code'] as String: row['text'] as String,
      };

      return Question(
        id: first['id'] as int,
        category: first['category'] as String,
        predefined: first['predefined'] == 1 || first['predefined'] == true,
        color: first['color'] as int,
        translations: translations,
      );
    }).toList();
  }

  Future<void> clearTable(String tableName) async {
    final db = await database;
    await db.delete(tableName);
  }

  Future<void> clearCustomData() async {
    final db = await DatabaseHelper.instance.database;

    await db.delete(
      'category_translations',
      where: 'category_id IN (SELECT id FROM categories WHERE id NOT LIKE ?)',
      whereArgs: ['usr_%'],
    );

    await db.delete(
      'question_translations',
      where: 'question_id IN (SELECT id FROM questions WHERE predefined = ?)',
      whereArgs: [true],
    );

    await db.delete('questions', where: 'predefined = ?', whereArgs: [true]);

    await db.delete('categories', where: "id NOT LIKE ?", whereArgs: ['usr_%']);
  }

  Future<List<Category>> getAllCategories() async {
    final db = await instance.database;

    final result = await db.rawQuery('''
    SELECT 
      c.id,
      c.subcategory,
      c.color,
      c.isPremium,
      c.img,
      ct.language_code,
      ct.title
    FROM categories c
    LEFT JOIN category_translations ct ON c.id = ct.category_id
  ''');

    final grouped = groupBy(result, (row) => row['id'] as String);

    return grouped.entries.map((entry) {
      final rows = entry.value;
      final first = rows.first;

      final translations = {
        for (var row in rows)
          if (row['language_code'] != null && row['title'] != null)
            row['language_code'] as String: row['title'] as String,
      };

      return Category(
        id: first['id'] as String,
        subcategory: first['subcategory'] as String,
        color: first['color'] as int,
        img: first['img'] as String,
        isPremium: (first['isPremium'] as int) == 1,
        titleTranslations: translations,
      );
    }).toList();
  }

  Future<List<Category>> getCategoriesByIds(List<String> ids) async {
    final db = await instance.database;

    if (ids.isEmpty) return [];

    final placeholders = List.filled(ids.length, '?').join(',');
    final result = await db.rawQuery('''
    SELECT 
      c.id,
      c.subcategory,
      c.color,
      c.img,
      c.isPremium,
      ct.language_code,
      ct.title
    FROM categories c
    LEFT JOIN category_translations ct ON c.id = ct.category_id
    WHERE c.id IN ($placeholders)
  ''', ids);

    final grouped = groupBy(result, (row) => row['id'] as String);

    return grouped.entries.map((entry) {
      final rows = entry.value;
      final first = rows.first;

      final translations = {
        for (var row in rows)
          if (row['language_code'] != null && row['title'] != null)
            row['language_code'] as String: row['title'] as String,
      };

      return Category(
        id: first['id'] as String,
        subcategory: first['subcategory'] as String,
        color: first['color'] as int,
        img: first['img'] as String,
        isPremium: (first['isPremium'] as int) == 1,
        titleTranslations: translations,
      );
    }).toList();
  }

  Future<bool> isDatabaseEmpty() async {
    final db = await database;
    final result = await db.query('categories', limit: 1);
    return result.isEmpty;
  }

  Future<List<Category>> loadDefaultCategories() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/default_categories.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);

    return jsonList.map((jsonItem) => Category.fromJson(jsonItem)).toList();
  }

  Future<void> insertDefaultsIfEmpty() async {
    if (await isDatabaseEmpty()) {
      final categories = await loadDefaultCategories();

      for (var cat in categories) {
        await insertCategory(
          cat.id,
          cat.titleTranslations,
          cat.subcategory,
          cat.color,
          cat.isPremium,
          cat.img,
        );
      }
    }
  }
}
