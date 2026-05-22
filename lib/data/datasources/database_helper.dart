import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/data/models/custom_category.dart';
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
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE categories (
          id TEXT NOT NULL,
          subcategory TEXT NOT NULL,
          color INTEGER NOT NULL,
          img TEXT NOT NULL,
          isPremium INTEGER NOT NULL DEFAULT 0,
          is_system INTEGER NOT NULL DEFAULT 1,
          created_at INTEGER
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

        await db.execute(
          'CREATE UNIQUE INDEX idx_categories_id ON categories(id)',
        );
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE categories ADD COLUMN is_system INTEGER NOT NULL DEFAULT 1',
          );
          await db.execute(
            'ALTER TABLE categories ADD COLUMN created_at INTEGER',
          );
          await db.execute(
            "UPDATE categories SET is_system = 0 WHERE id LIKE 'usr_%'",
          );
        }
        if (oldVersion < 3) {
          await _dedupeCategoriesAndEnsureUniqueId(db);
        }
      },
    );
  }

  Future<void> insertCategory(
    String categoryId,
    Map<String, String> titleTranslations,
    String subcategory,
    int color,
    bool isPremium,
    String img, {
    bool isSystem = true,
    int? createdAt,
  }) async {
    final db = await instance.database;
    await db.insert('categories', {
      'id': categoryId,
      'color': color,
      'img': img,
      'isPremium': isPremium ? 1 : 0,
      'subcategory': subcategory,
      'is_system': isSystem ? 1 : 0,
      'created_at': createdAt,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.delete(
      'category_translations',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );

    for (var entry in titleTranslations.entries) {
      await insertCategoryTranslation(categoryId, entry.key, entry.value);
    }
  }

  Future<void> _dedupeCategoriesAndEnsureUniqueId(Database db) async {
    final rows = await db.query('categories', orderBy: 'rowid DESC');
    final seen = <String>{};
    for (final row in rows) {
      final id = row['id'] as String;
      if (seen.contains(id)) {
        await db.delete(
          'categories',
          where: 'rowid = ?',
          whereArgs: [row['rowid']],
        );
      } else {
        seen.add(id);
      }
    }
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_categories_id ON categories(id)',
    );
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

  Future<void> updateQuestion(
    int questionId,
    Map<String, String> translations,
  ) async {
    final db = await instance.database;
    for (final entry in translations.entries) {
      final languageCode = entry.key;
      final text = entry.value;

      final updated = await db.update(
        'question_translations',
        {'text': text},
        where: 'question_id = ? AND language_code = ?',
        whereArgs: [questionId, languageCode],
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      if (updated == 0) {
        await insertQuestionTranslation(questionId, languageCode, text);
      }
    }
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
      where:
          "category_id IN (SELECT id FROM categories WHERE id NOT LIKE 'usr_%' AND id NOT LIKE 'custom_%')",
    );

    await db.delete(
      'question_translations',
      where: 'question_id IN (SELECT id FROM questions WHERE predefined = ?)',
      whereArgs: [true],
    );

    await db.delete('questions', where: 'predefined = ?', whereArgs: [true]);

    await db.delete(
      'categories',
      where: "id NOT LIKE 'usr_%' AND id NOT LIKE 'custom_%'",
    );
  }

  Map<String, String> _titleMapForCustom(
    String title,
    String primaryLanguageCode,
  ) {
    return {
      'en': title,
      'uk': title,
      'es': title,
      'it': title,
      'fr': title,
      'de': title,
      'pl': title,
      'pt': title,
      primaryLanguageCode: title,
    };
  }

  Future<CustomCategory> insertCustomCategory({
    required String title,
    required CategoryTabType tabType,
    required int color,
    required String iconName,
    required String primaryLanguageCode,
  }) async {
    final id = CustomCategory.generateId();
    final createdAt = DateTime.now().millisecondsSinceEpoch;
    final subcategory =
        tabType == CategoryTabType.adults ? 'adults' : 'kids';
    final titles = _titleMapForCustom(title, primaryLanguageCode);

    await insertCategory(
      id,
      titles,
      subcategory,
      color,
      false,
      iconName,
      isSystem: false,
      createdAt: createdAt,
    );

    return CustomCategory(
      id: id,
      title: title,
      tabType: tabType,
      color: color,
      iconName: iconName,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      isSystem: false,
    );
  }

  Future<void> updateCustomCategoryTitle({
    required String id,
    required String title,
    required String primaryLanguageCode,
  }) async {
    if (!isCustomCategoryId(id)) return;
    final db = await instance.database;
    final titles = _titleMapForCustom(title, primaryLanguageCode);

    await db.delete(
      'category_translations',
      where: 'category_id = ?',
      whereArgs: [id],
    );
    for (final entry in titles.entries) {
      await insertCategoryTranslation(id, entry.key, entry.value);
    }
  }

  Future<void> updateCustomCategory({
    required String id,
    required String title,
    required int color,
    required String iconName,
    required String primaryLanguageCode,
  }) async {
    if (!isCustomCategoryId(id)) return;
    final db = await instance.database;
    await db.update(
      'categories',
      {'color': color, 'img': iconName},
      where: 'id = ?',
      whereArgs: [id],
    );
    await updateCustomCategoryTitle(
      id: id,
      title: title,
      primaryLanguageCode: primaryLanguageCode,
    );
  }

  Future<void> deleteCustomCategory(String id) async {
    if (!isCustomCategoryId(id)) return;
    final db = await instance.database;

    final questions = await db.query(
      'questions',
      columns: ['id'],
      where: 'category = ?',
      whereArgs: [id],
    );

    for (final row in questions) {
      await deleteQuestion(row['id'] as int);
    }

    await db.delete(
      'category_translations',
      where: 'category_id = ?',
      whereArgs: [id],
    );
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<CustomCategory>> getCustomCategories(
    CategoryTabType tabType,
  ) async {
    final db = await instance.database;
    final subcategory =
        tabType == CategoryTabType.adults ? 'adults' : 'kids';

    final result = await db.rawQuery('''
    SELECT 
      c.id,
      c.subcategory,
      c.color,
      c.img,
      c.created_at,
      ct.language_code,
      ct.title
    FROM categories c
    LEFT JOIN category_translations ct ON c.id = ct.category_id
    WHERE c.id LIKE 'custom_%' AND c.subcategory = ?
    ORDER BY c.created_at ASC
  ''', [subcategory]);

    final grouped = groupBy(result, (row) => row['id'] as String);

    return grouped.entries.map((entry) {
      final rows = entry.value;
      final first = rows.first;
      final titleRow = rows.firstWhere(
        (r) => r['title'] != null,
        orElse: () => first,
      );
      final createdRaw = first['created_at'] as int?;
      return CustomCategory(
        id: first['id'] as String,
        title: (titleRow['title'] as String?) ?? '',
        tabType: tabType,
        color: first['color'] as int,
        iconName: first['img'] as String,
        createdAt: createdRaw != null
            ? DateTime.fromMillisecondsSinceEpoch(createdRaw)
            : DateTime.now(),
        isSystem: false,
      );
    }).toList();
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
          isSystem: false,
        );
      }
    }
  }
}
