import 'package:flutter/material.dart';

class DetailScreenAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final DateTime date;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DetailScreenAppBar({
    super.key,
    required this.date,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  String _formatDate(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
      title: Text(
        _formatDate(date),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Theme(
          data: Theme.of(
            context,
          ).copyWith(splashFactory: InkRipple.splashFactory),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            color: Colors.green.shade200,
            splashRadius: 20,
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'edit',
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('수정'),
                    ),
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('삭제'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
