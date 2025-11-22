import 'package:flutter/material.dart';

class DatePickerBottomSheet extends StatefulWidget {
  final DateTime initialDate;

  const DatePickerBottomSheet({super.key, required this.initialDate});

  @override
  State<DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();

  static Future<DateTime?> show(BuildContext context, DateTime initialDate) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DatePickerBottomSheet(initialDate: initialDate),
    );
  }
}

class _DatePickerBottomSheetState extends State<DatePickerBottomSheet> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _getDaysInMonth(_selectedYear, _selectedMonth);
    if (_selectedDay > daysInMonth) {
      _selectedDay = daysInMonth;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            // 년도, 월, 일 선택 영역
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  // 년도 선택
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 40,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        controller: FixedExtentScrollController(
                          initialItem: _selectedYear - 2000,
                        ),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedYear = 2000 + index;
                            final newDaysInMonth = _getDaysInMonth(
                              _selectedYear,
                              _selectedMonth,
                            );
                            if (_selectedDay > newDaysInMonth) {
                              _selectedDay = newDaysInMonth;
                            }
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final year = 2000 + index;
                            final isSelected = year == _selectedYear;
                            return Center(
                              child: Text(
                                '$year',
                                style: TextStyle(
                                  fontSize: isSelected ? 18 : 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.green.shade600
                                      : Colors.black87,
                                ),
                              ),
                            );
                          },
                          childCount: 101, // 2000 ~ 2100
                        ),
                      ),
                    ),
                  ),
                  // 월 선택
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 40,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        controller: FixedExtentScrollController(
                          initialItem: _selectedMonth - 1,
                        ),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedMonth = index + 1;
                            final newDaysInMonth = _getDaysInMonth(
                              _selectedYear,
                              _selectedMonth,
                            );
                            if (_selectedDay > newDaysInMonth) {
                              _selectedDay = newDaysInMonth;
                            }
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final month = index + 1;
                            final isSelected = month == _selectedMonth;
                            return Center(
                              child: Text(
                                '$month월',
                                style: TextStyle(
                                  fontSize: isSelected ? 18 : 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.green.shade600
                                      : Colors.black87,
                                ),
                              ),
                            );
                          },
                          childCount: 12,
                        ),
                      ),
                    ),
                  ),
                  // 일 선택
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 40,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        controller: FixedExtentScrollController(
                          initialItem: _selectedDay - 1,
                        ),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedDay = index + 1;
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final day = index + 1;
                            final isSelected = day == _selectedDay;
                            return Center(
                              child: Text(
                                '$day일',
                                style: TextStyle(
                                  fontSize: isSelected ? 18 : 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.green.shade600
                                      : Colors.black87,
                                ),
                              ),
                            );
                          },
                          childCount: daysInMonth,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 확인 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      DateTime(_selectedYear, _selectedMonth, _selectedDay),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
