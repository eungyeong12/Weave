import 'package:flutter/material.dart';

class DiaryTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final double minHeight;
  final String hintText;

  const DiaryTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onChanged,
    this.minHeight = 540,
    this.hintText = '오늘 하루를 기록해보세요',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F9F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          minLines: null,
          maxLines: null,
          expands: false,
          textAlignVertical: TextAlignVertical.top,
          style: const TextStyle(fontSize: 14),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.transparent,
            hoverColor: Colors.transparent,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }
}
