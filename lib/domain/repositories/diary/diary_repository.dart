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

  Future<Either<Failure, Diary>> updateDailyDiary({
    required String diaryId,
    required String userId,
    required DateTime date,
    required String content,
    required List<String> existingImageUrls,
    required List<String> newImageFilePaths,
  });

  Future<Either<Failure, List<Diary>>> getDiaries({
    required String userId,
    int? year,
    int? month,
  });

  Future<Either<Failure, void>> deleteDailyDiary({
    required String diaryId,
    required String userId,
    required List<String> imageUrls,
  });
}
