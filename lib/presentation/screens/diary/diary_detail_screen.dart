import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weave/domain/entities/diary/diary.dart';
import 'package:weave/presentation/screens/diary/daily_diary_write_screen.dart';

class DiaryDetailScreen extends StatelessWidget {
  final Diary diary;

  const DiaryDetailScreen({super.key, required this.diary});

  String _formatDate(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
  }

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left, color: Colors.black),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        title: Text(
          _formatDate(diary.date),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Theme(
            data: Theme.of(
              context,
            ).copyWith(splashFactory: InkRipple.splashFactory),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              color: Colors.green.shade200,
              splashRadius: 20,
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DailyDiaryWriteScreen(
                        selectedDate: diary.date,
                        diary: diary,
                      ),
                    ),
                  );
                } else if (value == 'delete') {
                  // TODO: 삭제 기능 구현
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('수정'),
                      ),
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('삭제'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
}
