import 'package:dartz/dartz.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/user/user.dart';
// 'AuthRepository' 인터페이스를 가져옴
// 이 UseCase는 'Data 계층의 구현체를 직접 참조하지 않고,
// 'Domain' 계층의 '추상화된 인터페이스'에만 의존
import 'package:weave/domain/repositories/auth/auth_repository.dart';

class SignInWithEmailAndPasswordUseCase {
  // 외부(Data 계층)로부터 데이터를 가져오기 위한 창구
  final AuthRepository repository;

  // 이 UseCase를 생성할 때, 반드시 'AuthRepository' 타입의 객체를 주입받아야 함
  // 보통 'Dependency Injection' 라이브러리를 통해 Data 계층의 'AuthRepositoryImpl'이 주입됨
  SignInWithEmailAndPasswordUseCase(this.repository);

  // 'call' 메서드
  // 클래스 인스턴스를 함수처럼 호출(`signInWithEmailAndPasswordUseCase()`)할 수 있게 해주는
  // 특별한 이름의 메서드
  // 'AuthRepository'와 동일한 반환 타입을 가짐
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    // 주입받은 'repository'의 'signInWithEmailAndPassword' 메서드를 호출
    // await을 사용해 비동기 작업이 완료될 때까지 기다림
    // 그 결과를 호출부(ViewModel)에 반환
    return await repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
