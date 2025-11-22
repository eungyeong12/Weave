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
import 'core/services/biometric_service.dart';

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

    // 웹에서는 생체 인증을 사용하지 않으므로 바로 홈 화면으로 이동
    if (kIsWeb) {
      return const HomeScreen();
    }

    // 생체 인증이 활성화되어 있는지 확인
    final biometricService = BiometricService();
    return FutureBuilder<bool>(
      future: biometricService.isBiometricEnabled(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 로딩 중에는 빈 화면 또는 로딩 인디케이터 표시
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 생체 인증이 활성화되어 있으면 잠금 화면, 아니면 홈 화면
        // 앱 실행 시마다 인증을 요구하므로 항상 잠금 화면으로 이동
        if (snapshot.data == true) {
          return const LockScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
