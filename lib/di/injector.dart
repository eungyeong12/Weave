import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:weave/data/datasources/auth/firebase_auth_datasource.dart';
import 'package:weave/data/datasources/firestore/firebase_firestore_datasource.dart';
import 'package:weave/data/datasources/storage/firebase_storage_datasource.dart';
import 'package:weave/data/repositories/auth/auth_repository_impl.dart';
import 'package:weave/data/repositories/diary/diary_repository_impl.dart';
import 'package:weave/domain/repositories/auth/auth_repository.dart';
import 'package:weave/domain/repositories/diary/diary_repository.dart';
import 'package:weave/domain/usecases/auth/sign_in_with_email_and_password.dart';
import 'package:weave/domain/usecases/auth/sign_up_with_email_and_password.dart';
import 'package:weave/domain/usecases/auth/sign_out.dart';
import 'package:weave/domain/usecases/auth/delete_user.dart';
import 'package:weave/domain/usecases/diary/save_daily_diary.dart';
import 'package:weave/data/datasources/book/naver_book_datasource.dart';
import 'package:weave/data/repositories/book/book_repository_impl.dart';
import 'package:weave/domain/repositories/book/book_repository.dart';
import 'package:weave/domain/usecases/book/search_books.dart';
import 'package:weave/presentation/viewmodels/auth/auth_viewmodel.dart';
import 'package:weave/presentation/viewmodels/diary/daily_diary_write_viewmodel.dart';
import 'package:weave/presentation/viewmodels/book/book_search_viewmodel.dart';
import 'package:weave/data/datasources/movie/tmdb_movie_datasource.dart';
import 'package:weave/data/repositories/movie/movie_repository_impl.dart';
import 'package:weave/domain/repositories/movie/movie_repository.dart';
import 'package:weave/domain/usecases/movie/search_movies.dart';
import 'package:weave/presentation/viewmodels/movie/movie_search_viewmodel.dart';
import 'package:weave/data/datasources/performance/kopis_datasource.dart';
import 'package:weave/data/repositories/performance/performance_repository_impl.dart';
import 'package:weave/domain/repositories/performance/performance_repository.dart';
import 'package:weave/domain/usecases/performance/search_performances.dart';
import 'package:weave/presentation/viewmodels/performance/performance_search_viewmodel.dart';
import 'package:weave/data/repositories/record/record_repository_impl.dart';
import 'package:weave/domain/repositories/record/record_repository.dart';
import 'package:weave/domain/usecases/record/save_record.dart';
import 'package:weave/domain/usecases/record/get_records.dart';
import 'package:weave/domain/usecases/diary/get_diaries.dart';
import 'package:weave/presentation/viewmodels/record/record_write_viewmodel.dart';
import 'package:weave/presentation/viewmodels/home/home_viewmodel.dart';

final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);

final firebaseAuthDataSourceProvider = Provider(
  (ref) => FirebaseAuthDataSource(ref.read(firebaseAuthProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.read(firebaseAuthDataSourceProvider),
    ref.read(firebaseFirestoreDatasourceProvider),
    ref.read(firebaseStorageDatasourceProvider),
  ),
);

final signInWithEmailAndPasswordUseCaseProvider = Provider(
  (ref) => SignInWithEmailAndPasswordUseCase(ref.read(authRepositoryProvider)),
);

final signUpWithEmailAndPasswordUseCaseProvider = Provider(
  (ref) => SignUpWithEmailAndPasswordUseCase(ref.read(authRepositoryProvider)),
);

final signOutUseCaseProvider = Provider(
  (ref) => SignOutUseCase(ref.read(authRepositoryProvider)),
);

final deleteUserUseCaseProvider = Provider(
  (ref) => DeleteUserUseCase(ref.read(authRepositoryProvider)),
);

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(
    ref.read(signInWithEmailAndPasswordUseCaseProvider),
    ref.read(signUpWithEmailAndPasswordUseCaseProvider),
    ref.read(signOutUseCaseProvider),
    ref.read(deleteUserUseCaseProvider),
  ),
);

// Diary 관련 providers
final firebaseFirestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final firebaseStorageProvider = Provider((ref) => FirebaseStorage.instance);

final firebaseFirestoreDatasourceProvider = Provider(
  (ref) => FirebaseFirestoreDatasource(ref.read(firebaseFirestoreProvider)),
);

final firebaseStorageDatasourceProvider = Provider(
  (ref) => FirebaseStorageDataSource(ref.read(firebaseStorageProvider)),
);

