import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/data/datasources/book/naver_book_datasource.dart';
import 'package:weave/domain/entities/book/book.dart';
import 'package:weave/domain/repositories/book/book_repository.dart';

class BookRepositoryImpl implements BookRepository {
  final NaverBookDataSource _dataSource;

  BookRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Book>>> searchBooks({
    required String query,
    int start = 1,
    int display = 10,
  }) async {
    try {
      final books = await _dataSource.searchBooks(
        query: query,
        start: start,
        display: display,
      );
      return Right(books);
    } catch (e) {
      return Left(Failure('도서 검색 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }
}
