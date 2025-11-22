import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/data/datasources/firestore/firebase_firestore_datasource.dart';
import 'package:weave/domain/entities/record/record.dart';
import 'package:weave/domain/repositories/record/record_repository.dart';

class RecordRepositoryImpl implements RecordRepository {
  final FirebaseFirestoreDatasource _firestoreDatasource;

  RecordRepositoryImpl(this._firestoreDatasource);

  @override
  Future<Either<Failure, Record>> saveRecord({
    required String userId,
    required String type,
    required DateTime date,
    required String title,
    String? imageUrl,
    required String content,
    required double rating,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final recordDto = await _firestoreDatasource.saveRecord(
        userId: userId,
        type: type,
        date: date,
        title: title,
        imageUrl: imageUrl,
        content: content,
        rating: rating,
        metadata: metadata,
      );
      return Right(recordDto);
    } catch (e) {
      return Left(Failure('기록 저장 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Record>> updateRecord({
    required String recordId,
    required String userId,
    required String type,
    required DateTime date,
    required String title,
    String? imageUrl,
    required String content,
    required double rating,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final recordDto = await _firestoreDatasource.updateRecord(
        recordId: recordId,
        userId: userId,
        type: type,
        date: date,
        title: title,
        imageUrl: imageUrl,
        content: content,
        rating: rating,
        metadata: metadata,
      );
      return Right(recordDto);
    } catch (e) {
      return Left(Failure('기록 업데이트 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Record>>> getRecords({
    required String userId,
    int? year,
    int? month,
  }) async {
    try {
      final records = await _firestoreDatasource.getRecords(
        userId: userId,
        year: year,
        month: month,
      );
      return Right(records);
    } catch (e) {
      return Left(Failure('기록 조회 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }
}
