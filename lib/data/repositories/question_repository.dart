import 'package:truesoulcards/data/models/question.dart';
import 'package:truesoulcards/data/datasources/database_helper.dart';

class QuestionRepository {
  final DatabaseHelper _dbHelper;

  QuestionRepository(this._dbHelper);

  Future<List<Question>> getAllQuestions() {
    return _dbHelper.getQuestions();
  }

  Future<List<Question>> getQuestionsByCategory(String categoryId) {
    return _dbHelper.getQuestions(categoryId: categoryId);
  }

  Future<Question?> getFirstQuestionInCategory(String categoryId) async {
    final questions = await getQuestionsByCategory(categoryId);
    if (questions.isEmpty) return null;
    return questions.first;
  }

  Future<List<Question>> getRandomQuestionsByCategory(String categoryId) async {
    final questions = await getQuestionsByCategory(categoryId);
    questions.shuffle();
    return questions;
  }

  Future<List<Question>> getRandomQuestionsByCategories(List<String> categoryIds) async {
    final allQuestions = await getAllQuestions();
    final filtered = allQuestions.where((q) => categoryIds.contains(q.category)).toList();
    filtered.shuffle();
    return filtered;
  }
}
