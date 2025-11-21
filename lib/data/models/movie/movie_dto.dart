import 'package:weave/domain/entities/movie/movie.dart';

class MovieDto extends Movie {
  const MovieDto({
    required super.title,
    super.overview,
    super.posterPath,
    super.backdropPath,
    super.releaseDate,
    super.voteAverage,
    super.id,
  });

  factory MovieDto.fromJson(Map<String, dynamic> json) {
    // TMDb 이미지 URL 생성 (base URL: https://image.tmdb.org/t/p/w500)
    String? posterPath;
    if (json['poster_path'] != null &&
        json['poster_path'].toString().isNotEmpty) {
      final path = json['poster_path'].toString();
      if (path.startsWith('http')) {
        posterPath = path;
      } else {
        posterPath = 'https://image.tmdb.org/t/p/w500$path';
      }
    }

    String? backdropPath;
    if (json['backdrop_path'] != null &&
        json['backdrop_path'].toString().isNotEmpty) {
      final path = json['backdrop_path'].toString();
      if (path.startsWith('http')) {
        backdropPath = path;
      } else {
        backdropPath = 'https://image.tmdb.org/t/p/w500$path';
      }
    }

    return MovieDto(
      title: json['title'] ?? json['name'] ?? '',
      overview: json['overview'],
      posterPath: posterPath,
      backdropPath: backdropPath,
      releaseDate: json['release_date'] ?? json['first_air_date'],
      voteAverage: json['vote_average'] != null
          ? (json['vote_average'] is num
                ? json['vote_average'].toDouble()
                : double.tryParse(json['vote_average'].toString()))
          : null,
      id: json['id'] != null
          ? (json['id'] is int
                ? json['id'] as int
                : int.tryParse(json['id'].toString()))
          : null,
    );
  }
}
