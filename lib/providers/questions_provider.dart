

// import 'package:truesoulcards/data/questions_data.dart';
// import 'package:truesoulcards/models/question.dart';
//
// // final questionProvider = Provider((ref){
// //   return availableQuestions;
// // });
//
// class QuestionsNotifier extends StateNotifier<List<Question>> {
//   QuestionsNotifier() : super (availableQuestions);
//   void addQuestions(Question question) {
//     state = [...state, question];
//
//   }
// }
// final questionProvider = StateNotifierProvider <QuestionsNotifier, List<Question>> ((ref){
//   return QuestionsNotifier();
// });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/models/question.dart';
import '../database/database_helper.dart';

final questionsProvider = FutureProvider<List<Question>>((ref) async {
  return await DatabaseHelper.instance.getAllQuestions();
});

final firstQuestionInCategoryProvider = FutureProvider.family<Question?, String>((ref, categoryId) async {
  final allQuestions = await ref.watch(questionsProvider.future);
  final questions = allQuestions.where((question) => question.category == categoryId).toList();
  if (questions.isEmpty) return null;
  return questions.first;
});

final randomQuestionInCategoryProvider = FutureProvider.family<Question?, String>((ref, categoryId) async {
  final allQuestions = await ref.watch(questionsProvider.future);
  final questions = allQuestions.where((question) => question.category == categoryId).toList();
  if (questions.isEmpty) return null;
  questions.shuffle();
  return questions.first;
});
