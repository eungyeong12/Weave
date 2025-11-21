import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/user/user.dart';
import 'package:weave/domain/repositories/auth/auth_repository.dart';

class SignUpWithEmailAndPasswordUseCase {
  final AuthRepository repository;

  SignUpWithEmailAndPasswordUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    return await repository.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
