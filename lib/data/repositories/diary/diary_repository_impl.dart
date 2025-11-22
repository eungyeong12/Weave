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

  @override
  Future<Either<Failure, Diary>> updateDailyDiary({
    required String diaryId,
    required String userId,
    required DateTime date,
    required String content,
    required List<String> existingImageUrls,
    required List<String> newImageFilePaths,
  }) async {
    try {
      // 1. 새로 추가한 이미지 파일 경로를 XFile로 변환
      final newImageFiles = newImageFilePaths
          .map((path) => XFile(path))
          .toList();

      // 2. 새로 추가한 이미지가 있으면 Storage에 업로드
      List<String> newImageUrls = [];
      if (newImageFiles.isNotEmpty) {
        final dateId =
            '${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';
        newImageUrls = await _storageDatasource.uploadImages(
          userId: userId,
          dateId: dateId,
          imageFiles: newImageFiles,
        );
      }

      // 3. 기존 이미지 URL과 새 이미지 URL 합치기
      final allImageUrls = [...existingImageUrls, ...newImageUrls];

      // 4. Firestore에 일기 업데이트
      final diaryDto = await _firestoreDatasource.updateDailyDiary(
        diaryId: diaryId,
        userId: userId,
        date: date,
        content: content,
        imageUrls: allImageUrls,
      );

      return Right(diaryDto);
    } catch (e) {
      return Left(Failure('일기 업데이트 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Diary>>> getDiaries({
    required String userId,
    int? year,
    int? month,
  }) async {
    try {
      final diaries = await _firestoreDatasource.getDiaries(
        userId: userId,
        year: year,
        month: month,
      );
      return Right(diaries);
    } catch (e) {
      return Left(Failure('일기 조회 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDailyDiary({
    required String diaryId,
    required String userId,
    required List<String> imageUrls,
  }) async {
    try {
      // 1. Storage에서 이미지 삭제
      if (imageUrls.isNotEmpty) {
        await _storageDatasource.deleteImages(imageUrls);
      }

      // 2. Firestore에서 일기 문서 삭제
      await _firestoreDatasource.deleteDailyDiary(
        diaryId: diaryId,
        userId: userId,
      );

      return const Right(null);
    } catch (e) {
      return Left(Failure('일기 삭제 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }
}
