import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/book/book.dart';
import 'package:weave/domain/repositories/book/book_repository.dart';

class SearchBooksUseCase {
  final BookRepository _repository;

  SearchBooksUseCase(this._repository);

  Future<Either<Failure, List<Book>>> call({
    required String query,
    int start = 1,
    int display = 10,
  }) async {
    return await _repository.searchBooks(
      query: query,
      start: start,
      display: display,
    );
  }
}
