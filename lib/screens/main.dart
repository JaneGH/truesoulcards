import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:truesoulcards/screens/settings.dart';
import 'package:truesoulcards/widgets/main_drawer.dart';
import 'package:truesoulcards/models/question_data.dart';
import 'package:truesoulcards/services/data_service.dart';
import 'categories.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final DataService dataService = DataService();

  List<String> categories = [];
  Map<String, QuestionData> questionDataMap = {};

  @override
  void initState() {
    super.initState();
    fetchAllCategoriesAndQuestions();
  }

  Future<void> fetchAllCategoriesAndQuestions() async {
    try {
      final categoryNames = await dataService.fetchCategories();

      for (String categoryName in categoryNames) {
        final categoryData = await dataService.fetchQuestionsData(categoryName);
        setState(() {
          categories.add(categoryName);
          questionDataMap[categoryName] = categoryData;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching categories and questions: $e");
      }
    }
  }

  final List<Widget> _screens = [
    const CategoriesScreen(),
    const SettingsScreen(),
  ];

  void _setScreen(String identifier) async{
    Navigator.of(context).pop();
    if (identifier == "settings") {
      final result = Navigator.of(context).push<Map<Filter, bool>>(
        MaterialPageRoute(builder: (ctx) => const SettingsScreen())
      );
      print(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: MainDrawer(onSelectScreen: _setScreen,),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
