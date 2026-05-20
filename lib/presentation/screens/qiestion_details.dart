import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesoulcards/data/models/question.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';
import 'package:truesoulcards/presentation/widgets/shared/category_pattern_row.dart';
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
    _scheduleVisibility();
  }

  @override
  void didUpdateWidget(covariant QuestionDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationEnabled != widget.animationEnabled ||
        oldWidget.question.id != widget.question.id) {
      _scheduleVisibility();
    }
  }

  void _scheduleVisibility() {
    if (!widget.animationEnabled) {
      if (!_isVisible) {
        setState(() => _isVisible = true);
      }
      return;
    }

    setState(() => _isVisible = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _isVisible = true);
    });
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
    final surface = Theme.of(context).colorScheme.surface;

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.lerp(categoryColor, surface, 0.35)!
                  .withOpacity(0.85),
              surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
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
                            clipBehavior: Clip.none,
                            elevation: 0,
                            color: surface.withOpacity(0.94),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: BorderSide(
                                color: categoryColor.withOpacity(0.18),
                              ),
                            ),
                            shadowColor: categoryColor.withOpacity(0.2),
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                          fontWeight: FontWeight.w600,
                                          fontSize: fontSize,
                                          color: cs.onSurface,
                                          height: 1.35,
                                          letterSpacing: 0.1,
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
