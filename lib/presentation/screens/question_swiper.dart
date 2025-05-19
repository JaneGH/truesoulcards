import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/presentation/screens/qiestion_details.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';
import 'package:truesoulcards/presentation/providers/questions_provider.dart';
import 'package:shake/shake.dart';
import 'package:truesoulcards/data/models/category.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QuestionSwiperScreen extends ConsumerStatefulWidget {
  final List<Category> categories;
  const QuestionSwiperScreen({super.key, required this.categories});

  @override
  ConsumerState<QuestionSwiperScreen> createState() => _QuestionSwiperScreenState();
}

class _QuestionSwiperScreenState extends ConsumerState<QuestionSwiperScreen> {
  late List<Category> categories;
  late List<String> categoryIds;
  late ShakeDetector shakeDetector;
  late PageController _pageController;
  int _currentPage = 0;
  int numberQuestions = 0;

  @override
  void initState() {
    super.initState();
    categories = widget.categories;
    categoryIds = categories.map((c) => c.id).toList();
    _pageController = PageController();
    shakeDetector = ShakeDetector.autoStart(
        onPhoneShake: (ShakeEvent event) {_onPhoneShake();
        }
    );
  }

  @override
  void dispose() {
    shakeDetector.stopListening();
    _pageController.dispose();
    super.dispose();
  }

   void _onPhoneShake() {
     if (_currentPage < numberQuestions-1) {
      setState(() {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryMap = { for (var c in categories) c.id: c };
    final questionsAsyncValue = ref.watch(randomQuestionsInListCategoriesProvider(categoryIds));
    final languages = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: questionsAsyncValue.maybeWhen(
          data: (questions) {
            if (questions.isNotEmpty) {
              final question = questions[_currentPage];
              final category = categoryMap[question.category];
              final total = questions.length;
              if (category != null) {
                return Text('${category.getTitle(languages['primary']!)} (${_currentPage + 1}/$total)');
              }
              return Text(AppLocalizations.of(context)!.questions);
            }
            return Text(AppLocalizations.of(context)!.questions);
          },
          orElse: () => const Text(''),
        ),
      ),
      body: questionsAsyncValue.when(
        data: (questions) {

          if (questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.nothing_here_yet,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.time_to_choose_the_categories_for_the_game,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }

          numberQuestions = questions.length;
          return PageView.builder(
            controller: _pageController,
            itemCount: questions.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final question = questions[index];
              return QuestionDetailsScreen(question: question, color: question.color,);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
