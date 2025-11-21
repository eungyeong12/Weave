import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weave/domain/entities/diary/diary.dart';

class DiaryDto extends Diary {
  const DiaryDto({
    super.id,
    required super.userId,
    required super.date,
    required super.content,
    required super.imageUrls,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DiaryDto.fromFirestore(Map<String, dynamic> data, String id) {
    return DiaryDto(
      id: id,
      userId: data['userId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      content: data['content'] as String? ?? '',
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
