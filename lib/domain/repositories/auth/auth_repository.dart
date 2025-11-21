// 'Either' 타입을 가져옴. 'Either'는 'Left' (보통 실패) 또는 'Right' (보통 성공) 둘 중 하나의 값을 가지는 타입
import 'package:dartz/dartz.dart';
// '실패'라는 데이터를 반환하기 위해 사용
import 'package:weave/core/failure.dart';
// 데이터베이스 모델(DTO)이 아닌
// 앱의 핵심 비즈니스 로직(도메인)에서 사용하는 순수한 데이터 모델
import 'package:weave/domain/entities/user/user.dart';

// 인증(Auth) 기능에서 '반드시 이런 기능들을 제공해야 한다'라는 '규칙' 또는 '계약'을 선언
abstract class AuthRepository {
  // 'Future'은 이 작업이 비동기로 처리됨을 의미. 작업이 완료될 때까지 기다림
  // 'Either'은 'Future'가 완료되었을 때 반환하는 값의 타입
  // Left: 작업이 실패했음을 의미하며, 'Failure' 객체를 담음
  // Right: 작업이 성공했음을 의미하며, User 엔티티 객체를 담음
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();
}
