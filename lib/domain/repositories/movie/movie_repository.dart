import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/movie/movie.dart';

abstract class MovieRepository {
  Future<Either<Failure, List<Movie>>> searchMovies({
    required String query,
    int page = 1,
  });
}
