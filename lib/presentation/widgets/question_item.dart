import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:truesoulcards/data/models/question.dart';
import 'package:truesoulcards/presentation/providers/language_provider.dart';

class QuestionItem extends ConsumerWidget {
  const QuestionItem({
    super.key,
    required this.question,
    required this.onSelectQuestion,
  });

  final Question question;
  final void Function(Question question) onSelectQuestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languages = ref.watch(languageProvider);
    final locale = languages['primary'] ?? 'en';

    final Color primaryColor = Color(question.color);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 5,
        shadowColor: primaryColor.withAlpha((0.25 * 255).round()),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onSelectQuestion(question),
          splashColor: primaryColor.withAlpha((0.6 * 255).round()),
          highlightColor: Colors.transparent,
          child: Container(
            width: 140,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  primaryColor.withAlpha((0.05 * 255).round()),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 6,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withAlpha((0.2 * 255).round()),
                          blurRadius: 6,
                          offset: Offset(2, 0),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned.fill(
                  child: Opacity(
                    opacity: 0.09,
                    child: SvgPicture.asset(
                      'assets/svg/pattern.svg',
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Center(
                    child: Text(
                      question.getText(locale),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black.withAlpha((0.9 * 255).round()),
                        fontSize: 21,
                        shadows: [
                          Shadow(
                            blurRadius: 3,
                            color: primaryColor.withAlpha((0.4 * 255).round()),
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
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
