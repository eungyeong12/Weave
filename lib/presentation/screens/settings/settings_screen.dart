import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weave/di/injector.dart';
import 'package:weave/presentation/screens/auth/login_screen.dart';
import 'package:weave/presentation/screens/auth/pin_setup_screen.dart';
import 'package:weave/presentation/widgets/common/delete_confirmation_dialog.dart';
import 'package:weave/core/services/biometric_service.dart';
import 'package:weave/core/services/pin_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isPinLockEnabled = false;
  bool _isBiometricLockEnabled = false;
  bool _isDeleting = false;
  bool _isBiometricAvailable = false;
  bool _isAuthenticating = false; // 인증 중 플래그 추가
  final BiometricService _biometricService = BiometricService();
  final PinService _pinService = PinService();

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _loadBiometricSetting();
    _loadPinSetting();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (mounted) {
      setState(() {
        _isBiometricAvailable = isAvailable;
      });
    }
  }

  Future<void> _loadBiometricSetting() async {
    final isEnabled = await _biometricService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _isBiometricLockEnabled = isEnabled;
      });
    }
  }

  Future<void> _loadPinSetting() async {
    final isEnabled = await _pinService.isPinEnabled();
    if (mounted) {
      setState(() {
        _isPinLockEnabled = isEnabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left, color: Colors.black),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
          ),
        ),
        title: const Text(
          '설정',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // 잠금 설정 섹션
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                '잠금 설정',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            _buildSettingItem(
              icon: Icons.lock_outline,
              title: '비밀번호 잠금',
              trailing: Switch(
                value: _isPinLockEnabled,
                onChanged: (value) => _handlePinLockChange(value),
                activeColor: Colors.green,
              ),
              onTap: () => _togglePinLock(),
            ),
            // 웹에서는 생체 인증 옵션 숨김
            if (!kIsWeb)
              _buildSettingItem(
                icon: Icons.fingerprint,
                title: '생체 인증',
                trailing: Switch(
                  value: _isBiometricLockEnabled,
                  onChanged:
                      (_isPinLockEnabled &&
                          _isBiometricAvailable &&
                          !_isAuthenticating)
                      ? (value) => _handleBiometricChange(value)
                      : null,
                  activeColor: Colors.green,
                ),
                onTap:
                    (_isPinLockEnabled &&
                        _isBiometricAvailable &&
                        !_isAuthenticating)
                    ? () => _toggleBiometricLock()
                    : null,
              ),
            const SizedBox(height: 24),
            // 계정 섹션
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                '계정',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            if (user != null)
              _buildSettingItem(
                icon: Icons.email_outlined,
                title: '이메일',
                subtitle: user.email,
                trailing: null,
              ),
            _buildSettingItem(
              icon: Icons.logout,
              title: '로그아웃',
              trailing: null,
              onTap: (_isDeleting || isLoading)
                  ? null
                  : () => _showLogoutConfirmationDialog(context),
            ),
            _buildSettingItem(
              icon: Icons.person_remove,
              title: '회원 탈퇴',
              trailing: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: (_isDeleting || isLoading)
                  ? null
                  : () => _showDeleteAccountConfirmationDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? Colors.black87, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor ?? Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    DeleteConfirmationDialog.show(
      context,
      _logout,
      message: '로그아웃하시겠습니까?',
      confirmText: '로그아웃',
      confirmColor: Colors.green,
    );
  }

  void _showDeleteAccountConfirmationDialog(BuildContext context) {
    DeleteConfirmationDialog.show(
      context,
      _deleteAccount,
      message: '정말 회원 탈퇴하시겠습니까?\n모든 데이터가 삭제되며 복구할 수 없습니다.',
      confirmText: '탈퇴',
      confirmColor: Colors.red,
    );
  }

  Future<void> _logout() async {
    // 로그아웃 시 세션 인증 상태 초기화
    _biometricService.clearSessionAuth();
    _pinService.clearSessionAuth();

    final viewModel = ref.read(authViewModelProvider.notifier);
    await viewModel.signOut();

    final state = ref.read(authViewModelProvider);

    if (!mounted) return;

    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // 로그아웃 성공 시 로그인 화면으로 이동
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _deleteAccount() async {
    final authState = ref.read(authViewModelProvider);
    final user = authState.user;

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인이 필요합니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final viewModel = ref.read(authViewModelProvider.notifier);
      await viewModel.deleteUser(userId: user.uid);

      final state = ref.read(authViewModelProvider);

      if (!mounted) return;

      if (state.error != null) {
        // App Check 관련 오류는 무시하고 실제 오류만 표시
        String errorMessage = state.error!;
        if (errorMessage.contains('App Check') ||
            errorMessage.contains('AppCheckProvider')) {
          // App Check 오류는 경고일 뿐이므로 실제 탈퇴가 성공했는지 확인
          // 에러가 있지만 사용자가 삭제되었을 수도 있음
          if (ref.read(authViewModelProvider).user == null) {
            // 사용자가 삭제되었으면 성공으로 처리
            errorMessage = '';
          }
        }

        if (errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              duration: const Duration(seconds: 3),
            ),
          );
          setState(() {
            _isDeleting = false;
          });
          return;
        }
      }

      // 회원 탈퇴 성공 시 로그인 화면으로 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원 탈퇴가 완료되었습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원 탈퇴 중 오류가 발생했습니다: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handlePinLockChange(bool value) async {
    if (value) {
      // 비밀번호 활성화: 비밀번호 설정 화면으로 이동
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PinSetupScreen()),
      );
      if (result == true && mounted) {
        // 비밀번호 설정 성공
        setState(() {
          _isPinLockEnabled = true;
        });
      }
    } else {
      // 비밀번호 비활성화
      await _pinService.setPinEnabled(false);
      await _pinService.deletePinCode();

      // 비밀번호 잠금 해제 시 생체 인증도 자동으로 해제
      // 실제 Firestore에 저장된 생체 인증 상태를 확인하고 비활성화
      final isBiometricEnabled = await _biometricService.isBiometricEnabled();
      if (isBiometricEnabled) {
        await _biometricService.setBiometricEnabled(false);
      }

      if (mounted) {
        setState(() {
          _isPinLockEnabled = false;
          _isBiometricLockEnabled = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('비밀번호 잠금이 비활성화되었습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _togglePinLock() {
    _handlePinLockChange(!_isPinLockEnabled);
  }

  Future<void> _handleBiometricChange(bool value) async {
    // 이미 인증 중이면 무시
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      if (value) {
        // 생체 인증 활성화: 다이얼로그 없이 바로 활성화
        // 실제 인증은 앱 실행 시에만 수행됨
        await _biometricService.setBiometricEnabled(true);
        if (mounted) {
          setState(() {
            _isBiometricLockEnabled = true;
            _isAuthenticating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('생체 인증이 활성화되었습니다. 다음 앱 실행부터 생체 인증이 요구됩니다.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // 생체 인증 비활성화
        await _biometricService.setBiometricEnabled(false);
        if (mounted) {
          setState(() {
            _isBiometricLockEnabled = false;
            _isAuthenticating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('생체 인증이 비활성화되었습니다.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // 에러 발생 시 플래그 초기화
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
          _isBiometricLockEnabled = false;
        });
      }
    }
  }

  void _toggleBiometricLock() {
    if (_isPinLockEnabled && _isBiometricAvailable && !_isAuthenticating) {
      _handleBiometricChange(!_isBiometricLockEnabled);
    }
  }
}
