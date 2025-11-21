import 'package:flutter/material.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const CalendarWidget({
    super.key,
    required this.currentMonth,
    this.selectedDate,
    required this.onDateSelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
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

  bool _isSelected(
    DateTime date,
    DateTime? selectedDate,
    DateTime currentMonth,
  ) {
    if (selectedDate == null) return false;
    // 선택된 날짜가 현재 달에 속하지 않으면 선택되지 않은 것으로 처리
    if (selectedDate.year != currentMonth.year ||
        selectedDate.month != currentMonth.month) {
      return false;
    }
    return date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 사용 가능한 높이 계산 (헤더와 요일 헤더 제외)
        final availableHeight = constraints.maxHeight;
        final headerHeight = 48.0; // 헤더 높이
        final weekdayHeaderHeight = 24.0; // 요일 헤더 높이
        final spacing = 8.0; // 헤더와 그리드 사이 간격
        final gridHeight =
            availableHeight - headerHeight - weekdayHeaderHeight - spacing;
        // 6주 + 마지막 주 아래 공간까지 포함하여 7개의 동일한 공간으로 나눔
        final cellHeight = gridHeight / 7;
        final cellWidth = (constraints.maxWidth - 16) / 7; // 7열, 좌우 8dp씩

        return GestureDetector(
          onHorizontalDragEnd: (details) {
            // 스와이프 속도와 거리를 고려하여 달력 이동
            const sensitivity = 50.0; // 최소 스와이프 거리
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! > sensitivity) {
                // 오른쪽으로 스와이프 (이전 달)
                onPreviousMonth();
              } else if (details.primaryVelocity! < -sensitivity) {
                // 왼쪽으로 스와이프 (다음 달)
                onNextMonth();
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // 캘린더 헤더 (월/년도 및 네비게이션)
                Row(
                  children: [
                    GestureDetector(
                      onTap: onPreviousMonth,
                      child: const Icon(Icons.chevron_left),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${currentMonth.year}년 ${currentMonth.month}월',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onNextMonth,
                      child: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 요일 헤더
                Row(
                  children: ['일', '월', '화', '수', '목', '금', '토']
                      .map(
                        (day) => SizedBox(
                          width: cellWidth,
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
                      final isSelected = _isSelected(
                        date,
                        selectedDate,
                        currentMonth,
                      );

                      return GestureDetector(
                        onTap: () => onDateSelected(date),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.green.shade600
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: isSelected
                                          ? Colors.white
                                          : !isCurrentMonth
                                          ? Colors.grey.shade300
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
