import 'package:flutter/material.dart';

class SearchTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final String hintText;

  const SearchTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onClear,
    this.hintText = '검색어를 입력하세요',
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: SizedBox(
        height: 36,
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          style: const TextStyle(fontSize: 14),
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(fontSize: 14),
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF111111),
              size: 20,
            ),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: Color(0xFF111111),
                      size: 20,
                    ),
                    onPressed: widget.onClear,
                  )
                : null,
            filled: true,
            fillColor: Color(0xFFF1F1F1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0,
            ),
          ),
          onChanged: (value) {
            setState(() {});
          },
          onSubmitted: widget.onSubmitted,
          textInputAction: TextInputAction.search,
        ),
      ),
    );
  }
}
