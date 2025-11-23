// Flutter의 material 디자인 위젯 사용
import 'package:flutter/material.dart';

// 상태를 가지므로 'StatefulWidget'을 상속 받음
class EmailPasswordForm extends StatefulWidget {
  // 로그인 버튼 클릭 시 실행될 함수 (이메일, 비밀번호를 파라미터로 받음)
  final Function(String email, String password) onSignIn;
  // 회원가입 버튼 클릭 시 실행될 함수
  final Function(String email, String password) onSignUp;
  // 로딩 상태
  final bool isLoading;
  // 초기 모드 (로그인/회원가입)
  final bool initialSignUpMode;
  // 모드 전환 콜백
  final Function(bool isSignUp)? onModeToggle;

  // 생성자
  const EmailPasswordForm({
    super.key,
    required this.onSignIn,
    required this.onSignUp,
    this.isLoading = false,
    this.initialSignUpMode = false,
    this.onModeToggle,
  });

  @override
  State<EmailPasswordForm> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<EmailPasswordForm> {
  // 폼의 상태를 관리하기 위한 GlobalKey
  final _formKey = GlobalKey<FormState>();
  // 이메일 입력을 관리하는 TextEditingController
  final _emailController = TextEditingController();
  // 비밀번호 입력을 관리하는 TextEditingController
  final _passwordController = TextEditingController();
  // 포커스 노드
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  // 비밀번호 표시 여부를 관리하는 변수
  bool _obscurePassword = true;
  // 로그인/회원가입 모드를 관리하는 변수
  late bool _isSignUpMode;

  @override
  void initState() {
    super.initState();
    _isSignUpMode = widget.initialSignUpMode;
  }

  @override
  void didUpdateWidget(EmailPasswordForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSignUpMode != widget.initialSignUpMode) {
      setState(() {
        _isSignUpMode = widget.initialSignUpMode;
      });
    }
  }

  @override
  void dispose() {
    // 위젯이 제거될 때 컨트롤러를 정리하여 메모리 누수 방지
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // 비밀번호 강도 검증 함수
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }

    // 회원가입 모드일 때만 강력한 비밀번호 검증
    if (_isSignUpMode) {
      if (value.length < 8) {
        return '비밀번호는 최소 8자 이상이어야 합니다';
      }
      if (!value.contains(RegExp(r'[A-Za-z]'))) {
        return '영문자를 최소 1개 이상 포함해야 합니다';
      }
      if (!value.contains(RegExp(r'[0-9]'))) {
        return '숫자를 최소 1개 이상 포함해야 합니다';
      }
      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        return '특수문자를 최소 1개 이상 포함해야 합니다';
      }
    } else {
      // 로그인 모드일 때는 최소 길이만 체크
      if (value.length < 6) {
        return '비밀번호를 입력해주세요';
      }
    }

    return null;
  }

  void _submit() {
    // 폼의 유효성 검사를 수행
    if (_formKey.currentState!.validate()) {
      if (_isSignUpMode) {
        // 회원가입 모드일 때
        widget.onSignUp(_emailController.text.trim(), _passwordController.text);
      } else {
        // 로그인 모드일 때
        widget.onSignIn(_emailController.text.trim(), _passwordController.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 이메일 입력 필드
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              // 이메일 입력 완료 시 비밀번호 필드로 포커스 이동
              _passwordFocusNode.requestFocus();
            },
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: '이메일',
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일을 입력해주세요';
              }
              if (!value.contains('@')) {
                return '올바른 이메일 형식이 아닙니다';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          // 비밀번호 입력 필드
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              // 비밀번호 입력 완료 시 자동으로 로그인/회원가입 실행
              _submit();
            },
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: '비밀번호',
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Colors.red),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 20),
          // 로그인/회원가입 버튼
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSignUpMode
                    ? Colors.green.shade600
                    : (widget.isLoading
                          ? Colors.green.shade300
                          : Colors.green.shade600),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                disabledBackgroundColor: Colors.green.shade300,
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _isSignUpMode ? '가입하기' : '로그인',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          // 로그인/회원가입 모드 전환 (하단에 표시하지 않고, login_screen에서 처리)
        ],
      ),
    );
  }
}
