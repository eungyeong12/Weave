import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weave/domain/entities/diary/diary.dart';

class DiaryDetailScreen extends StatelessWidget {
  final Diary diary;

  const DiaryDetailScreen({super.key, required this.diary});

  String _formatDate(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
  }

  String _formatDateTime(DateTime dateTime) {
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$year.$month.$day $hour:$minute';
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
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.chevron_left, color: Colors.black),
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
          Material(
            color: Colors.transparent,
            child: PopupMenuButton<String>(
              splashRadius: 0,
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onSelected: (value) {
                if (value == 'edit') {
                  // TODO: 수정 기능 구현
                } else if (value == 'delete') {
                  // TODO: 삭제 기능 구현
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Text('수정'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Text('삭제'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 작성 시간
              Text(
                _formatDateTime(diary.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              // 이미지들
              if (diary.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildImageGrid(),
              ],
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
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    if (diary.imageUrls.length == 1) {
      // 이미지가 1개일 때는 전체 너비로 표시
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _getProxiedImageUrl(diary.imageUrls.first),
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey.shade200,
              child: const Icon(Icons.image, size: 50, color: Colors.grey),
            );
          },
        ),
      );
    } else if (diary.imageUrls.length == 2) {
      // 이미지가 2개일 때는 2열로 표시
      return Row(
        children: [
          Expanded(child: _buildImageItem(diary.imageUrls[0], 0)),
          const SizedBox(width: 8),
          Expanded(child: _buildImageItem(diary.imageUrls[1], 1)),
        ],
      );
    } else {
      // 이미지가 3개 이상일 때는 그리드로 표시
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: diary.imageUrls.length,
        itemBuilder: (context, index) {
          return _buildImageItem(diary.imageUrls[index], index);
        },
      );
    }
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
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.image, size: 50, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }
}
