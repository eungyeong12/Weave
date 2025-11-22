import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'add_image_button.dart';
import 'image_item.dart';
import 'existing_image_item.dart';

class ImageListSection extends StatelessWidget {
  final List<XFile> images;
  final List<String> existingImageUrls; // 수정 모드일 때 기존 이미지 URL
  final VoidCallback onAddImage;
  final Function(int) onRemoveImage;
  final Function(int)? onRemoveExistingImage; // 기존 이미지 삭제 콜백

  const ImageListSection({
    super.key,
    required this.images,
    this.existingImageUrls = const [],
    required this.onAddImage,
    required this.onRemoveImage,
    this.onRemoveExistingImage,
  });

  @override
  Widget build(BuildContext context) {
    const double imageWidth = 80;
    const double imageHeight = 120; // 2:3 비율

    final totalItems =
        existingImageUrls.length + images.length + 1; // 기존 이미지 + 새 이미지 + 추가 버튼

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: imageHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: totalItems,
          itemBuilder: (context, index) {
            // 기존 이미지 URL들
            if (index < existingImageUrls.length) {
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
                child: ExistingImageItem(
                  imageUrl: existingImageUrls[index],
                  width: imageWidth,
                  height: imageHeight,
                  onRemove: onRemoveExistingImage != null
                      ? () => onRemoveExistingImage!(index)
                      : null,
                ),
              );
            }
            // 새로 추가한 이미지들
            final newImageIndex = index - existingImageUrls.length;
            if (newImageIndex < images.length) {
              return Padding(
                padding: EdgeInsets.only(
                  left: (index == 0 && existingImageUrls.isEmpty) ? 0 : 8,
                ),
                child: ImageItem(
                  imageFile: images[newImageIndex],
                  width: imageWidth,
                  height: imageHeight,
                  onRemove: () => onRemoveImage(newImageIndex),
                ),
              );
            }
            // 사진 추가 버튼
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: AddImageButton(
                onTap: onAddImage,
                width: imageWidth,
                height: imageHeight,
              ),
            );
          },
        ),
      ),
    );
  }
}
