import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/core/auth_error_translator.dart';
import 'package:weave/data/datasources/auth/firebase_auth_datasource.dart';
import 'package:weave/data/datasources/firestore/firebase_firestore_datasource.dart';
import 'package:weave/data/datasources/storage/firebase_storage_datasource.dart';
import 'package:weave/data/models/user/user_dto.dart';
import 'package:weave/domain/repositories/auth/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  // 데이터 소스를 멤버 변수로 선언
  // 이 클래스는 어떻게 Firebase와 통신하는지 모르며, 단지 Datasource에 위임
  final FirebaseAuthDataSource _dataSource;
  final FirebaseFirestoreDatasource _firestoreDatasource;
  final FirebaseStorageDataSource _storageDatasource;

  // 이 클래스가 생성될 때 외부에서 'FirebaseAuthDatasource' 인스턴스를 주입받음
  AuthRepositoryImpl(
    this._dataSource,
    this._firestoreDatasource,
    this._storageDatasource,
  );

  @override
  Future<Either<Failure, UserDto>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Datasource에서 발생할 수 있는 모든 예외를 잡아서 'Failure' 객체로 변환
    try {
      // 실제 이메일/비밀번호 로그인을 비동기로 요청
      final user = await _dataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // user가 null이면 실패
      if (user == null) {
        return Left(Failure('로그인에 실패했습니다.'));
      }

      // Firebase의 'user' 객체를 Domain의 'UserDto' 객체로 변환
      // 'UserDto'는 'User'를 상속하므로 'Right<User>' 타입으로 변환될 수 있음
      final userDto = UserDto.fromFirebaseUser(user);
      return Right(userDto);
    } on FirebaseAuthException catch (e) {
      // Firebase 인증 예외만 처리 (실제 인증 실패)
      final koreanMessage = AuthErrorTranslator.translateFirebaseAuthException(
        e,
      );
      return Left(Failure(koreanMessage));
    } catch (e) {
      // 예상치 못한 예외 발생
      // Firebase 인증이 성공했을 수도 있으므로, 현재 인증된 사용자 확인
      try {
        final currentUser = _dataSource.currentUser;
        if (currentUser != null) {
          // 현재 사용자가 있으면 성공으로 처리
          final userDto = UserDto.fromFirebaseUser(currentUser);
          return Right(userDto);
        }
      } catch (_) {
        // 현재 사용자 확인 실패
      }
      // 사용자가 없으면 실패로 처리
      return Left(Failure('로그인 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, UserDto>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      // user가 null이면 실패
      if (user == null) {
        return Left(Failure('회원가입에 실패했습니다.'));
      }

      // UserDto 변환 (예외가 발생하지 않아야 함)
      final userDto = UserDto.fromFirebaseUser(user);
      return Right(userDto);
    } on FirebaseAuthException catch (e) {
      // Firebase 인증 예외만 처리 (실제 인증 실패)
      final koreanMessage = AuthErrorTranslator.translateFirebaseAuthException(
        e,
      );
      return Left(Failure(koreanMessage));
    } catch (e) {
      // 예상치 못한 예외 발생
      // Firebase 인증이 성공했을 수도 있으므로, 현재 인증된 사용자 확인
      try {
        final currentUser = _dataSource.currentUser;
        if (currentUser != null) {
          // 현재 사용자가 있으면 성공으로 처리
          final userDto = UserDto.fromFirebaseUser(currentUser);
          return Right(userDto);
        }
      } catch (_) {
        // 현재 사용자 확인 실패
      }
      // 사용자가 없으면 실패로 처리
      return Left(Failure('회원가입 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(Failure('로그아웃 중 오류가 발생했습니다.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser({required String userId}) async {
    try {
      // 1. Storage에서 사용자 이미지 삭제 (실패해도 계속 진행)
      try {
        await _storageDatasource.deleteUserImages(userId: userId);
      } catch (e) {
        // Storage 삭제 실패는 무시 (이미 삭제되었을 수 있음)
        print('Storage 삭제 실패 (무시됨): $e');
      }

      // 2. Firestore에서 사용자 데이터 삭제 (실패해도 계속 진행)
      try {
        await _firestoreDatasource.deleteUserData(userId: userId);
      } catch (e) {
        // Firestore 삭제 실패는 무시 (이미 삭제되었을 수 있음)
        print('Firestore 삭제 실패 (무시됨): $e');
      }

      // 3. Firebase Auth에서 사용자 계정 삭제 (가장 중요)
      await _dataSource.deleteUser();

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      // Firebase 인증 예외 처리
      String errorMessage = '회원 탈퇴 중 오류가 발생했습니다.';
      if (e.code == 'requires-recent-login') {
        errorMessage = '보안을 위해 최근에 로그인한 사용자만 계정을 삭제할 수 있습니다. 다시 로그인해주세요.';
      } else {
        errorMessage = '회원 탈퇴 중 오류가 발생했습니다: ${e.message ?? e.code}';
      }
      return Left(Failure(errorMessage));
    } catch (e) {
      // App Check 관련 오류는 무시
      final errorString = e.toString();
      if (errorString.contains('App Check') ||
          errorString.contains('AppCheckProvider')) {
        // App Check 오류는 경고일 뿐이므로 성공으로 처리
        return const Right(null);
      }
      return Left(Failure('회원 탈퇴 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }
}
