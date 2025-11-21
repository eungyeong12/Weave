import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weave/presentation/widgets/calendar/calendar_widget.dart';
import 'package:weave/presentation/widgets/category/category_bottom_sheet.dart';
import 'package:weave/presentation/screens/diary/daily_diary_write_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime? _selectedDate;
  DateTime _currentMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      // 달력 이동 시 선택된 날짜 초기화
      _selectedDate = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      // 달력 이동 시 선택된 날짜 초기화
      _selectedDate = null;
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      // 클릭한 날짜가 현재 달이 아닌 경우 해당 달로 이동
      final isCurrentMonth =
          date.year == _currentMonth.year && date.month == _currentMonth.month;
      if (!isCurrentMonth) {
        _currentMonth = DateTime(date.year, date.month);
      }
      _selectedDate = date;
    });
    // bottomSheet 표시
    CategoryBottomSheet.show(
      context,
      _handleCategorySelection,
      selectedDate: _selectedDate,
    );
  }

  void _handleCategorySelection(String category) {
    if (category == '일상') {
      // 선택된 날짜가 없으면 오늘 날짜로 설정
      final selectedDate = _selectedDate ?? DateTime.now();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DailyDiaryWriteScreen(selectedDate: selectedDate),
        ),
      );
    } else {
      // 다른 카테고리 선택 처리 (나중에 구현)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$category 카테고리가 선택되었습니다.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CalendarWidget(
          currentMonth: _currentMonth,
          selectedDate: _selectedDate,
          onDateSelected: _selectDate,
          onPreviousMonth: _previousMonth,
          onNextMonth: _nextMonth,
        ),
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.green.shade600, Colors.green.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => CategoryBottomSheet.show(
              context,
              _handleCategorySelection,
              selectedDate: _selectedDate,
            ),
            borderRadius: BorderRadius.circular(28),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
