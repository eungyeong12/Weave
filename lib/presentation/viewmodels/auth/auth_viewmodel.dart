import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weave/core/failure.dart';
import 'package:weave/domain/entities/user/user.dart';
import 'package:weave/domain/usecases/auth/sign_in_with_email_and_password.dart';
import 'package:weave/domain/usecases/auth/sign_up_with_email_and_password.dart';
import 'package:weave/domain/usecases/auth/sign_out.dart';
import 'package:weave/domain/usecases/auth/delete_user.dart';
import 'package:dartz/dartz.dart';

// ui가 어떻게 보여야 하는지에 대한 모든 정보를 담고 있는 불변 데이터 클래스
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  AuthState({this.isLoading = false, this.user, this.error});

  // AuthState는 불변이므로 상태를 수정하는 대신
  // 새로운 AuthState 객체를 복사해서 생성
  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
    );
  }

  // 'factory' 생성자는 'AuthState.initial()'을 호출하면
  // 모든 값이 기본 값으로 채워진 초기 상태 객체를 반환
  factory AuthState.initial() => AuthState();
}

// Riverpod의 'StateNNotifier'를 상속받으며, 'AuthState'를 관리하는 두뇌
// UI는 이 ViewModel의 '상태(state)'가 변하는 것을 구독함
class AuthViewModel extends StateNotifier<AuthState> {
  // Domain 계층의 UseCase를 멤버 변수로 가짐
  final SignInWithEmailAndPasswordUseCase _signIn;
  final SignUpWithEmailAndPasswordUseCase _signUp;
  final SignOutUseCase _signOut;
  final DeleteUserUseCase _deleteUser;

  // 생성자를 호출하여 부모(SstateNotifier)에게
  // 관리할 상태의 초기값은 AuthState.initial()이라고 알려줌
  // 'this._signIn', 'this._signUp', 'this._signOut': UseCase를 외부에서 주입받음
  AuthViewModel(this._signIn, this._signUp, this._signOut, this._deleteUser)
    : super(AuthState.initial());

  // 현재 로그인된 사용자를 설정하는 메서드 (앱 시작 시 사용)
  void setCurrentUser(User user) {
    state = state.copyWith(user: user, clearError: true);
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // 로그인 시작: 에러를 명시적으로 제거하고 로딩 시작
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // 주입받은 UseCase 인스턴스(_signIn)를 함수처럼 호출함
      final Either<Failure, User> result = await _signIn(
        email: email,
        password: password,
      );

      // 'result' (Either 객체)에 대해 'fold'를 호출하여 결과를 분기 처리
      result.fold(
        (failure) {
          // 실패: 로딩 종료, 에러 설정
          state = state.copyWith(isLoading: false, error: failure.message);
        },
        (user) {
          // 성공: 로딩 종료, 사용자 설정, 에러 제거
          state = state.copyWith(
            isLoading: false,
            user: user,
            clearError: true,
          );
        },
      );
    } catch (e) {
      // 예상치 못한 예외
      state = state.copyWith(
        isLoading: false,
        error: '로그인 중 예상치 못한 오류가 발생했습니다.',
      );
    }
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // 회원가입 시작: 에러를 명시적으로 제거하고 로딩 시작
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final Either<Failure, User> result = await _signUp(
        email: email,
        password: password,
      );

      result.fold(
        (failure) {
          // 실패: 로딩 종료, 에러 설정
          state = state.copyWith(isLoading: false, error: failure.message);
        },
        (user) {
          // 성공: 로딩 종료, 사용자 설정, 에러 제거
          state = state.copyWith(
            isLoading: false,
            user: user,
            clearError: true,
          );
        },
      );
    } catch (e) {
      // 예상치 못한 예외
      state = state.copyWith(
        isLoading: false,
        error: '회원가입 중 예상치 못한 오류가 발생했습니다.',
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final Either<Failure, void> result = await _signOut();
      result.fold(
        (failure) {
          state = state.copyWith(isLoading: false, error: failure.message);
        },
        (_) {
          state = state.copyWith(
            isLoading: false,
            clearUser: true,
            clearError: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '로그아웃 중 예상치 못한 오류가 발생했습니다.',
      );
    }
  }

  Future<void> deleteUser({required String userId}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final Either<Failure, void> result = await _deleteUser(userId: userId);
      result.fold(
        (failure) {
          state = state.copyWith(isLoading: false, error: failure.message);
        },
        (_) {
          state = state.copyWith(
            isLoading: false,
            clearUser: true,
            clearError: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '회원 탈퇴 중 예상치 못한 오류가 발생했습니다.',
      );
    }
  }
}
