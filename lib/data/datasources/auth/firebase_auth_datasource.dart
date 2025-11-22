import 'package:firebase_auth/firebase_auth.dart';

// Firebase와 직접 통신하는 데이터 소스 클래스
class FirebaseAuthDataSource {
  // 외부에서 생성되어 주입됨
  final FirebaseAuth _auth;

  FirebaseAuthDataSource(this._auth);

  // 현재 인증된 사용자 가져오기
  User? get currentUser => _auth.currentUser;

  // 이메일과 비밀번호로 로그인하는 메서드
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Firebase 인증이 성공했으면 user를 반환
    // FirebaseAuthException은 자동으로 throw되므로 별도 처리 불필요
    return userCredential.user;
  }

  // 이메일과 비밀번호로 회원가입하는 메서드
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Firebase 인증이 성공했으면 user를 반환
    // FirebaseAuthException은 자동으로 throw되므로 별도 처리 불필요
    return userCredential.user;
  }

  // 로그아웃 메서드
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 회원 탈퇴 메서드
  Future<void> deleteUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('삭제할 사용자를 찾을 수 없습니다.');
    }

    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      // 재인증이 필요한 경우
      if (e.code == 'requires-recent-login') {
        throw Exception('보안을 위해 최근에 로그인한 사용자만 계정을 삭제할 수 있습니다. 다시 로그인해주세요.');
      }
      rethrow;
    } catch (e) {
      // 다른 예외는 그대로 전달
      rethrow;
    }
  }
}
