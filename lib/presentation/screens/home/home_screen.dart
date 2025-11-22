import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weave/presentation/widgets/calendar/calendar_widget.dart';
import 'package:weave/presentation/widgets/calendar/date_posts_bottom_sheet.dart';
import 'package:weave/presentation/widgets/category/category_bottom_sheet.dart';
import 'package:weave/presentation/screens/diary/daily_diary_write_screen.dart';
import 'package:weave/presentation/widgets/gallery/gallery_widget.dart';
import 'package:weave/di/injector.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  DateTime? _selectedDate;
  DateTime _currentMonth = DateTime.now();
  String _gallerySearchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 생체 인증은 앱 실행 시에만 수행되므로 여기서는 아무것도 하지 않음
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final authState = ref.read(authViewModelProvider);
    final user = authState.user;
    if (user != null) {
      ref
          .read(homeViewModelProvider.notifier)
          .loadData(
            user.uid,
            year: _currentMonth.year,
            month: _currentMonth.month,
          );
    }
  }

  void _changeMonth(DateTime newMonth) {
    setState(() {
      _currentMonth = DateTime(newMonth.year, newMonth.month);
      // 달력 이동 시 선택된 날짜 초기화
      _selectedDate = null;
    });
    // 월 변경 시 데이터 다시 로드
    _loadData();
  }

  void _selectDate(DateTime date) {
    final isCurrentMonth =
        date.year == _currentMonth.year && date.month == _currentMonth.month;
    if (!isCurrentMonth) {
      // 다른 달로 이동하는 경우
      setState(() {
        _currentMonth = DateTime(date.year, date.month);
        _selectedDate = date;
      });
      // 월 변경 시 데이터 다시 로드
      _loadData();
    } else {
      setState(() {
        _selectedDate = date;
      });
    }

    // 해당 날짜의 게시물 확인
    final homeState = ref.read(homeViewModelProvider);
    final dayRecords = homeState.records.where((record) {
      final recordDate = record.date;
      return recordDate.year == date.year &&
          recordDate.month == date.month &&
          recordDate.day == date.day;
    }).toList();

    final dayDiaries = homeState.diaries.where((diary) {
      final diaryDate = diary.date;
      return diaryDate.year == date.year &&
          diaryDate.month == date.month &&
          diaryDate.day == date.day;
    }).toList();

    // 게시물이 있으면 게시물 bottom sheet, 없으면 카테고리 bottom sheet 표시
    if (dayRecords.isNotEmpty || dayDiaries.isNotEmpty) {
      DatePostsBottomSheet.show(
        context,
        date,
        homeState.records,
        homeState.diaries,
        onCategorySelected: (category) {
          CategoryBottomSheet.show(
            context,
            _handleCategorySelection,
            selectedDate: _selectedDate,
          );
        },
      );
    } else {
      CategoryBottomSheet.show(
        context,
        _handleCategorySelection,
        selectedDate: _selectedDate,
      );
    }
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
    final homeState = ref.watch(homeViewModelProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // 갤러리 탭이 활성화되어 있고 검색어가 있으면 앱 종료하지 않음
          if (_tabController.index == 1 && _gallerySearchQuery.isNotEmpty) {
            return;
          }
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              // 달력 탭
              CalendarWidget(
                currentMonth: _currentMonth,
                selectedDate: _selectedDate,
                onDateSelected: _selectDate,
                onMonthChanged: _changeMonth,
                records: homeState.records,
                diaries: homeState.diaries,
              ),
              // 갤러리 탭
              GalleryWidget(
                records: homeState.records,
                diaries: homeState.diaries,
                isLoading: homeState.isLoading,
                onRefresh: _loadData,
                currentMonth: _currentMonth,
                onMonthChanged: _changeMonth,
                onSearchQueryChanged: (query) {
                  setState(() {
                    _gallerySearchQuery = query;
                  });
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(icon: Icon(Icons.calendar_today)),
                Tab(icon: Icon(Icons.photo_library)),
              ],
            ),
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
      ),
    );
  }
}
