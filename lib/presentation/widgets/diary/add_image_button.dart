import 'package:flutter/material.dart';

class AddImageButton extends StatelessWidget {
  final VoidCallback onTap;
  final double width;
  final double height;

  const AddImageButton({
    super.key,
    required this.onTap,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.add_photo_alternate,
            size: 32,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
