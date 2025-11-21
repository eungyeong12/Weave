import 'package:flutter/material.dart';

class BookSearchLoadingState extends StatelessWidget {
  const BookSearchLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
