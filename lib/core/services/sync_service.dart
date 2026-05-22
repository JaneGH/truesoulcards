import '../../data/datasources/database_helper.dart';
import 'package:truesoulcards/core/services/data_service.dart';

class SyncService {
  final DataService dataService = DataService();
  final db = DatabaseHelper.instance;

  Future<void> syncRemoteQuestions() async {
    final data = await dataService.fetchAllQuestions(forceRefresh: true);
    await db.syncRemoteQuestionData(data);
  }
}
