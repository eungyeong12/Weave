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
import 'package:weave/domain/usecases/diary/save_daily_diary.dart';
import 'package:weave/presentation/viewmodels/auth/auth_viewmodel.dart';
import 'package:weave/presentation/viewmodels/diary/daily_diary_write_viewmodel.dart';

final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);

final firebaseAuthDataSourceProvider = Provider(
  (ref) => FirebaseAuthDataSource(ref.read(firebaseAuthProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.read(firebaseAuthDataSourceProvider)),
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

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(
    ref.read(signInWithEmailAndPasswordUseCaseProvider),
    ref.read(signUpWithEmailAndPasswordUseCaseProvider),
    ref.read(signOutUseCaseProvider),
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

final dailyDiaryWriteViewModelProvider =
    StateNotifierProvider<DailyDiaryWriteViewModel, DailyDiaryWriteState>(
      (ref) =>
          DailyDiaryWriteViewModel(ref.read(saveDailyDiaryUseCaseProvider)),
    );
