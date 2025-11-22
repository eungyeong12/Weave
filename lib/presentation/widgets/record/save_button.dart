import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback onSave;
  final bool isContentEmpty;
  final bool isLoading;

  const SaveButton({
    super.key,
    required this.onSave,
    required this.isContentEmpty,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = isLoading || isContentEmpty;

    return TextButton(
      onPressed: isDisabled ? null : onSave,
      style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
      child: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          : Text(
              '저장',
              style: TextStyle(
                color: isContentEmpty ? Colors.grey : Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
