import 'package:flutter/material.dart';

class BookSearchEmptyState extends StatelessWidget {
  final String message;

  const BookSearchEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
      ),
    );
  }
}
