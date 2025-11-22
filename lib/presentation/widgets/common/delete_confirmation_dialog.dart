import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final String message;
  final String confirmText;
  final Color confirmColor;

  const DeleteConfirmationDialog({
    super.key,
    required this.onConfirm,
    this.message = '정말 삭제하시겠습니까?',
    this.confirmText = '삭제',
    this.confirmColor = Colors.green,
  });

  static Future<void> show(
    BuildContext context,
    VoidCallback onConfirm, {
    String message = '정말 삭제하시겠습니까?',
    String confirmText = '삭제',
    Color confirmColor = Colors.green,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return DeleteConfirmationDialog(
          onConfirm: onConfirm,
          message: message,
          confirmText: confirmText,
          confirmColor: confirmColor,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      content: Text(
        message,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        SizedBox(
          width: 100,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('취소'),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: TextButton.styleFrom(
              foregroundColor: confirmColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(confirmText),
          ),
        ),
      ],
    );
  }
}
