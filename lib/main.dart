import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'di/injector.dart';
import 'data/models/user/user_dto.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/auth/lock_screen.dart';
import 'presentation/screens/auth/pin_lock_screen.dart';
import 'core/services/biometric_service.dart';
import 'core/services/pin_service.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 파일 로드
  await dotenv.load(fileName: ".env");

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // 빌드가 완료된 후에 사용자 정보를 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final firebaseAuth = ref.read(firebaseAuthProvider);
      final currentUser = firebaseAuth.currentUser;

      if (currentUser != null) {
        final userDto = UserDto.fromFirebaseUser(currentUser);
        final authViewModel = ref.read(authViewModelProvider.notifier);
        authViewModel.setCurrentUser(userDto);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Firebase Auth의 현재 사용자 확인
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final currentUser = firebaseAuth.currentUser;

    return MaterialApp(
      title: 'Weave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      locale: const Locale('ko', 'KR'),
      home: _buildInitialScreen(currentUser),
      builder: (context, child) {
        if (kIsWeb) {
          return Container(
            color: const Color.fromARGB(255, 240, 240, 240).withOpacity(0.5),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: child!,
              ),
            ),
          );
        }
        return child!;
      },
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/lock': (context) => const LockScreen(),
      },
    );
  }

  Widget _buildInitialScreen(dynamic currentUser) {
    if (currentUser == null) {
      return const LoginScreen();
    }

    // 비밀번호와 생체 인증 상태 확인
    final pinService = PinService();
    final biometricService = BiometricService();

    return FutureBuilder<Map<String, bool>>(
      future: Future.wait([
        pinService.isPinEnabled(),
        kIsWeb ? Future.value(false) : biometricService.isBiometricEnabled(),
      ]).then((results) => {'pin': results[0], 'biometric': results[1]}),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(backgroundColor: Colors.white);
        }

        final pinEnabled = snapshot.data?['pin'] ?? false;
        final biometricEnabled = snapshot.data?['biometric'] ?? false;

        // 비밀번호가 비활성화되어 있으면 생체 인증도 무시 (비밀번호가 필수)
        if (!pinEnabled) {
          return const HomeScreen();
        }

        // 둘 다 활성화되어 있으면 우선순위: 생체 인증 > 비밀번호
        if (pinEnabled && biometricEnabled) {
          // 생체 인증이 세션 인증이 안 되어 있으면 생체 인증 화면으로
          if (!biometricService.isAuthenticatedInSession()) {
            return const LockScreen();
          }
          // 생체 인증은 성공했지만 비밀번호가 세션 인증이 안 되어 있으면 비밀번호 화면으로
          if (!pinService.isAuthenticatedInSession()) {
            return const PinLockScreen();
          }
        }
        // 비밀번호만 활성화되어 있고 세션 인증이 안 되어 있으면 비밀번호 잠금 화면
        else if (pinEnabled && !pinService.isAuthenticatedInSession()) {
          return const PinLockScreen();
        }
        // 생체 인증만 활성화되어 있고 세션 인증이 안 되어 있으면 생체 인증 잠금 화면
        else if (biometricEnabled &&
            !biometricService.isAuthenticatedInSession()) {
          return const LockScreen();
        }

        return const HomeScreen();
      },
    );
  }
}
