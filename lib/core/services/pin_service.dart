import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 앱 실행 중 인증 상태 (메모리에만 저장, 앱 종료 시 초기화됨)
  bool _isAuthenticatedInSession = false;

  // 현재 사용자 ID 가져오기
  String? get _currentUserId => _auth.currentUser?.uid;

  // 비밀번호 해시화
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 비밀번호 활성화 여부 저장
  Future<bool> setPinEnabled(bool enabled) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return false;

      await _firestore.collection('users').doc(userId).set({
        'pinEnabled': enabled,
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('비밀번호 활성화 여부 저장 실패: $e');
      return false;
    }
  }

  // 비밀번호 활성화 여부 로드
  Future<bool> isPinEnabled() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return false;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return false;

      final data = doc.data();
      return data?['pinEnabled'] ?? false;
    } catch (e) {
      print('비밀번호 활성화 여부 로드 실패: $e');
      return false;
    }
  }

  // 비밀번호 저장 (해시화해서 저장)
  Future<bool> setPinCode(String pinCode) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return false;

      final hashedPin = _hashPin(pinCode);
      await _firestore.collection('users').doc(userId).set({
        'pinHash': hashedPin,
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('비밀번호 저장 실패: $e');
      return false;
    }
  }

  // 비밀번호 해시 로드
  Future<String?> getPinHash() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return null;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data();
      return data?['pinHash'] as String?;
    } catch (e) {
      print('비밀번호 해시 로드 실패: $e');
      return null;
    }
  }

  // 비밀번호 검증
  Future<bool> verifyPinCode(String inputPin) async {
    try {
      final savedPinHash = await getPinHash();
      if (savedPinHash == null) return false;

      final inputPinHash = _hashPin(inputPin);
      return savedPinHash == inputPinHash;
    } catch (e) {
      print('비밀번호 검증 실패: $e');
      return false;
    }
  }

  // 비밀번호 삭제
  Future<bool> deletePinCode() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return false;

      await _firestore.collection('users').doc(userId).update({
        'pinHash': FieldValue.delete(),
      });

      return true;
    } catch (e) {
      print('비밀번호 삭제 실패: $e');
      return false;
    }
  }

  // 현재 세션에서 인증되었는지 확인 (앱 실행 중에만 유효)
  bool isAuthenticatedInSession() {
    return _isAuthenticatedInSession;
  }

  // 세션 인증 상태 설정
  void setSessionAuth(bool authenticated) {
    _isAuthenticatedInSession = authenticated;
  }

  // 세션 인증 상태 초기화 (로그아웃 시 등)
  void clearSessionAuth() {
    _isAuthenticatedInSession = false;
  }
}
