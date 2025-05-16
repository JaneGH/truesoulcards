
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:truesoulcards/data/models/category.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NewQuestion extends StatefulWidget {
  const NewQuestion({super.key});

  @override
  State<NewQuestion> createState() => _NewQuestionState();
}

class _NewQuestionState extends State<NewQuestion> {
  final TextEditingController _questionController = TextEditingController();
  Category? _selectedCategory;

  void _submitForm() {
    final question = _questionController.text;
    final category = _selectedCategory;

    if (question.isNotEmpty && category != null) {
      // // Handle submission (e.g., send to server, save locally, etc.)
      // print('Question: $question');
      // print('Category: $category');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question submitted!')),
      );
      setState(() {
        _questionController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in both fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> _categories = ['Math', 'Science', 'History', 'Tech'];
    return Scaffold (
      appBar: AppBar(
        title: const Text("New question")
        ),
        body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    labelText: 'Question',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 20),
                // DropdownButtonFormField<Category>(
                //   decoration: InputDecoration(
                //     labelText: 'Select a category',
                //     border: OutlineInputBorder(),
                //   ),
                //   value: _selectedCategory,
                //   items: userCategories.map((category) {
                //     return DropdownMenuItem<Category>(
                //       value: category,
                //       child: Row(
                //         children: [
                //           Container(
                //             width: 10,
                //             height: 10,
                //             margin: const EdgeInsets.only(right: 8),
                //             decoration: BoxDecoration(
                //               color: Color(category.color),
                //               shape: BoxShape.circle,
                //             ),
                //           ),
                //           Text(category.title),
                //         ],
                //       ),
                //     );
                //   }).toList(),
                //   onChanged: (Category? newValue) {
                //     setState(() {
                //       _selectedCategory = newValue;
                //     });
                //   },
                // ),

                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the form screen
                      },
                      child: Text('Close'),
                    ),

                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Submit'),
                    ),

                  ],
                ),

            ],
          ),
        )
       );
  }
}
