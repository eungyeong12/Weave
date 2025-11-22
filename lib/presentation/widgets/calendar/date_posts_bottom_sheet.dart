import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weave/domain/entities/record/record.dart';
import 'package:weave/domain/entities/diary/diary.dart';
import 'package:weave/presentation/screens/diary/diary_detail_screen.dart';
import 'package:weave/presentation/screens/record/record_detail_screen.dart';

class DatePostsBottomSheet {
  static void show(
    BuildContext context,
    DateTime date,
    List<Record> records,
    List<Diary> diaries, {
    required Function(String) onCategorySelected,
  }) {
    // 해당 날짜의 게시물 필터링
    final dayRecords = records.where((record) {
      final recordDate = record.date;
      return recordDate.year == date.year &&
          recordDate.month == date.month &&
          recordDate.day == date.day;
    }).toList();

    final dayDiaries = diaries.where((diary) {
      final diaryDate = diary.date;
      return diaryDate.year == date.year &&
          diaryDate.month == date.month &&
          diaryDate.day == date.day;
    }).toList();

    // 모든 항목을 하나의 리스트로 합치고 createdAt 기준으로 정렬
    final allItems = <dynamic>[];
    allItems.addAll(dayRecords);
    allItems.addAll(dayDiaries);
    allItems.sort((a, b) {
      final createdAtA = a is Record ? a.createdAt : (a as Diary).createdAt;
      final createdAtB = b is Record ? b.createdAt : (b as Diary).createdAt;
      return createdAtB.compareTo(createdAtA); // 최신순
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 드래그 핸들
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // 날짜 헤더
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${date.year}년 ${date.month}월 ${date.day}일',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${allItems.length}개',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              onCategorySelected('');
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Divider(height: 1),
                  ),
                  // 게시물 리스트
                  Expanded(
                    child: allItems.isEmpty
                        ? Center(
                            child: Text(
                              '기록이 없습니다',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: allItems.length,
                            itemBuilder: (context, index) {
                              final item = allItems[index];
                              if (item is Record) {
                                return _RecordItem(
                                  record: item,
                                  getProxiedImageUrl: _getProxiedImageUrl,
                                  getTypeIcon: _getTypeIcon,
                                );
                              } else {
                                return _DiaryItem(
                                  diary: item as Diary,
                                  getProxiedImageUrl: _getProxiedImageUrl,
                                );
                              }
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static String _getProxiedImageUrl(String originalUrl) {
    try {
      final projectId = Firebase.app().options.projectId;
      final encodedUrl = Uri.encodeComponent(originalUrl);
      return 'https://us-central1-$projectId.cloudfunctions.net/proxyImage?url=$encodedUrl';
    } catch (e) {
      return originalUrl;
    }
  }

  static IconData _getTypeIcon(String type) {
    switch (type) {
      case 'book':
        return Icons.book;
      case 'movie':
        return Icons.movie;
      case 'performance':
        return Icons.theater_comedy;
      default:
        return Icons.article;
    }
  }
}

class _RecordItem extends StatelessWidget {
  final Record record;
  final String Function(String) getProxiedImageUrl;
  final IconData Function(String) getTypeIcon;

  const _RecordItem({
    required this.record,
    required this.getProxiedImageUrl,
    required this.getTypeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecordDetailScreen(
              record: record,
              getProxiedImageUrl: getProxiedImageUrl,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // 이미지 영역
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: record.imageUrl != null && record.imageUrl!.isNotEmpty
                  ? Image.network(
                      getProxiedImageUrl(record.imageUrl!),
                      width: 92,
                      height: 92,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 92,
                          height: 92,
                          color: Colors.grey.shade200,
                          child: Icon(
                            getTypeIcon(record.type),
                            color: Colors.grey.shade400,
                            size: 32,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 92,
                      height: 92,
                      color: Colors.grey.shade200,
                      child: Icon(
                        getTypeIcon(record.type),
                        color: Colors.grey.shade400,
                        size: 32,
                      ),
                    ),
            ),
            // 정보 영역
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          getTypeIcon(record.type),
                          size: 10,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTypeName(record.type),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (record.content.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        record.content,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (record.rating > 0) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 13,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            record.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'book':
        return '도서';
      case 'movie':
        return '영화·드라마';
      case 'performance':
        return '공연·전시';
      default:
        return '기타';
    }
  }
}

class _DiaryItem extends StatelessWidget {
  final Diary diary;
  final String Function(String) getProxiedImageUrl;

  const _DiaryItem({required this.diary, required this.getProxiedImageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiaryDetailScreen(diary: diary),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // 이미지 영역
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: diary.imageUrls.isNotEmpty
                  ? Image.network(
                      getProxiedImageUrl(diary.imageUrls.first),
                      width: 92,
                      height: 92,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 92,
                          height: 92,
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.book,
                            color: Colors.grey.shade400,
                            size: 32,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 92,
                      height: 92,
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.book,
                        color: Colors.grey.shade400,
                        size: 32,
                      ),
                    ),
            ),
            // 정보 영역
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.book, size: 10, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '일상',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      diary.content,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (diary.imageUrls.length > 1) ...[
                      const SizedBox(height: 2),
                      Text(
                        '+${diary.imageUrls.length - 1}장',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
