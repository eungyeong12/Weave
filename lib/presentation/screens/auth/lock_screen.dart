import 'package:flutter/material.dart';
import 'package:weave/core/services/biometric_service.dart';
import 'package:weave/core/services/pin_service.dart';
import 'package:weave/presentation/screens/home/home_screen.dart';
import 'package:weave/presentation/screens/auth/pin_lock_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final BiometricService _biometricService = BiometricService();
  final PinService _pinService = PinService();
  bool _isAuthenticating = false;
  bool _isAuthenticated = false; // 인증 성공 여부 추적

  @override
  void initState() {
    super.initState();
    // 화면이 로드되면 자동으로 생체 인증 시도
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    // 이미 인증되었거나 인증 중이면 중복 실행 방지
    if (_isAuthenticating || _isAuthenticated) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final isEnabled = await _biometricService.isBiometricEnabled();
      if (!isEnabled) {
        // 생체 인증이 비활성화되어 있으면 바로 홈으로 이동
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
        return;
      }

      final result = await _biometricService.authenticate(
        reason: '앱을 잠금 해제하려면 생체 인증이 필요합니다',
        biometricOnly: true, // 생체 인증만 허용 (PIN/패턴 대체 불가)
      );

      if (mounted) {
        if (result.success) {
          // 인증 성공 플래그 설정
          _isAuthenticated = true;

          // 생체 인증 성공 시 비밀번호는 생략하고 바로 홈 화면으로 이동
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // 인증 실패 시 처리
          final isPinEnabled = await _pinService.isPinEnabled();

          // 인증 횟수 초과로 생체 인증이 잠긴 경우 또는 비밀번호가 활성화되어 있는 경우
          final isLockedOut =
              result.errorMessage != null &&
              (result.errorMessage!.contains('잠겨') ||
                  result.errorMessage!.contains('영구적으로') ||
                  result.errorMessage!.contains('lockedout') ||
                  result.errorMessage!.contains('permanently'));

          if (isPinEnabled || isLockedOut) {
            // 비밀번호가 활성화되어 있거나 생체 인증이 잠긴 경우 비밀번호 화면으로 이동
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const PinLockScreen()),
            );
          } else {
            // 비밀번호가 없고 생체 인증이 잠기지 않은 경우 다시 시도 가능하도록 상태 업데이트
            setState(() {
              _isAuthenticating = false;
            });
            // 에러 메시지가 있으면 표시
            if (result.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result.errorMessage!),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('생체 인증 중 오류가 발생했습니다: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fingerprint, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 24),
              const Text(
                '앱 잠금',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '생체 인증을 통해 앱을 잠금 해제하세요',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              if (!_isAuthenticating)
                ElevatedButton(
                  onPressed: _authenticate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('다시 시도'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
