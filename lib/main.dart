import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weave/presentation/widgets/auth/google_signin_button.dart';
import 'firebase_options.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weave',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Google 로그인 버튼 테스트')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GoogleSignInButton(
              onPressed: () {
                print('Google 로그인 버튼 클릭됨');
              },
            ),
          ),
        ),
      ),
    );
  }
}
