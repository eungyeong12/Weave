import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/data/datasources/performance/kopis_datasource.dart';
import 'package:weave/domain/entities/performance/performance.dart';
import 'package:weave/domain/repositories/performance/performance_repository.dart';

class PerformanceRepositoryImpl implements PerformanceRepository {
  final KopisDataSource _dataSource;

  PerformanceRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Performance>>> searchPerformances({
    required String query,
    int page = 1,
    int rows = 10,
  }) async {
    try {
      final performances = await _dataSource.searchPerformances(
        query: query,
        page: page,
        rows: rows,
      );
      return Right(performances);
    } catch (e) {
      return Left(Failure('공연 검색 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }
}
