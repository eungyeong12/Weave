import 'package:flutter/material.dart';
import 'package:weave/core/services/pin_service.dart';
import 'package:weave/presentation/screens/home/home_screen.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final PinService _pinService = PinService();
  final List<String> _enteredPin = [];
  String? _errorMessage;

  void _onNumberPressed(String number) {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }

    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin.add(number);
      });
      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin.removeLast();
      });
    }
  }

  Future<void> _verifyPin() async {
    final enteredPinStr = _enteredPin.join();
    final isValid = await _pinService.verifyPinCode(enteredPinStr);

    if (isValid) {
      // 인증 성공
      _pinService.setSessionAuth(true);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      // 인증 실패
      if (mounted) {
        setState(() {
          _errorMessage = '비밀번호가 일치하지 않습니다.';
          _enteredPin.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // 작은 로고 (상단 중앙)
            Icon(Icons.lock_outline, size: 40, color: Colors.green.shade600),
            const SizedBox(height: 32),
            // 안내 텍스트
            const Text(
              '비밀번호를 입력해주세요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            // PIN 표시 (대시)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    index < _enteredPin.length ? '●' : '─',
                    style: TextStyle(
                      fontSize: 20,
                      color: index < _enteredPin.length
                          ? Colors.green
                          : Colors.grey.shade400,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                );
              }),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
            const Spacer(),
            // 숫자 키패드
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildNumberButton('1')),
                    Expanded(child: _buildNumberButton('2')),
                    Expanded(child: _buildNumberButton('3')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildNumberButton('4')),
                    Expanded(child: _buildNumberButton('5')),
                    Expanded(child: _buildNumberButton('6')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildNumberButton('7')),
                    Expanded(child: _buildNumberButton('8')),
                    Expanded(child: _buildNumberButton('9')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: SizedBox(width: 80, height: 80),
                    ), // 빈 공간
                    Expanded(child: _buildNumberButton('0')),
                    Expanded(child: _buildDeleteButton()),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberPressed(number),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(fontSize: 20, color: Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _onDeletePressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: Icon(Icons.close, size: 20, color: Colors.grey.shade600),
        ),
      ),
    );
  }
}
