import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weave/presentation/widgets/auth/email_password_form.dart';
import 'package:weave/presentation/viewmodels/auth/auth_viewmodel.dart';
import 'package:weave/di/injector.dart';
import 'package:weave/presentation/screens/home/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isSignUpMode = false;

  @override
  Widget build(BuildContext context) {
    final authViewModel = ref.watch(authViewModelProvider);
    final authViewModelNotifier = ref.read(authViewModelProvider.notifier);

    // 상태 변화 감지: 성공 시 홈으로 이동, 실패 시 에러 표시
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      // 1. 성공 처리: 사용자가 있고 이전에는 없었을 때
      if (next.user != null && (previous == null || previous.user == null)) {
        // 빌드가 완료된 후에 네비게이션 실행
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          }
        });
        return;
      }

      // 2. 에러 처리: 로딩이 끝나고 에러가 있고 사용자가 없을 때
      // 이전에 로딩 중이었고, 지금은 로딩이 끝났으며, 에러가 있는 경우
      if (previous != null &&
          previous.isLoading &&
          !next.isLoading &&
          next.error != null &&
          next.user == null) {
        // 빌드가 완료된 후에 SnackBar 표시
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          // 기존 SnackBar가 있으면 제거
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          // 새로운 에러 SnackBar 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      next.error!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: '닫기',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                // 로고 영역
                const Text(
                  'Weave',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -1.0,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),
                // 이메일/비밀번호 로그인 폼
                _EmailPasswordFormWithMode(
                  isSignUpMode: _isSignUpMode,
                  onModeChanged: (isSignUp) {
                    setState(() {
                      _isSignUpMode = isSignUp;
                    });
                  },
                  onSignIn: (email, password) {
                    authViewModelNotifier.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                  },
                  onSignUp: (email, password) {
                    authViewModelNotifier.signUpWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                  },
                  isLoading: authViewModel.isLoading,
                ),
                const SizedBox(height: 20),
                // 구분선
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade300,
                        thickness: 0.5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        '또는',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade300,
                        thickness: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 하단 회원가입 링크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignUpMode ? '계정이 있으신가요? ' : '계정이 없으신가요? ',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSignUpMode = !_isSignUpMode;
                        });
                      },
                      child: Text(
                        _isSignUpMode ? '로그인' : '가입하기',
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 모드를 외부에서 제어할 수 있는 래퍼 위젯
class _EmailPasswordFormWithMode extends StatefulWidget {
  final bool isSignUpMode;
  final Function(bool) onModeChanged;
  final Function(String, String) onSignIn;
  final Function(String, String) onSignUp;
  final bool isLoading;

  const _EmailPasswordFormWithMode({
    required this.isSignUpMode,
    required this.onModeChanged,
    required this.onSignIn,
    required this.onSignUp,
    required this.isLoading,
  });

  @override
  State<_EmailPasswordFormWithMode> createState() =>
      _EmailPasswordFormWithModeState();
}

class _EmailPasswordFormWithModeState
    extends State<_EmailPasswordFormWithMode> {
  late bool _isSignUpMode;

  @override
  void initState() {
    super.initState();
    _isSignUpMode = widget.isSignUpMode;
  }

  @override
  void didUpdateWidget(_EmailPasswordFormWithMode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSignUpMode != widget.isSignUpMode) {
      setState(() {
        _isSignUpMode = widget.isSignUpMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return EmailPasswordForm(
      onSignIn: widget.onSignIn,
      onSignUp: widget.onSignUp,
      isLoading: widget.isLoading,
      initialSignUpMode: _isSignUpMode,
      onModeToggle: (isSignUp) {
        setState(() {
          _isSignUpMode = isSignUp;
        });
        widget.onModeChanged(isSignUp);
      },
    );
  }
}
