import 'package:flutter/material.dart';
import 'package:weave/domain/entities/book/book.dart';
import 'package:weave/presentation/widgets/book/book_item.dart';

class BookSearchResultsList extends StatelessWidget {
  final List<Book> books;
  final String Function(String) getProxiedImageUrl;

  const BookSearchResultsList({
    super.key,
    required this.books,
    required this.getProxiedImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookItem(book: book, getProxiedImageUrl: getProxiedImageUrl);
      },
    );
  }
}
