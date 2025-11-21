import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/data/datasources/firestore/firebase_firestore_datasource.dart';
import 'package:weave/data/datasources/storage/firebase_storage_datasource.dart';
import 'package:weave/domain/entities/diary/diary.dart';
import 'package:weave/domain/repositories/diary/diary_repository.dart';
import 'package:image_picker/image_picker.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;
  final FirebaseStorageDataSource _storageDatasource;

  DiaryRepositoryImpl(this._firestoreDatasource, this._storageDatasource);

  @override
  Future<Either<Failure, Diary>> saveDailyDiary({
    required String userId,
    required DateTime date,
    required String content,
    required List<String> imageFilePaths,
  }) async {
    try {
      // 1. 이미지 파일 경로를 XFile로 변환
      final imageFiles = imageFilePaths.map((path) => XFile(path)).toList();

      // 2. 이미지가 있으면 Storage에 업로드
      List<String> imageUrls = [];
      if (imageFiles.isNotEmpty) {
        final dateId =
            '${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';
        imageUrls = await _storageDatasource.uploadImages(
          userId: userId,
          dateId: dateId,
          imageFiles: imageFiles,
        );
      }

      // 3. Firestore에 일기 저장
      final diaryDto = await _firestoreDatasource.saveDailyDiary(
        userId: userId,
        date: date,
        content: content,
        imageUrls: imageUrls,
      );

      return Right(diaryDto);
    } catch (e) {
      return Left(Failure('일기 저장 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }
}
