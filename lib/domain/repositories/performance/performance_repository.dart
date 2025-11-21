import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/performance/performance.dart';

abstract class PerformanceRepository {
  Future<Either<Failure, List<Performance>>> searchPerformances({
    required String query,
    int page = 1,
    int rows = 10,
  });
}
