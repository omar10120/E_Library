class BookModel {
  final String id;
  final String title;
  final String type;
  final double price;
  final String authorFullName;
  final String publisherName;

  BookModel({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    required this.authorFullName,
    required this.publisherName,
  });

  factory BookModel.fromMap(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      price: (json['price'] as num).toDouble(),
      authorFullName: json['authorFullName'] ?? '',
      publisherName: json['publisherName'] ?? '',
    );
  }
}
