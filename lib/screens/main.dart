import 'package:flutter/material.dart';
import 'package:truesoulcards/screens/settings.dart';
import 'package:truesoulcards/widgets/main_drawer.dart';
import 'package:truesoulcards/database/database_helper.dart';
import 'package:truesoulcards/services/sync_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'categories.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool isDownloading = false;
  bool _isLoading = false;

  @override
  @override
  void initState() {
    super.initState();
    _loadDataForTheFirstTime();
  }

  void _loadDataForTheFirstTime() async {
    setState(() {
      _isLoading = true;
    });
    final syncService = SyncService();
    bool isDatabaseEmpty = await DatabaseHelper.instance.isDatabaseEmpty();
    if (isDatabaseEmpty) {
      await syncService.syncFromAssets();
     syncService.dataService.fetchAllQuestions();
    }
    setState(() {
      _isLoading = false;
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

  void setDownloadingState(bool isDownloading) {
    setState(() {
      this.isDownloading = isDownloading;
    });
  }

  Future<void> _refreshQuestions() async {
    if (isDownloading) return;
    setDownloadingState(true);
    try {
      final syncService = SyncService();
      await syncService.syncFromAssets();
      await syncService.dataService.fetchAllQuestions();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load questions. Please try again later.'),
          backgroundColor: Colors.red[200],
        ),
      );
    }finally{
      setDownloadingState(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: MainDrawer(onSelectScreen: _setScreen, onRefreshQuestions: _refreshQuestions, isDownloading: isDownloading),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.category),
            label: AppLocalizations.of(context)!.explore,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.vibration),
            label: AppLocalizations.of(context)!.play,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }
}
