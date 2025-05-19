import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/models/question.dart';
import 'package:truesoulcards/data/repositories/question_repository.dart';
import 'package:truesoulcards/data/datasources/database_helper.dart';

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepository(DatabaseHelper.instance);
});

final questionsProvider = FutureProvider<List<Question>>((ref) {
  final repository = ref.watch(questionRepositoryProvider);
  return repository.getAllQuestions();
});

final questionsProviderByCategory = FutureProvider.family<List<Question>, String>((ref, categoryId) {
  final repository = ref.watch(questionRepositoryProvider);
  return repository.getQuestionsByCategory(categoryId);
});

final firstQuestionInCategoryProvider = FutureProvider.family<Question?, String>((ref, categoryId) {
  final repository = ref.watch(questionRepositoryProvider);
  return repository.getFirstQuestionInCategory(categoryId);
});

final randomQuestionsInCategoryProvider = FutureProvider.family<List<Question>, String>((ref, categoryId) {
  final repository = ref.watch(questionRepositoryProvider);
  return repository.getRandomQuestionsByCategory(categoryId);
});

final randomQuestionsInListCategoriesProvider = FutureProvider.family<List<Question>, List<String>>((ref, categoryIds) {
  final repository = ref.watch(questionRepositoryProvider);
  return repository.getRandomQuestionsByCategories(categoryIds);
});
