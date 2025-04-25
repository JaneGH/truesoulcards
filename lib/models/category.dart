import 'package:flutter/material.dart';

class Category {
  final String id;
  final String title;
  final int color;

  Category({required this.id, required this.title, required this.color});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      title: json['title'],
      color: int.parse(json['color'].toString()),
    );
  }
}
