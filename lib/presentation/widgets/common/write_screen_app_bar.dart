import 'package:flutter/material.dart';
import 'package:weave/presentation/widgets/diary/date_picker_bottom_sheet.dart';
import 'package:weave/presentation/widgets/record/save_button.dart';

class WriteScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onSave;
  final bool isContentEmpty;
  final bool isLoading;
  final double? titleSpacing;

  const WriteScreenAppBar({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.onSave,
    required this.isContentEmpty,
    required this.isLoading,
    this.titleSpacing,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: titleSpacing ?? 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.chevron_left, color: Colors.black),
        ),
      ),
      title: GestureDetector(
        onTap: () async {
          final DateTime? picked = await DatePickerBottomSheet.show(
            context,
            selectedDate,
          );
          if (picked != null) {
            onDateChanged(picked);
          }
        },
        child: Text(
          _formatDate(selectedDate),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      actions: [
        SaveButton(
          onSave: onSave,
          isContentEmpty: isContentEmpty,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
