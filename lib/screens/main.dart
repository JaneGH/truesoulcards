import 'package:flutter/material.dart';
import 'package:truesoulcards/screens/settings.dart';
import 'package:truesoulcards/widgets/main_drawer.dart';
import 'package:truesoulcards/models/question_data.dart';
import '../services/sync_service.dart';
import 'categories.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  Map<String, QuestionData> questionDataMap = {};

  @override
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final syncService = SyncService();
    await syncService.syncFromAssets();
    final data = await syncService.dataService.fetchAllQuestions();
    setState(() {
      questionDataMap = data;
    });
  }

  final List<Widget> _screens = [
    const CategoriesScreen(mode: ScreenMode.play),
    const SettingsScreen(),
  ];

  void _setScreen(String identifier) async {
    Navigator.of(context).pop();

    if (identifier == "settings") {
      final result = await Navigator.of(context).push<Map<Filter, bool>>(
        MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
      );
      print(result);
    } else if (identifier == "category_edit") {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (ctx) => const CategoriesScreen(mode: ScreenMode.edit,)),
      );
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
            label: 'Play',
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
