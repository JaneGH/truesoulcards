
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/questions_data.dart';
import 'package:truesoulcards/models/question.dart';

// final questionProvider = Provider((ref){
//   return availableQuestions;
// });

class QuestionsNotifier extends StateNotifier<List<Question>> {
  QuestionsNotifier() : super (availableQuestions);
  void addQuestions(Question question) {
    state = [...state, question];
    
  }
}
final questionProvider = StateNotifierProvider <QuestionsNotifier, List<Question>> ((ref){
  return QuestionsNotifier();
});