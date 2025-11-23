import 'package:flutter/material.dart';
import 'package:weave/core/services/pin_service.dart';

class PinChangeScreen extends StatefulWidget {
  const PinChangeScreen({super.key});

  @override
  State<PinChangeScreen> createState() => _PinChangeScreenState();
}

class _PinChangeScreenState extends State<PinChangeScreen> {
  final PinService _pinService = PinService();
  final List<String> _currentPin = [];
  final List<String> _newPin = [];
  final List<String> _confirmPin = [];
  int _step = 0; // 0: 기존 비밀번호, 1: 새 비밀번호, 2: 새 비밀번호 확인
  String? _errorMessage;

  void _onNumberPressed(String number) {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }

    if (_step == 0) {
      // 기존 비밀번호 입력
      if (_currentPin.length < 4) {
        setState(() {
          _currentPin.add(number);
        });
        if (_currentPin.length == 4) {
          _verifyCurrentPin();
        }
      }
    } else if (_step == 1) {
      // 새 비밀번호 입력
      if (_newPin.length < 4) {
        setState(() {
          _newPin.add(number);
        });
        if (_newPin.length == 4) {
          _startConfirm();
        }
      }
    } else if (_step == 2) {
      // 새 비밀번호 확인
      if (_confirmPin.length < 4) {
        setState(() {
          _confirmPin.add(number);
        });
        if (_confirmPin.length == 4) {
          _verifyNewPin();
        }
      }
    }
  }

  void _onDeletePressed() {
    if (_step == 0) {
      if (_currentPin.isNotEmpty) {
        setState(() {
          _currentPin.removeLast();
        });
      }
    } else if (_step == 1) {
      if (_newPin.isNotEmpty) {
        setState(() {
          _newPin.removeLast();
        });
      }
    } else if (_step == 2) {
      if (_confirmPin.isNotEmpty) {
        setState(() {
          _confirmPin.removeLast();
        });
      }
    }
  }

  Future<void> _verifyCurrentPin() async {
    final currentPinStr = _currentPin.join();
    final isValid = await _pinService.verifyPinCode(currentPinStr);

    if (isValid) {
      setState(() {
        _step = 1;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = '기존 비밀번호가 일치하지 않습니다.';
        _currentPin.clear();
      });
    }
  }

  void _startConfirm() {
    setState(() {
      _step = 2;
      _errorMessage = null;
    });
  }

  Future<void> _verifyNewPin() async {
    final newPinStr = _newPin.join();
    final confirmPinStr = _confirmPin.join();

    if (newPinStr != confirmPinStr) {
      setState(() {
        _errorMessage = '새 비밀번호가 일치하지 않습니다.';
        _newPin.clear();
        _confirmPin.clear();
        _step = 1;
      });
      return;
    }

    // 새 비밀번호 저장
    final pinSaved = await _pinService.setPinCode(newPinStr);

    if (pinSaved && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('비밀번호가 변경되었습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = '비밀번호 변경 중 오류가 발생했습니다.';
          _newPin.clear();
          _confirmPin.clear();
          _step = 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentPin;
    String instructionText;

    if (_step == 0) {
      currentPin = _currentPin;
      instructionText = '기존 비밀번호를 입력해주세요';
    } else if (_step == 1) {
      currentPin = _newPin;
      instructionText = '새 비밀번호를 입력해주세요';
    } else {
      currentPin = _confirmPin;
      instructionText = '새 비밀번호를 다시 입력해주세요';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
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
          '비밀번호 변경',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // 작은 로고 (상단 중앙)
            Icon(Icons.lock_outline, size: 40, color: Colors.green.shade600),
            const SizedBox(height: 32),
            // 안내 텍스트
            Text(
              instructionText,
              style: const TextStyle(
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
                    index < currentPin.length ? '●' : '─',
                    style: TextStyle(
                      fontSize: 20,
                      color: index < currentPin.length
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
