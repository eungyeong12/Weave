import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/diary/diary.dart';
import 'package:weave/domain/repositories/diary/diary_repository.dart';

class SaveDailyDiaryUseCase {
  final DiaryRepository repository;

  SaveDailyDiaryUseCase(this.repository);

  Future<Either<Failure, Diary>> call({
    required String userId,
    required DateTime date,
    required String content,
    required List<String> imageFilePaths,
  }) async {
    return await repository.saveDailyDiary(
      userId: userId,
      date: date,
      content: content,
      imageFilePaths: imageFilePaths,
    );
  }
}
