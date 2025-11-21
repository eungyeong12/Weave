import 'package:weave/domain/entities/user/user.dart';

// 이 DTO가 도메인 계층의 'User' 엔티티를 상속(확장)함
// UserDto는 User의 한 종류임을 의미
// Data 계층에서 반환된 'UserDto' 객체를 Domain 계층에서 'User' 타입으로
// 아무런 변환 없이 그대로 사용할 수 있음
class UserDto extends User {
  const UserDto({required super.uid, super.name, super.email, super.photoUrl});

  // 'factory' 키워드는 이 메서드가 'UserDto'의 인스턴스를 '생성해서 반환'하는
  // 생성자 역할을 함을 의미
  //'dynamic'은 Firebase SDK가 반환하는 User 타입
  // 'Data' 계층이 직접적으로 의존하지 않음
  factory UserDto.fromFirebaseUser(dynamic user) {
    return UserDto(
      uid: user.uid,
      name: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
    );
  }
}
