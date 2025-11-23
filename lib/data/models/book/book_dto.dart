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
    // 이미지 URL에서 HTML 태그 제거 및 정리
    String? imageUrl;
    if (json['image'] != null) {
      String image = json['image'].toString();
      // HTML 태그 제거
      image = image.replaceAll(RegExp(r'<[^>]*>'), '').trim();
      // 빈 문자열이 아니면 사용
      if (image.isNotEmpty) {
        imageUrl = image;
      }
    }

    return BookDto(
      title: (json['title'] ?? '').toString().replaceAll(
        RegExp(r'<[^>]*>'),
        '',
      ),
      author: (json['author'] ?? '').toString().replaceAll(
        RegExp(r'<[^>]*>'),
        '',
      ),
      imageUrl: imageUrl,
      description: json['description']?.toString().replaceAll(
        RegExp(r'<[^>]*>'),
        '',
      ),
      isbn: json['isbn']?.toString(),
      publisher: json['publisher']?.toString(),
      pubDate: json['pubdate']?.toString(),
    );
  }
}
