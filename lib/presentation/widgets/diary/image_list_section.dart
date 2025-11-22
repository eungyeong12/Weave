import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'add_image_button.dart';
import 'image_item.dart';

class ImageListSection extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback onAddImage;
  final Function(int) onRemoveImage;

  const ImageListSection({
    super.key,
    required this.images,
    required this.onAddImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    const double imageWidth = 80;
    const double imageHeight = 120; // 2:3 비율

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: imageHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: images.length + 1, // 사진들 + 추가 버튼
          itemBuilder: (context, index) {
            if (index == images.length) {
              // 사진 추가 버튼
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: AddImageButton(
                  onTap: onAddImage,
                  width: imageWidth,
                  height: imageHeight,
                ),
              );
            }
            // 사진 아이템
            return Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
              child: ImageItem(
                imageFile: images[index],
                width: imageWidth,
                height: imageHeight,
                onRemove: () => onRemoveImage(index),
              ),
            );
          },
        ),
      ),
    );
  }
}
