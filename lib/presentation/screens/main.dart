import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/core/services/analytics_service.dart';
import 'package:truesoulcards/presentation/providers/analytics_provider.dart';
import 'package:truesoulcards/presentation/providers/category_picker_ui_provider.dart';
import 'package:truesoulcards/presentation/screens/information.dart';
import 'package:truesoulcards/presentation/screens/question_swiper.dart';
import 'package:truesoulcards/presentation/screens/settings.dart';
import 'package:truesoulcards/presentation/widgets/main_drawer.dart';
import 'package:truesoulcards/theme/app_icons.dart';
import 'package:truesoulcards/data/datasources/database_helper.dart';
import 'package:truesoulcards/core/services/sync_service.dart';
import 'package:truesoulcards/l10n/app_localizations.dart';
import 'categories.dart';
import 'categories_settings.dart';
import 'UploadQuestionsScreen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  bool isDownloading = false;
  bool _isLoading = false;

  final List<Widget> _screens = [
    const CategoriesScreen(mode: ScreenModeCategories.play),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).logManualScreenView(
        screenName: AnalyticsScreens.home,
        screenClass: 'MainScreen',
      );
    });

    _fetchInitialData();
  }

  void _fetchInitialData() async {
    setState(() {
      _isLoading = true;
    });

    bool isDatabaseEmpty =
    await DatabaseHelper.instance.isDatabaseEmpty();

    if (isDatabaseEmpty) {
      final syncService = SyncService();

      await DatabaseHelper.instance.insertDefaultsIfEmpty();
      await syncService.syncRemoteQuestions();
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

      case 'information':
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => const InfoScreen(),
          ),
        );
        break;

      case 'upload':
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => const UploadQuestionsScreen(),
          ),
        );
        break;

      case 'home':
        setState(() => _currentIndex = 0);
        break;

      case "question_swiper":
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) =>
            const QuestionSwiperScreen(categories: []),
          ),
        );
        break;

      case "categories_settings":
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) =>
            const CategoriesSettingsScreen(),
          ),
        );
        break;

      case "category_edit":
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => const CategoriesScreen(
              mode: ScreenModeCategories.edit,
            ),
          ),
        );
        break;
    }
  }

  Future<void> _refreshQuestions() async {
    if (isDownloading) return;

    setState(() => isDownloading = true);

    try {
      final syncService = SyncService();

      await syncService.syncRemoteQuestions();
      await syncService.dataService.fetchAllQuestions();
    } catch (e) {
      if (!mounted) return;

      final cs = Theme.of(context).colorScheme;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!
                .failed_to_load_questions,
            style:
            Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onErrorContainer,
            ),
          ),
          backgroundColor: cs.errorContainer,
        ),
      );
    } finally {
      setState(() => isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    var appBarText =
        AppLocalizations.of(context)!.pick_category;

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            appBarText,
            style: theme.appBarTheme.titleTextStyle?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),

        drawer: MainDrawer(
          onSelectScreen: _setScreen,
          onRefreshQuestions: _refreshQuestions,
          isDownloading: isDownloading,
        ),

        body: _isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : _screens[_currentIndex],

        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              16,
              6,
              16,
              10,
            ),
            color: Colors.white.withOpacity(0.92),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(26),
                    onTap: () {
                      ref
                          .read(categoriesPlayInvokerProvider)
                          ?.call();
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF8ED8FF),
                            Color(0xFF6CC7FF),
                          ],
                        ),
                        borderRadius:
                        BorderRadius.circular(26),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: Color(0xFF4A3428),
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            localization.play,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: Color(0xFF4A3428),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 18),

                InkWell(
                  borderRadius:
                  BorderRadius.circular(18),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) =>
                        const SettingsScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      AppIcons.settings,
                      size: AppIconSizes.md,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}