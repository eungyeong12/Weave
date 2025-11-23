import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/book/book.dart';
import 'package:weave/domain/usecases/book/search_books.dart';

class BookSearchState {
  final bool isLoading;
  final List<Book> books;
  final String? error;

  const BookSearchState({
    this.isLoading = false,
    this.books = const [],
    this.error,
  });

  BookSearchState copyWith({
    bool? isLoading,
    List<Book>? books,
    String? error,
    bool clearError = false,
  }) {
    return BookSearchState(
      isLoading: isLoading ?? this.isLoading,
      books: books ?? this.books,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class BookSearchViewModel extends StateNotifier<BookSearchState> {
  final SearchBooksUseCase _searchBooksUseCase;

  BookSearchViewModel(this._searchBooksUseCase)
    : super(const BookSearchState());

  Future<void> searchBooks(String query) async {

    if (query.trim().isEmpty) {
      state = state.copyWith(books: [], clearError: true);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final Either<Failure, List<Book>> result = await _searchBooksUseCase(
        query: query,
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
            books: [],
          );
        },
        (books) {
          state = state.copyWith(
            isLoading: false,
            books: books,
            clearError: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '도서 검색 중 예상치 못한 오류가 발생했습니다.',
        books: [],
      );
    }
  }

  void clearSearch() {
    state = state.copyWith(books: [], clearError: true);
  }
}
