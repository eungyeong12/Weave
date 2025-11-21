import 'package:flutter/material.dart';
import 'package:weave/domain/entities/book/book.dart';
import 'package:weave/presentation/widgets/book/book_item.dart';
import 'package:weave/presentation/screens/record/record_write_screen.dart';
import 'package:firebase_core/firebase_core.dart';

class BookSearchResultsList extends StatelessWidget {
  final List<Book> books;
  final String Function(String) getProxiedImageUrl;
  final DateTime? selectedDate;

  const BookSearchResultsList({
    super.key,
    required this.books,
    required this.getProxiedImageUrl,
    this.selectedDate,
  });

  String _getProxiedImageUrl(String originalUrl) {
    try {
      final projectId = Firebase.app().options.projectId;
      final encodedUrl = Uri.encodeComponent(originalUrl);
      return 'https://us-central1-$projectId.cloudfunctions.net/proxyImage?url=$encodedUrl';
    } catch (e) {
      return originalUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookItem(
          book: book,
          getProxiedImageUrl: getProxiedImageUrl,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecordWriteScreen(
                  type: RecordType.book,
                  book: book,
                  getProxiedImageUrl: _getProxiedImageUrl,
                  selectedDate: selectedDate ?? DateTime.now(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
