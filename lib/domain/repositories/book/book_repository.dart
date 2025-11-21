import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/book/book.dart';

abstract class BookRepository {
  Future<Either<Failure, List<Book>>> searchBooks({
    required String query,
    int start = 1,
    int display = 10,
  });
}
