import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weave/di/injector.dart';

class SaveButton extends ConsumerWidget {
  final VoidCallback onSave;
  final bool isContentEmpty;

  const SaveButton({
    super.key,
    required this.onSave,
    required this.isContentEmpty,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyDiaryWriteViewModelProvider);
    final isDisabled = state.isLoading || isContentEmpty;

    return TextButton(
      onPressed: isDisabled ? null : onSave,
      style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
      child: state.isLoading
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
