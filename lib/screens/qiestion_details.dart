import 'package:flutter/material.dart';
import 'package:truesoulcards/models/question.dart';

class QuestionDetailsScreen extends StatelessWidget {
  const QuestionDetailsScreen({
    super.key,
    required this.question,
    // required this.onToggleFavorite,
  });

  final Question question;
  // final void Function(Question meal) onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(question.text), actions: [
          IconButton(
            onPressed: () {
              // onToggleFavorite(question);
            },
            icon: const Icon(Icons.star),
          )
        ]),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Image.network(
                "https://books.google.com/books/content?id=HestSXO362YC&printsec=frontcover&img=1&zoom=2&edge=curl&source=gbs_api",
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 14),
              Text(
                'Ingredients',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              // for (final ingredient in question.ingredients)
              //   Text(
              //     ingredient,
              //     style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              //       color: Theme.of(context).colorScheme.onBackground,
              //     ),
              //   ),
              const SizedBox(height: 24),
              Text(
                'Steps',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              // for (final step in meal.steps)
              //   Padding(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 12,
              //       vertical: 8,
              //     ),
              //     child: Text(
              //       step,
              //       textAlign: TextAlign.center,
              //       style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              //         color: Theme.of(context).colorScheme.onBackground,
              //       ),
              //     ),
              //   ),
            ],
          ),
        ));
  }
}