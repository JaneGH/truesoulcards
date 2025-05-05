import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/models/category.dart';
import 'package:truesoulcards/screens/qiestion_details.dart';
import '../providers/questions_provider.dart';
import 'package:shake/shake.dart';

class QuestionSwiperScreen extends ConsumerStatefulWidget {
  final Category category;


  const QuestionSwiperScreen({super.key, required this.category});

  @override
  ConsumerState<QuestionSwiperScreen> createState() => _QuestionSwiperScreenState();
}

class _QuestionSwiperScreenState extends ConsumerState<QuestionSwiperScreen> {
  late String categoryId;
  late Category category;
  late ShakeDetector shakeDetector;
  late PageController _pageController;
  int _currentPage = 0;
  int numberQuestions = 0;

  @override
  void initState() {
    super.initState();
    categoryId = widget.category.id;
    category   = widget.category;
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
     print('Shake detected!');
     print(_currentPage);
     print(numberQuestions);
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
    final questionAsyncValue = ref.watch(randomQuestionsInCategoryProvider(categoryId));

    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: questionAsyncValue.when(
        data: (questions) {
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
              return QuestionDetailsScreen(question: question, color: category.color,);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
