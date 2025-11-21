import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/movie/movie.dart';
import 'package:weave/domain/usecases/movie/search_movies.dart';

class MovieSearchState {
  final bool isLoading;
  final List<Movie> movies;
  final String? error;

  const MovieSearchState({
    this.isLoading = false,
    this.movies = const [],
    this.error,
  });

  MovieSearchState copyWith({
    bool? isLoading,
    List<Movie>? movies,
    String? error,
    bool clearError = false,
  }) {
    return MovieSearchState(
      isLoading: isLoading ?? this.isLoading,
      movies: movies ?? this.movies,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MovieSearchViewModel extends StateNotifier<MovieSearchState> {
  final SearchMoviesUseCase _searchMoviesUseCase;

  MovieSearchViewModel(this._searchMoviesUseCase)
    : super(const MovieSearchState());

  Future<void> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(movies: [], clearError: true);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final Either<Failure, List<Movie>> result = await _searchMoviesUseCase(
        query: query,
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
            movies: [],
          );
        },
        (movies) {
          state = state.copyWith(
            isLoading: false,
            movies: movies,
            clearError: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '영화 검색 중 오류가 발생했습니다: $e',
        movies: [],
      );
    }
  }

  void clearSearch() {
    state = const MovieSearchState();
  }
}
