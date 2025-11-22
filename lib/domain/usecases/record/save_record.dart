import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/record/record.dart';
import 'package:weave/domain/repositories/record/record_repository.dart';

class SaveRecordUseCase {
  final RecordRepository _repository;

  SaveRecordUseCase(this._repository);

  Future<Either<Failure, Record>> call({
    required String userId,
    required String type,
    required DateTime date,
    required String title,
    String? imageUrl,
    required String content,
    required double rating,
    Map<String, dynamic>? metadata,
  }) async {
    return await _repository.saveRecord(
      userId: userId,
      type: type,
      date: date,
      title: title,
      imageUrl: imageUrl,
      content: content,
      rating: rating,
      metadata: metadata,
    );
  }
}

class UpdateRecordUseCase {
  final RecordRepository _repository;

  UpdateRecordUseCase(this._repository);

  Future<Either<Failure, Record>> call({
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
    return await _repository.updateRecord(
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
  }
}
