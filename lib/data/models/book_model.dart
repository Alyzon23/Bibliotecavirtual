class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String fileUrl;
  final BookFormat format;
  final DateTime publishedDate;
  final List<String> categories;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.fileUrl,
    required this.format,
    required this.publishedDate,
    required this.categories,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      description: json['description'],
      coverUrl: json['coverUrl'],
      fileUrl: json['fileUrl'],
      format: BookFormat.values.firstWhere(
        (e) => e.toString().split('.').last == json['format'],
      ),
      publishedDate: DateTime.parse(json['publishedDate']),
      categories: List<String>.from(json['categories']),
    );
  }
}

enum BookFormat { pdf, epub }