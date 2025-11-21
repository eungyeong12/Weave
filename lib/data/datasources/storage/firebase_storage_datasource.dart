import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class FirebaseStorageDataSource {
  final FirebaseStorage _storage;

  FirebaseStorageDataSource(this._storage);

  Future<String> uploadImage({
    required String userId,
    required String dateId,
    required int imageIndex,
    required XFile imageFile,
  }) async {
    try {
      final fileName = '${userId}_${dateId}_$imageIndex.jpg';
      final ref = _storage.ref().child('diaries/$userId/$dateId/$fileName');

      UploadTask uploadTask;
      if (kIsWeb) {
        // Web: Uint8List로 업로드
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // iOS/Android: File로 업로드
        uploadTask = ref.putFile(
          File(imageFile.path),
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  Future<List<String>> uploadImages({
    required String userId,
    required String dateId,
    required List<XFile> imageFiles,
  }) async {
    final List<String> imageUrls = [];

    for (int i = 0; i < imageFiles.length; i++) {
      final url = await uploadImage(
        userId: userId,
        dateId: dateId,
        imageIndex: i,
        imageFile: imageFiles[i],
      );
      imageUrls.add(url);
    }

    return imageUrls;
  }
}
