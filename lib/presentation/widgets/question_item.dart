import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path/path.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:truesoulcards/data/models/question.dart';

import '../providers/language_provider.dart';

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
    final primaryLocale = languages['primary'] ?? 'en';
    return Card(
      margin: const EdgeInsets.all(18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          onSelectQuestion(question);
        },
        child: Stack(
          children: [
            SvgPicture.asset(
              'assets/svg/pattern.svg',
              height: 80,
              width: double.infinity,
              colorFilter: ColorFilter.mode(
                Color(question.color),
                BlendMode.srcIn,
              ),
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 44,
                ),
                child: Column(
                  children: [
                    Text(
                      question.getText(primaryLocale),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