final diaryRepositoryProvider = Provider<DiaryRepository>(
  (ref) => DiaryRepositoryImpl(
    ref.read(firebaseFirestoreDatasourceProvider),
    ref.read(firebaseStorageDatasourceProvider),
  ),
);

final saveDailyDiaryUseCaseProvider = Provider(
  (ref) => SaveDailyDiaryUseCase(ref.read(diaryRepositoryProvider)),
);

final updateDailyDiaryUseCaseProvider = Provider(
  (ref) => UpdateDailyDiaryUseCase(ref.read(diaryRepositoryProvider)),
);

final deleteDailyDiaryUseCaseProvider = Provider(
  (ref) => DeleteDailyDiaryUseCase(ref.read(diaryRepositoryProvider)),
);

final dailyDiaryWriteViewModelProvider =
    StateNotifierProvider<DailyDiaryWriteViewModel, DailyDiaryWriteState>(
      (ref) => DailyDiaryWriteViewModel(
        ref.read(saveDailyDiaryUseCaseProvider),
        ref.read(updateDailyDiaryUseCaseProvider),
        ref.read(deleteDailyDiaryUseCaseProvider),
      ),
    );

// Book 관련 providers
final naverBookDataSourceProvider = Provider((ref) => NaverBookDataSource());

final bookRepositoryProvider = Provider<BookRepository>(
  (ref) => BookRepositoryImpl(ref.read(naverBookDataSourceProvider)),
);

final searchBooksUseCaseProvider = Provider(
  (ref) => SearchBooksUseCase(ref.read(bookRepositoryProvider)),
);

final bookSearchViewModelProvider =
    StateNotifierProvider<BookSearchViewModel, BookSearchState>(
      (ref) => BookSearchViewModel(ref.read(searchBooksUseCaseProvider)),
    );

// Movie 관련 providers
final tmdbMovieDataSourceProvider = Provider((ref) => TmdbMovieDataSource());

final movieRepositoryProvider = Provider<MovieRepository>(
  (ref) => MovieRepositoryImpl(ref.read(tmdbMovieDataSourceProvider)),
);

final searchMoviesUseCaseProvider = Provider(
  (ref) => SearchMoviesUseCase(ref.read(movieRepositoryProvider)),
);

final movieSearchViewModelProvider =
    StateNotifierProvider<MovieSearchViewModel, MovieSearchState>(
      (ref) => MovieSearchViewModel(ref.read(searchMoviesUseCaseProvider)),
    );

// Performance 관련 providers
final kopisDataSourceProvider = Provider((ref) => KopisDataSource());

final performanceRepositoryProvider = Provider<PerformanceRepository>(
  (ref) => PerformanceRepositoryImpl(ref.read(kopisDataSourceProvider)),
);

final searchPerformancesUseCaseProvider = Provider(
  (ref) => SearchPerformancesUseCase(ref.read(performanceRepositoryProvider)),
);

final performanceSearchViewModelProvider =
    StateNotifierProvider<PerformanceSearchViewModel, PerformanceSearchState>(
      (ref) => PerformanceSearchViewModel(
        ref.read(searchPerformancesUseCaseProvider),
      ),
    );

// Record 관련 providers
final recordRepositoryProvider = Provider<RecordRepository>(
  (ref) => RecordRepositoryImpl(ref.read(firebaseFirestoreDatasourceProvider)),
);

final saveRecordUseCaseProvider = Provider(
  (ref) => SaveRecordUseCase(ref.read(recordRepositoryProvider)),
);

final updateRecordUseCaseProvider = Provider(
  (ref) => UpdateRecordUseCase(ref.read(recordRepositoryProvider)),
);

final deleteRecordUseCaseProvider = Provider(
  (ref) => DeleteRecordUseCase(ref.read(recordRepositoryProvider)),
);

final recordWriteViewModelProvider =
    StateNotifierProvider<RecordWriteViewModel, RecordWriteState>(
      (ref) => RecordWriteViewModel(
        ref.read(saveRecordUseCaseProvider),
        ref.read(updateRecordUseCaseProvider),
        ref.read(deleteRecordUseCaseProvider),
      ),
    );

final getRecordsUseCaseProvider = Provider(
  (ref) => GetRecordsUseCase(ref.read(recordRepositoryProvider)),
);

final getDiariesUseCaseProvider = Provider(
  (ref) => GetDiariesUseCase(ref.read(diaryRepositoryProvider)),
);

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>(
  (ref) => HomeViewModel(
    ref.read(getRecordsUseCaseProvider),
    ref.read(getDiariesUseCaseProvider),
  ),
);
