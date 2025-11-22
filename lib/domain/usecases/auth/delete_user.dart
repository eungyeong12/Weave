import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/repositories/auth/auth_repository.dart';

class DeleteUserUseCase {
  final AuthRepository _repository;

  DeleteUserUseCase(this._repository);

  Future<Either<Failure, void>> call({required String userId}) async {
    return await _repository.deleteUser(userId: userId);
  }
}
