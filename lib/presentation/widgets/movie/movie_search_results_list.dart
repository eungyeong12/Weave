import 'package:flutter/material.dart';
import 'package:weave/domain/entities/movie/movie.dart';
import 'package:weave/presentation/widgets/movie/movie_item.dart';
import 'package:weave/presentation/screens/record/record_write_screen.dart';
import 'package:firebase_core/firebase_core.dart';

class MovieSearchResultsList extends StatelessWidget {
  final List<Movie> movies;
  final String Function(String) getProxiedImageUrl;
  final DateTime? selectedDate;

  const MovieSearchResultsList({
    super.key,
    required this.movies,
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
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return MovieItem(
          movie: movie,
          getProxiedImageUrl: getProxiedImageUrl,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecordWriteScreen(
                  type: RecordType.movie,
                  movie: movie,
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
