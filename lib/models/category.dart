class Category {
  final String id;
  final String title;
  final String subcategory;
  final int color;
  final String img;

  Category({
    required this.id,
    required this.title,
    required this.color,
    required this.subcategory,
    this.img = '',
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      title: json['title'],
      subcategory: json['subcategory'],
      color: int.parse(json['color'].toString()),
      img: json['img'] ?? '',
    );
  }
}
