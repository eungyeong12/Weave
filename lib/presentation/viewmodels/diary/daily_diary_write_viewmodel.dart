import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/diary/diary.dart';
import 'package:weave/domain/usecases/diary/save_daily_diary.dart';

class DailyDiaryWriteState {
  final bool isLoading;
  final String? error;

  const DailyDiaryWriteState({this.isLoading = false, this.error});

  DailyDiaryWriteState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return DailyDiaryWriteState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DailyDiaryWriteViewModel extends StateNotifier<DailyDiaryWriteState> {
  final SaveDailyDiaryUseCase _saveDailyDiaryUseCase;

  DailyDiaryWriteViewModel(this._saveDailyDiaryUseCase)
    : super(const DailyDiaryWriteState());

  Future<void> saveDailyDiary({
    required String userId,
    required DateTime date,
    required String content,
    required List<String> imageFilePaths,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final Either<Failure, Diary> result = await _saveDailyDiaryUseCase(
        userId: userId,
        date: date,
        content: content,
        imageFilePaths: imageFilePaths,
      );

      result.fold(
        (failure) {
          state = state.copyWith(isLoading: false, error: failure.message);
        },
        (_) {
          state = state.copyWith(isLoading: false, clearError: true);
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '일기 저장 중 예상치 못한 오류가 발생했습니다.',
      );
    }
  }
}
