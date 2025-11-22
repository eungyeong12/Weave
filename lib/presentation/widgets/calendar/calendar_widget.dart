import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:weave/domain/entities/record/record.dart';
import 'package:weave/domain/entities/diary/diary.dart';
import 'package:weave/presentation/widgets/gallery/month_picker_bottom_sheet.dart';
import 'package:weave/presentation/screens/settings/settings_screen.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onMonthChanged;
  final List<Record> records;
  final List<Diary> diaries;

  const CalendarWidget({
    super.key,
    required this.currentMonth,
    this.selectedDate,
    required this.onDateSelected,
    required this.onMonthChanged,
    this.records = const [],
    this.diaries = const [],
  });

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday % 7; // 일요일 = 0

    final List<DateTime> days = [];

    // 이전 달의 마지막 날들 추가
    if (firstWeekday > 0) {
      final previousMonth = DateTime(month.year, month.month - 1);
      final daysInPreviousMonth = DateTime(
        previousMonth.year,
        previousMonth.month + 1,
        0,
      ).day;
      for (int i = firstWeekday - 1; i >= 0; i--) {
        days.add(
          DateTime(
            previousMonth.year,
            previousMonth.month,
            daysInPreviousMonth - i,
          ),
        );
      }
    }

    // 현재 달의 날들 추가
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    // 다음 달의 첫 날들 추가 (42개 셀을 채우기 위해)
    final remainingDays = 42 - days.length;
    for (int i = 1; i <= remainingDays; i++) {
      days.add(DateTime(month.year, month.month + 1, i));
    }

    return days;
  }

  bool _isCurrentMonth(DateTime date, DateTime currentMonth) {
    return date.year == currentMonth.year && date.month == currentMonth.month;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String? _getLatestImageUrl(DateTime date) {
    // 해당 날짜의 모든 기록과 일기 수집
    final dayRecords = records.where((record) {
      final recordDate = record.date;
      return recordDate.year == date.year &&
          recordDate.month == date.month &&
          recordDate.day == date.day &&
          record.imageUrl != null &&
          record.imageUrl!.isNotEmpty;
    }).toList();

    final dayDiaries = diaries.where((diary) {
      final diaryDate = diary.date;
      return diaryDate.year == date.year &&
          diaryDate.month == date.month &&
          diaryDate.day == date.day &&
          diary.imageUrls.isNotEmpty;
    }).toList();

    // 모든 항목을 하나의 리스트로 합치고 createdAt 기준으로 정렬
    final allItems = <({String imageUrl, DateTime createdAt})>[];

    // Record 추가
    for (final record in dayRecords) {
      allItems.add((imageUrl: record.imageUrl!, createdAt: record.createdAt));
    }

    // Diary 추가 (첫 번째 이미지만 사용)
    for (final diary in dayDiaries) {
      if (diary.imageUrls.isNotEmpty) {
        allItems.add((
          imageUrl: diary.imageUrls.first,
          createdAt: diary.createdAt,
        ));
      }
    }

    // createdAt 기준으로 정렬 (최신순)
    allItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 가장 최근 항목의 이미지 URL 반환
    return allItems.isNotEmpty ? allItems.first.imageUrl : null;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // 셀 너비 계산 (7열, 좌우 8dp씩 패딩)
        final cellWidth = (constraints.maxWidth - 16) / 7;
        // 셀 높이 계산 (16:9 비율 유지: 높이:너비 = 16:9)
        final cellHeight = cellWidth * 16 / 9;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                // 이전 달로 이동
                GestureDetector(
                  onTap: () {
                    final previousMonth = DateTime(
                      currentMonth.year,
                      currentMonth.month - 1,
                    );
                    onMonthChanged(previousMonth);
                  },
                  child: const Icon(Icons.chevron_left, color: Colors.black),
                ),
                const SizedBox(width: 4),
                // 년도/월 텍스트 (클릭 시 다이얼로그 표시)
                GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await MonthPickerBottomSheet.show(
                      context,
                      currentMonth,
                    );
                    if (picked != null) {
                      onMonthChanged(picked);
                    }
                  },
                  child: Text(
                    '${currentMonth.year}년 ${currentMonth.month}월',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // 다음 달로 이동
                GestureDetector(
                  onTap: () {
                    final nextMonth = DateTime(
                      currentMonth.year,
                      currentMonth.month + 1,
                    );
                    onMonthChanged(nextMonth);
                  },
                  child: const Icon(Icons.chevron_right, color: Colors.black),
                ),
              ],
            ),
            actions: [
              // 설정 아이콘
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings, color: Colors.grey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              if (kIsWeb) const SizedBox(width: 8),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                // 요일 헤더
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['일', '월', '화', '수', '목', '금', '토']
                      .map(
                        (day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                // 캘린더 그리드
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: cellWidth / cellHeight,
                    ),
                    itemCount: 42,
                    itemBuilder: (context, index) {
                      final days = _getDaysInMonth(currentMonth);
                      final date = days[index];
                      final isCurrentMonth = _isCurrentMonth(
                        date,
                        currentMonth,
                      );
                      final isToday = _isToday(date);
                      final imageUrl = _getLatestImageUrl(date);

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onDateSelected(date),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: imageUrl != null && isCurrentMonth
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                )
                              : null,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 배경 이미지
                              if (imageUrl != null && isCurrentMonth)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _getProxiedImageUrl(imageUrl),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                              // 날짜 텍스트
                              Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: isToday && isCurrentMonth
                                      ? Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${date.day}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Text(
                                          '${date.day}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: !isCurrentMonth
                                                ? Colors.grey.shade300
                                                : (imageUrl != null &&
                                                          isCurrentMonth
                                                      ? Colors.white
                                                      : Colors.black87),
                                            shadows:
                                                imageUrl != null &&
                                                    isCurrentMonth
                                                ? [
                                                    Shadow(
                                                      offset: const Offset(
                                                        0,
                                                        1,
                                                      ),
                                                      blurRadius: 3,
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
