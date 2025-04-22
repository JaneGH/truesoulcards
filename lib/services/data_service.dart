import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truesoulcards/models/question_data.dart';

class DataService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? '';
  Future<List<String>> fetchCategories() async {
    if (baseUrl.isEmpty) {
      throw ArgumentError('Base URL is empty. Please check your environment configuration.');
    }
    final url = Uri.parse('${baseUrl}categories.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<String>();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<QuestionData> fetchQuestionsData(String categoryName) async {
    final prefs = await SharedPreferences.getInstance();
    final url = Uri.parse('${baseUrl}$categoryName.json');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        prefs.setString(categoryName, response.body); // Cache the response
        final jsonData = json.decode(response.body);
        return QuestionData.fromJson(jsonData);
      } else {
        throw Exception('Failed to load questions data');
      }
    } catch (_) {
      final cached = prefs.getString(categoryName);
      if (cached != null) {
        final jsonData = json.decode(cached);
        return QuestionData.fromJson(jsonData);
      } else {
        throw Exception('No data and no internet connection');
      }
    }
  }
}
