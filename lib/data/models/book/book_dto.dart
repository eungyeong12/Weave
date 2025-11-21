import 'package:weave/domain/entities/book/book.dart';

class BookDto extends Book {
  const BookDto({
    required super.title,
    required super.author,
    super.imageUrl,
    super.description,
    super.isbn,
    super.publisher,
    super.pubDate,
  });

  factory BookDto.fromJson(Map<String, dynamic> json) {
    return BookDto(
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      imageUrl: json['image'],
      description: json['description'],
      isbn: json['isbn'],
      publisher: json['publisher'],
      pubDate: json['pubdate'],
    );
  }
}
