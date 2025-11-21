import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/performance/performance.dart';
import 'package:weave/domain/usecases/performance/search_performances.dart';

class PerformanceSearchState {
  final bool isLoading;
  final List<Performance> performances;
  final String? error;

  const PerformanceSearchState({
    this.isLoading = false,
    this.performances = const [],
    this.error,
  });

  PerformanceSearchState copyWith({
    bool? isLoading,
    List<Performance>? performances,
    String? error,
    bool clearError = false,
  }) {
    return PerformanceSearchState(
      isLoading: isLoading ?? this.isLoading,
      performances: performances ?? this.performances,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PerformanceSearchViewModel extends StateNotifier<PerformanceSearchState> {
  final SearchPerformancesUseCase _searchPerformancesUseCase;

  PerformanceSearchViewModel(this._searchPerformancesUseCase)
    : super(const PerformanceSearchState());

  Future<void> searchPerformances(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(performances: [], clearError: true);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final Either<Failure, List<Performance>> result =
          await _searchPerformancesUseCase(query: query);

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
            performances: [],
          );
        },
        (performances) {
          state = state.copyWith(
            isLoading: false,
            performances: performances,
            clearError: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '공연 검색 중 오류가 발생했습니다: $e',
        performances: [],
      );
    }
  }

  void clearSearch() {
    state = const PerformanceSearchState();
  }
}
