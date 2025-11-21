import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/diary/diary.dart';

abstract class DiaryRepository {
  Future<Either<Failure, Diary>> saveDailyDiary({
    required String userId,
    required DateTime date,
    required String content,
    required List<String> imageFilePaths,
  });
}
