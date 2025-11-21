import 'package:firebase_auth/firebase_auth.dart';

/// Firebase 인증 에러를 한글로 변환하는 유틸리티 클래스
class AuthErrorTranslator {
  /// FirebaseAuthException의 에러 코드를 한글 메시지로 변환
  static String translateFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      // 로그인 관련 에러
      case 'user-not-found':
        return '등록되지 않은 이메일입니다.';
      case 'wrong-password':
        return '비밀번호가 올바르지 않습니다.';
      case 'invalid-email':
        return '이메일 형식이 올바르지 않습니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      case 'too-many-requests':
        return '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.';
      case 'operation-not-allowed':
        return '이 작업은 허용되지 않습니다.';
      case 'network-request-failed':
        return '네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.';

      // 회원가입 관련 에러
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다. 더 강한 비밀번호를 사용해주세요.';
      case 'invalid-credential':
        return '인증 정보가 올바르지 않습니다.';

      // 기타 에러
      case 'requires-recent-login':
        return '보안을 위해 다시 로그인해주세요.';
      case 'credential-already-in-use':
        return '이 인증 정보는 이미 다른 계정에서 사용 중입니다.';
      case 'invalid-verification-code':
        return '인증 코드가 올바르지 않습니다.';
      case 'invalid-verification-id':
        return '인증 ID가 올바르지 않습니다.';
      case 'session-expired':
        return '세션이 만료되었습니다. 다시 시도해주세요.';

      default:
        // 알 수 없는 에러 코드인 경우 영어 메시지를 반환하거나 기본 메시지 반환
        return e.message ?? '알 수 없는 오류가 발생했습니다.';
    }
  }

  /// 일반 Exception을 한글 메시지로 변환
  static String translateException(Exception e) {
    final message = e.toString();

    // Firebase 관련 에러 메시지 패턴 확인
    if (message.contains('FirebaseAuthException')) {
      // 이미 처리된 경우
      return message;
    }

    // 일반적인 에러 메시지 패턴 확인
    if (message.contains('network') || message.contains('Network')) {
      return '네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.';
    }

    if (message.contains('timeout') || message.contains('Timeout')) {
      return '요청 시간이 초과되었습니다. 다시 시도해주세요.';
    }

    // 기본 메시지
    return '오류가 발생했습니다. 다시 시도해주세요.';
  }
}
