import 'package:flutter/material.dart';
import 'package:weave/core/services/biometric_service.dart';
import 'package:weave/presentation/screens/home/home_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final BiometricService _biometricService = BiometricService();
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
        biometricOnly: false, // PIN/패턴도 허용
      );

      if (mounted) {
        if (result.success) {
          // 인증 성공 플래그 설정
          _isAuthenticated = true;
          // 인증 성공 시 홈 화면으로 이동
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // 인증 실패 시 다시 시도 가능하도록 상태 업데이트
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
