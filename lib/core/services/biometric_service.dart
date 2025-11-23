import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static const String _biometricEnabledKey = 'biometric_enabled';

  final LocalAuthentication _localAuth = LocalAuthentication();

  // 앱 실행 중 인증 상태 (메모리에만 저장, 앱 종료 시 초기화됨)
  bool _isAuthenticatedInSession = false;

  // 생체 인증 가능 여부 확인
  Future<bool> isBiometricAvailable() async {
    try {
      // 웹에서는 local_auth가 제대로 작동하지 않으므로 false 반환
      if (kIsWeb) {
        return false;
      }

      // 모바일에서는 기존 로직 사용
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || isDeviceSupported;

      return canAuthenticate;
    } on MissingPluginException catch (e) {
      print('생체 인증 가능 여부 확인 중 MissingPluginException: $e');
      // 웹에서는 항상 false 반환
      return false;
    } on PlatformException catch (e) {
      print('생체 인증 가능 여부 확인 중 에러: $e');
      // 웹에서는 항상 false 반환
      return false;
    } catch (e) {
      print('생체 인증 가능 여부 확인 중 예상치 못한 에러: $e');
      // 웹에서는 항상 false 반환
      return false;
    }
  }

  // 사용 가능한 생체 인증 유형 확인
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // 생체 인증 실행
  // 반환값: (성공 여부, 에러 메시지)
  Future<({bool success, String? errorMessage})> authenticate({
    String reason = '생체 인증을 통해 앱을 잠금 해제하세요',
    bool biometricOnly = false, // true면 패턴/비밀번호 대체 인증 불가능
  }) async {
    bool authenticated = false;
    try {
      // 인증 실행 (isDeviceSupported() 체크는 생략 - authenticate() 자체가 지원 여부를 체크함)
      try {
        authenticated = await _localAuth.authenticate(
          localizedReason: reason,
          options: AuthenticationOptions(
            stickyAuth: false, // stickyAuth를 false로 설정하여 중복 다이얼로그 방지
            biometricOnly: biometricOnly, // true면 패턴/비밀번호 대체 인증 불가능
            useErrorDialogs: false, // 플랫폼 기본 에러 다이얼로그 비활성화 (중복 방지)
          ),
        );
      } on MissingPluginException catch (e) {
        print('웹에서 authenticate MissingPluginException: $e');
        // 웹에서 MissingPluginException 발생 시 WebAuthn이 지원되지 않음을 의미
        return (
          success: false,
          errorMessage:
              '웹에서 생체 인증을 사용할 수 없습니다. HTTPS 환경에서만 작동하며, 브라우저와 기기가 WebAuthn을 지원하는지 확인해주세요.',
        );
      }

      if (authenticated) {
        // 인증 성공 시 세션 플래그 설정 (앱 실행 중에만 유효)
        _isAuthenticatedInSession = true;
        return (success: true, errorMessage: null);
      } else {
        // 사용자가 취소하거나 인증 실패
        return (success: false, errorMessage: null); // null은 사용자 취소를 의미
      }
    } on PlatformException catch (e) {
      print('생체 인증 PlatformException: $e');
      String errorMessage = '생체 인증 중 오류가 발생했습니다.';

      // PlatformException의 code를 확인하여 구체적인 에러 메시지 제공
      final errorCode = e.code.toLowerCase();
      if (errorCode.contains('notavailable') ||
          errorCode.contains('not_available')) {
        errorMessage = '생체 인증을 사용할 수 없습니다.';
      } else if (errorCode.contains('notenrolled') ||
          errorCode.contains('not_enrolled')) {
        errorMessage = '생체 인증이 등록되어 있지 않습니다. 기기 설정에서 생체 인증을 등록해주세요.';
      } else if (errorCode.contains('lockedout') ||
          errorCode.contains('locked_out')) {
        errorMessage = '생체 인증이 잠겨 있습니다. 잠시 후 다시 시도해주세요.';
      } else if (errorCode.contains('passcode') &&
          errorCode.contains('not_set')) {
        errorMessage = '기기 잠금이 설정되어 있지 않습니다. 기기 설정에서 잠금을 설정해주세요.';
      } else if (errorCode.contains('permanently')) {
        errorMessage = '생체 인증이 영구적으로 잠겨 있습니다.';
      } else {
        errorMessage = '생체 인증 중 오류가 발생했습니다: ${e.message ?? e.code}';
      }

      return (success: false, errorMessage: errorMessage);
    } on MissingPluginException catch (e) {
      print('생체 인증 중 MissingPluginException: $e');
      // 웹에서 MissingPluginException 발생 시 적절한 메시지 반환
      if (kIsWeb) {
        return (
          success: false,
          errorMessage:
              '웹에서 생체 인증을 사용할 수 없습니다. HTTPS 환경에서만 작동하며, 브라우저와 기기가 WebAuthn을 지원하는지 확인해주세요.',
        );
      }
      return (success: false, errorMessage: '생체 인증 플러그인을 찾을 수 없습니다.');
    } catch (e) {
      print('생체 인증 중 예상치 못한 에러: $e');
      return (
        success: false,
        errorMessage: '생체 인증 중 예상치 못한 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  // 생체 인증 활성화 여부 저장
  Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_biometricEnabledKey, enabled);
    } catch (e) {
      return false;
    }
  }

  // 생체 인증 활성화 여부 로드
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  // 생체 인증 비활성화 (설정에서 끄기)
  Future<bool> disableBiometric() async {
    return await setBiometricEnabled(false);
  }

  // 현재 세션에서 인증되었는지 확인 (앱 실행 중에만 유효)
  bool isAuthenticatedInSession() {
    return _isAuthenticatedInSession;
  }

  // 세션 인증 상태 설정 (비밀번호 인증 성공 시 생체 인증도 자동 성공 처리)
  void setSessionAuth(bool authenticated) {
    _isAuthenticatedInSession = authenticated;
  }

  // 세션 인증 상태 초기화 (로그아웃 시 등)
  void clearSessionAuth() {
    _isAuthenticatedInSession = false;
  }
}
