import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/movie/movie.dart';
import 'package:weave/domain/repositories/movie/movie_repository.dart';

class SearchMoviesUseCase {
  final MovieRepository _repository;

  SearchMoviesUseCase(this._repository);

  Future<Either<Failure, List<Movie>>> call({
    required String query,
    int page = 1,
  }) async {
    return await _repository.searchMovies(query: query, page: page);
  }
}
