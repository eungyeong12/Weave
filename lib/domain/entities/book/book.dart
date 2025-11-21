class Book {
  final String title;
  final String author;
  final String? imageUrl;
  final String? description;
  final String? isbn;
  final String? publisher;
  final String? pubDate;

  const Book({
    required this.title,
    required this.author,
    this.imageUrl,
    this.description,
    this.isbn,
    this.publisher,
    this.pubDate,
  });
}
