import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weave/domain/entities/record/record.dart';
import 'package:weave/domain/entities/diary/diary.dart';
import 'package:weave/domain/usecases/record/get_records.dart';
import 'package:weave/domain/usecases/diary/get_diaries.dart';

class HomeState {
  final bool isLoading;
  final List<Record> records;
  final List<Diary> diaries;
  final String? error;

  const HomeState({
    this.isLoading = false,
    this.records = const [],
    this.diaries = const [],
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    List<Record>? records,
    List<Diary>? diaries,
    String? error,
    bool clearError = false,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      records: records ?? this.records,
      diaries: diaries ?? this.diaries,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  final GetRecordsUseCase _getRecordsUseCase;
  final GetDiariesUseCase _getDiariesUseCase;

  HomeViewModel(this._getRecordsUseCase, this._getDiariesUseCase)
    : super(const HomeState());

  Future<void> loadData(String userId, {int? year, int? month}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // records와 diaries를 동시에 조회
      final recordsResult = await _getRecordsUseCase(
        userId: userId,
        year: year,
        month: month,
      );
      final diariesResult = await _getDiariesUseCase(
        userId: userId,
        year: year,
        month: month,
      );

      recordsResult.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
            records: [],
          );
        },
        (records) {
          diariesResult.fold(
            (failure) {
              state = state.copyWith(
                isLoading: false,
                error: failure.message,
                records: records,
                diaries: [],
              );
            },
            (diaries) {
              state = state.copyWith(
                isLoading: false,
                records: records,
                diaries: diaries,
                clearError: true,
              );
            },
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '데이터 조회 중 오류가 발생했습니다: $e',
        records: [],
        diaries: [],
      );
    }
  }
}
