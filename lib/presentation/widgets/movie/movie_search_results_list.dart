import 'package:flutter/material.dart';
import 'package:weave/domain/entities/movie/movie.dart';
import 'package:weave/presentation/widgets/movie/movie_item.dart';

class MovieSearchResultsList extends StatelessWidget {
  final List<Movie> movies;
  final String Function(String) getProxiedImageUrl;

  const MovieSearchResultsList({
    super.key,
    required this.movies,
    required this.getProxiedImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return MovieItem(movie: movie, getProxiedImageUrl: getProxiedImageUrl);
      },
    );
  }
}
