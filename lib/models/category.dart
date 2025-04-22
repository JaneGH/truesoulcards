import 'package:flutter/material.dart';

class Category {
  final String id;
  final String title;
  final Color color;

  Category({required this.id, required this.title, required this.color});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      title: json['title'],
      color: _getColorFromString(json['color']),
    );
  }

   static Color _getColorFromString(String colorString) {
    switch (colorString) {
      case 'lightBlueAccent':
        return Colors.lightBlueAccent;
      case 'lime':
        return Colors.lime;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.lightBlueAccent;
    }
  }
}
