import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/record/record.dart';
import 'package:weave/domain/repositories/record/record_repository.dart';

class GetRecordsUseCase {
  final RecordRepository _repository;

  GetRecordsUseCase(this._repository);

  Future<Either<Failure, List<Record>>> call({
    required String userId,
    int? year,
    int? month,
  }) async {
    return await _repository.getRecords(
      userId: userId,
      year: year,
      month: month,
    );
  }
}
