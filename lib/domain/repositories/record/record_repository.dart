import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/record/record.dart';

abstract class RecordRepository {
  Future<Either<Failure, Record>> saveRecord({
    required String userId,
    required String type,
    required DateTime date,
    required String title,
    String? imageUrl,
    required String content,
    required double rating,
    Map<String, dynamic>? metadata,
  });

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
  });

  Future<Either<Failure, List<Record>>> getRecords({
    required String userId,
    int? year,
    int? month,
  });
}
