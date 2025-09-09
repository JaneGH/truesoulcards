import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/models/question.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';
import 'package:truesoulcards/presentation/widgets/shared/category_pattern_row.dart';
import 'package:truesoulcards/theme/app_colors.dart';
import 'package:truesoulcards/presentation/providers/font_provider.dart';

class QuestionDetailsScreen extends ConsumerStatefulWidget {
  const QuestionDetailsScreen({
    super.key,
    required this.question,
    required this.color,
    this.animationEnabled = false,
  });

  final Question question;
  final int color;
  final bool animationEnabled;

  @override
  ConsumerState<QuestionDetailsScreen> createState() =>
      _QuestionDetailsScreenState();
}

class _QuestionDetailsScreenState extends ConsumerState<QuestionDetailsScreen> {
  bool _isVisible = false;
  late String currentLanguageKey;

  @override
  void initState() {
    super.initState();
    currentLanguageKey = 'primary';

    if (widget.animationEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isVisible = true;
        });
      });
    } else {
      _isVisible = true;
    }
  }

  void toggleLanguage() {
    setState(() {
      currentLanguageKey = currentLanguageKey == 'primary' ? 'secondary' : 'primary';
    });
  }

  @override
  Widget build(BuildContext context) {
    final languages = ref.watch(languageProvider);
    final categoryColor = Color(widget.color);
    final fontSize = ref.watch(fontSizeProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              categoryColor.withAlpha((0.7 * 255).round()),
              AppColors.backgroundLight,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0)),
              const SizedBox(height: 16),
              Expanded(
                child: GestureDetector(
                  onTap: toggleLanguage,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _isVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: AnimatedSlide(
                        offset: _isVisible ? Offset.zero : const Offset(0, 0.1),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        child: AnimatedScale(
                          scale: _isVisible ? 1.0 : 0.9,
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeInOut,
                          child: Card(
                            elevation: 12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CategoryPatternRow(color: categoryColor),
                                  const SizedBox(height: 24),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        widget.question.getText(
                                          languages[currentLanguageKey]!,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          // color: AppColors.darkBrown,
                                          fontSize: fontSize,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  CategoryPatternRow(color: categoryColor),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
