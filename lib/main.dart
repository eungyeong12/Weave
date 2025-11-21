import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'di/injector.dart';
import 'data/models/user/user_dto.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';

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

    // 초기 라우트 결정
    final initialRoute = currentUser != null ? '/home' : '/';

    return MaterialApp(
      title: 'Weave',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
