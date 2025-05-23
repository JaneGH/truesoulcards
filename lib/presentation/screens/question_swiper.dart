import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shake/shake.dart';
import 'package:truesoulcards/presentation/screens/qiestion_details.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';
import 'package:truesoulcards/presentation/providers/questions_provider.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:truesoulcards/data/models/question.dart';
import 'package:truesoulcards/presentation/widgets/shared/empty_page.dart';
import 'package:truesoulcards/core/services/settings_service.dart';

// Добавляем импорт локализации
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QuestionSwiperScreen extends ConsumerStatefulWidget {
  final List<Category> categories;

  const QuestionSwiperScreen({super.key, required this.categories});

  @override
  ConsumerState<QuestionSwiperScreen> createState() =>
      _QuestionSwiperScreenState();
}

class _QuestionSwiperScreenState extends ConsumerState<QuestionSwiperScreen> {
  late List<Category> categories;
  late List<String> categoryIds;
  late ShakeDetector shakeDetector;
  late PageController _pageController;

  List<Question>? _questions;
  bool _isLoading = true;
  bool _hasError = false;

  int _currentPage = 0;
  bool animationEnabled = true;
  final SettingsService _settingsService = SettingsService();

  static const _prefsKey = 'saved_game';

  @override
  void initState() {
    super.initState();
    categories = widget.categories;
    categoryIds = categories.map((c) => c.id).toList();
    _pageController = PageController(initialPage: _currentPage);

    _loadAnimationSetting();

    shakeDetector = ShakeDetector.autoStart(
      shakeThresholdGravity: 2.0,
      onPhoneShake: _onPhoneShake,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSavedGameAndAsk();
    });
  }

  void _initPageController() {
    _pageController.dispose();
    _pageController = PageController(initialPage: _currentPage);
  }

  Future<void> _loadAnimationSetting() async {
    final enabled = await _settingsService.getShowAnimation();
    setState(() {
      animationEnabled = enabled;
    });
  }

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  Future<void> _checkSavedGameAndAsk() async {
    final prefs = await _prefs;
    final saved = prefs.getString(_prefsKey);

    if (!mounted) return;

    if (saved != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(saved);
        final questionsJson = data['questions'] as List<dynamic>;
        final currentPage = data['currentPage'] as int;

        if (questionsJson.isNotEmpty && currentPage>0) {
          final continueGame = await showAdaptiveDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              final localization = AppLocalizations.of(context)!;
              return AlertDialog(
                title: Text(localization.continuePreviousGame),
                content: Text(localization.continuePreviousGameDescription),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(localization.newGame),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(localization.continueGame),
                  ),
                ],
              );
            },
          );

          if (continueGame == true) {
            await _loadSavedGame();
            return;
          } else {
            await _clearSavedGame();
          }
        }
      } catch (e) {
        await _loadQuestions();
      }
    }

    await _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await ref.read(
        randomQuestionsInListCategoriesProvider(categoryIds).future,
      );
      setState(() {
        _questions = questions;
        _isLoading = false;
        _hasError = false;
        _currentPage = 0;
      });
      _initPageController();
      await _saveGame();
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSavedGame() async {
    final prefs = await _prefs;
    final saved = prefs.getString(_prefsKey);
    if (saved == null) {
      await _loadQuestions();
      return;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(saved);
      final questionsJson = data['questions'] as List<dynamic>;
      final currentPage = data['currentPage'] as int;
      final savedCategoryIds = List<String>.from(data['categoryIds']);

      final loadedQuestions = questionsJson
          .map((q) => Question.fromJson(q as Map<String, dynamic>, ''))
          .toList();

      final restoredCategories = widget.categories
          .where((c) => savedCategoryIds.contains(c.id))
          .toList();

      if (!mounted) return;

      setState(() {
        _questions = loadedQuestions;
        _currentPage = currentPage;
        categories = restoredCategories;
        categoryIds = savedCategoryIds;
        _isLoading = false;
        _hasError = false;
      });
      _initPageController();
    } catch (e) {
      await _loadQuestions();
    }
  }

  Future<void> _saveGame() async {
    if (_questions == null) return;
    final prefs = await _prefs;

    final data = jsonEncode({
      'questions': _questions!.map((q) => q.toJson()).toList(),
      'currentPage': _currentPage,
      'categoryIds': categoryIds,
    });

    await prefs.setString(_prefsKey, data);
  }

  Future<void> _clearSavedGame() async {
    final prefs = await _prefs;
    await prefs.remove(_prefsKey);
  }

  @override
  void dispose() {
    shakeDetector.stopListening();
    _pageController.dispose();
    super.dispose();
  }

  void _onPhoneShake(ShakeEvent event) {
    if (_questions == null) return;

    if (_currentPage < (_questions!.length - 1)) {
      setState(() {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
      _saveGame();
    }
  }

  String _buildTitle(
      Map<String, Category> categoryMap,
      Map<String, String> languages,
      AppLocalizations localization,
      ) {
    if (_questions == null || _questions!.isEmpty) return localization.questions;

    final currentQuestion = _questions![_currentPage];
    final categoryTitle =
        categoryMap[currentQuestion.category]?.getTitle(languages['primary']!) ?? '';

    return '$categoryTitle (${_currentPage + 1}/${_questions!.length})';
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final languages = ref.watch(languageProvider);
    final categoryMap = {for (var c in categories) c.id: c};

    return Scaffold(
      appBar: AppBar(
        title: Text(_buildTitle(categoryMap, languages, localization)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(child: Text(localization.something_went_wrong))
          : (_questions == null || _questions!.isEmpty)
          ? EmptyPageWidget(
        title: localization.nothing_here_yet,
        subtitle: categories.isEmpty
            ? localization.time_to_choose_the_categories_for_the_game
            : localization.try_to_choose_different_category,
      )
          : PageView.builder(
        controller: _pageController,
        itemCount: _questions!.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
          _saveGame();
        },
        itemBuilder: (context, index) {
          final question = _questions![index];
          return QuestionDetailsScreen(
            question: question,
            color: question.color,
            animationEnabled: animationEnabled,
          );
        },
      ),
    );
  }
}
