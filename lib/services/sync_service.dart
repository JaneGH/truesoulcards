import '../database/database_helper.dart';
import 'package:truesoulcards/services/data_service.dart';

class SyncService {
   final DataService dataService = DataService();
   final db = DatabaseHelper.instance;

  Future<void> syncFromAssets() async {
    await DatabaseHelper.instance.clearTable('questions');
    await DatabaseHelper.instance.clearTable('categories');
    await DatabaseHelper.instance.clearTable('question_translations');
    final data = await dataService.fetchAllQuestions();
    for (final entry in data.entries) {
      final questionData = entry.value;
      final category = questionData.category;
      await db.insertCategory(category.id, category.title, category.subcategory, category.color, category.img);
      for (final question in questionData.questions) {
        await db.insertQuestion(
          category.id,
          question.predefined,
          question.translations
        );
      }
    }
  }
}
