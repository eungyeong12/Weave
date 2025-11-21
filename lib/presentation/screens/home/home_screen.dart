import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weave/di/injector.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authViewModel = ref.watch(authViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weave'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authViewModelNotifier = ref.read(
                authViewModelProvider.notifier,
              );
              await authViewModelNotifier.signOut();
              // 로그아웃 성공 후 로그인 페이지로 이동
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            Text('환영합니다!', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            if (authViewModel.user != null) ...[
              Text(
                '이메일: ${authViewModel.user!.email ?? "없음"}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'UID: ${authViewModel.user!.uid}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
