import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/models/category.dart';
import 'package:truesoulcards/screens/qiestion_details.dart';
import 'package:truesoulcards/providers/language_provider.dart';
import 'package:truesoulcards/providers/questions_provider.dart';
import 'package:shake/shake.dart';

import '../providers/categories_provider.dart';

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
     if (_currentPage < numberQuestions) {
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
              if (category != null) {
                return Text(category.getTitle(languages['primary']!));
              }
            }
            return const Text('Questions');
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
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Oops! Nothing here yet.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Time to choose the categories for the game!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
