import 'package:flutter/material.dart';

class BookSearchErrorState extends StatelessWidget {
  final String error;

  const BookSearchErrorState({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        error,
        style: TextStyle(color: Colors.red.shade400, fontSize: 16),
      ),
    );
  }
}
