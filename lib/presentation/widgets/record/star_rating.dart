import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  final double rating;
  final ValueChanged<double>? onRatingChanged;
  final double starSize;
  final Color? color;

  const StarRating({
    super.key,
    this.rating = 0.0,
    this.onRatingChanged,
    this.starSize = 20.0,
    this.color,
  });

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
  }

  @override
  void didUpdateWidget(StarRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rating != oldWidget.rating) {
      _rating = widget.rating;
    }
  }

  void _updateRating(double newRating) {
    setState(() {
      _rating = newRating;
    });
    widget.onRatingChanged?.call(newRating);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Colors.black;

    return GestureDetector(
      onPanUpdate: (details) {
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box == null) return;

        final localPosition = box.globalToLocal(details.globalPosition);
        final starWidth = widget.starSize + 2.0; // 별 크기 + 패딩
        final starIndexFromPosition =
            (localPosition.dx / starWidth).floor() + 1;

        if (starIndexFromPosition >= 1 && starIndexFromPosition <= 5) {
          _updateRating(starIndexFromPosition.toDouble());
        }
      },
      onPanEnd: (_) {
        // 드래그 종료 시 아무 작업도 하지 않음
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final starIndex = index + 1;
          return GestureDetector(
            onTap: widget.onRatingChanged != null
                ? () => _updateRating(starIndex.toDouble())
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: Icon(
                _rating >= starIndex
                    ? Icons.star
                    : _rating > starIndex - 1
                    ? Icons.star_half
                    : Icons.star_border,
                size: widget.starSize,
                color: _rating >= starIndex
                    ? color
                    : _rating > starIndex - 1
                    ? color
                    : Colors.grey.shade300,
              ),
            ),
          );
        }),
      ),
    );
  }
}
