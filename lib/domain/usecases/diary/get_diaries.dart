import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/diary/diary.dart';
import 'package:weave/domain/repositories/diary/diary_repository.dart';

class GetDiariesUseCase {
  final DiaryRepository _repository;

  GetDiariesUseCase(this._repository);

  Future<Either<Failure, List<Diary>>> call({
    required String userId,
    int? year,
    int? month,
  }) async {
    return await _repository.getDiaries(
      userId: userId,
      year: year,
      month: month,
    );
  }
}
