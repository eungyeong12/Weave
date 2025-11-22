import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/record/record.dart';
import 'package:weave/domain/usecases/record/save_record.dart';

class RecordWriteState {
  final bool isLoading;
  final String? error;

  const RecordWriteState({this.isLoading = false, this.error});

  RecordWriteState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return RecordWriteState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class RecordWriteViewModel extends StateNotifier<RecordWriteState> {
  final SaveRecordUseCase _saveRecordUseCase;
  final UpdateRecordUseCase _updateRecordUseCase;

  RecordWriteViewModel(this._saveRecordUseCase, this._updateRecordUseCase)
    : super(const RecordWriteState());

  Future<void> saveRecord({
    required String userId,
    required String type,
    required DateTime date,
    required String title,
    String? imageUrl,
    required String content,
    required double rating,
    Map<String, dynamic>? metadata,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final Either<Failure, Record> result = await _saveRecordUseCase(
        userId: userId,
        type: type,
        date: date,
        title: title,
        imageUrl: imageUrl,
        content: content,
        rating: rating,
        metadata: metadata,
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
        error: '기록 저장 중 예상치 못한 오류가 발생했습니다.',
      );
    }
  }

  Future<void> updateRecord({
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
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final Either<Failure, Record> result = await _updateRecordUseCase(
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
        error: '기록 업데이트 중 예상치 못한 오류가 발생했습니다.',
      );
    }
  }
}
