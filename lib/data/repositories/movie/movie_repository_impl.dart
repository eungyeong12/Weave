import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/data/datasources/movie/tmdb_movie_datasource.dart';
import 'package:weave/domain/entities/movie/movie.dart';
import 'package:weave/domain/repositories/movie/movie_repository.dart';

class MovieRepositoryImpl implements MovieRepository {
  final TmdbMovieDataSource _dataSource;

  MovieRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Movie>>> searchMovies({
    required String query,
    int page = 1,
  }) async {
    try {
      final movies = await _dataSource.searchMovies(query: query, page: page);
      return Right(movies);
    } catch (e) {
      return Left(Failure('영화 검색 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }
}
