import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weave/data/datasources/auth/firebase_auth_datasource.dart';
import 'package:weave/data/repositories/auth/auth_repository_impl.dart';
import 'package:weave/domain/repositories/auth/auth_repository.dart';
import 'package:weave/domain/usecases/auth/sign_in_with_email_and_password.dart';
import 'package:weave/domain/usecases/auth/sign_up_with_email_and_password.dart';
import 'package:weave/domain/usecases/auth/sign_out.dart';
import 'package:weave/presentation/viewmodels/auth/auth_viewmodel.dart';

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
