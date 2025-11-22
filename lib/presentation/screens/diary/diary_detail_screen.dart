import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weave/domain/entities/diary/diary.dart';
import 'package:weave/presentation/screens/diary/daily_diary_write_screen.dart';
import 'package:weave/presentation/screens/home/home_screen.dart';
import 'package:weave/presentation/widgets/common/detail_screen_app_bar.dart';
import 'package:weave/presentation/widgets/common/delete_confirmation_dialog.dart';
import 'package:weave/di/injector.dart';

class DiaryDetailScreen extends ConsumerStatefulWidget {
  final Diary diary;

  const DiaryDetailScreen({super.key, required this.diary});

  @override
  ConsumerState<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends ConsumerState<DiaryDetailScreen> {
  Diary get diary => widget.diary;

  String _getProxiedImageUrl(String originalUrl) {
    try {
      final projectId = Firebase.app().options.projectId;
      final encodedUrl = Uri.encodeComponent(originalUrl);
      return 'https://us-central1-$projectId.cloudfunctions.net/proxyImage?url=$encodedUrl';
    } catch (e) {
      return originalUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DetailScreenAppBar(
        date: diary.date,
        onEdit: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DailyDiaryWriteScreen(selectedDate: diary.date, diary: diary),
            ),
          );
        },
        onDelete: () => _showDeleteConfirmationDialog(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 이미지들
                if (diary.imageUrls.isNotEmpty) ...[_buildImageGrid()],
                // 내용
                if (diary.content.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    diary.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    const double imageHeight = 150; // 2:3 비율

    return SizedBox(
      height: imageHeight,
      child: Center(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: diary.imageUrls.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
              child: _buildImageItem(diary.imageUrls[index], index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageItem(String imageUrl, int index) {
    return GestureDetector(
      onTap: () {
        // TODO: 이미지 확대 보기
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _getProxiedImageUrl(imageUrl),
          width: 100,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 100,
              height: 150,
              color: Colors.grey.shade200,
              child: const Icon(Icons.image, size: 50, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    DeleteConfirmationDialog.show(context, _deleteDiary);
  }

  Future<void> _deleteDiary() async {
    if (diary.id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('삭제할 일기를 찾을 수 없습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

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

    final viewModel = ref.read(dailyDiaryWriteViewModelProvider.notifier);

    await viewModel.deleteDailyDiary(
      diaryId: diary.id!,
      userId: user.uid,
      imageUrls: diary.imageUrls,
    );

    final state = ref.read(dailyDiaryWriteViewModelProvider);

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

    // 삭제 성공 시 홈 화면으로 이동
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('기록이 삭제되었습니다.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
