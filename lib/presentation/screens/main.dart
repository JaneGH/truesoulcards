import 'package:flutter/material.dart';
import 'package:truesoulcards/presentation/screens/question_swiper.dart';
import 'package:truesoulcards/presentation/screens/settings.dart';
import 'package:truesoulcards/presentation/widgets/main_drawer.dart';
import 'package:truesoulcards/data/datasources/database_helper.dart';
import 'package:truesoulcards/core/services/sync_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'categories.dart';
import 'categories_settings.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool isDownloading = false;
  bool _isLoading = false;

  final List<Widget> _screens = [
    const CategoriesScreen(mode: ScreenModeCategories.play),
  ];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  void _fetchInitialData() async {
    setState(() {
      _isLoading = true;
    });
    await DatabaseHelper.instance.insertDefaultsIfEmpty();
    final syncService = SyncService();
    bool isDatabaseEmpty = await DatabaseHelper.instance.isDatabaseEmpty();
    if (isDatabaseEmpty) {
      await syncService.syncFromAssets();
      await syncService.dataService.fetchAllQuestions();
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _setScreen(String identifier) async {
    Navigator.of(context).pop();

    switch (identifier) {
      case 'settings':
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => const SettingsScreen(),
          ),
        );
        break;
      case 'home':
        setState(() => _currentIndex = 0);
        print("Switching to screen index: $_currentIndex");
        break;
      case "question_swiper":
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => const QuestionSwiperScreen(categories: []),
          ),
        );
        break;
      case "categories_settings":
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => const CategoriesSettingsScreen()),
        );
        break;
      case "category_edit":
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (ctx) =>
                    const CategoriesScreen(mode: ScreenModeCategories.edit),
          ),
        );
        break;
    }
  }

  // void setDownloadingState(bool isDownloading) {
  //   setState(() {
  //     this.isDownloading = isDownloading;
  //   });
  // }

  Future<void> _refreshQuestions() async {
    if (isDownloading) return;
    setState(() => isDownloading = true);

    try {
      final syncService = SyncService();
      await syncService.syncFromAssets();
      await syncService.dataService.fetchAllQuestions();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failed_to_load_questions),
          backgroundColor: Colors.red[200],
        ),
      );
    } finally {
      setState(() => isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        drawer: MainDrawer(
          onSelectScreen: _setScreen,
          onRefreshQuestions: _refreshQuestions,
          isDownloading: isDownloading,
        ),
        body:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) async {
            if (index == 1) {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
              );
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.category),
              label: loc.explore,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: loc.settings,
            ),
            // BottomNavigationBarItem(
            //   icon: const Icon(Icons.vibration),
            //   label: loc.play,
            // ),
            ],
        ),
      ),
    );
  }
}
