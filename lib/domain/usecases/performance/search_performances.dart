import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/performance/performance.dart';
import 'package:weave/domain/repositories/performance/performance_repository.dart';

class SearchPerformancesUseCase {
  final PerformanceRepository _repository;

  SearchPerformancesUseCase(this._repository);

  Future<Either<Failure, List<Performance>>> call({
    required String query,
    int page = 1,
    int rows = 10,
  }) async {
    return await _repository.searchPerformances(
      query: query,
      page: page,
      rows: rows,
    );
  }
}
