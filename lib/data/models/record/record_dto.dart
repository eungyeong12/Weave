import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weave/domain/entities/record/record.dart';

class RecordDto extends Record {
  const RecordDto({
    super.id,
    required super.userId,
    required super.type,
    required super.date,
    required super.title,
    super.imageUrl,
    required super.content,
    required super.rating,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
  });

  factory RecordDto.fromFirestore(Map<String, dynamic> data, String id) {
    return RecordDto(
      id: id,
      userId: data['userId'] as String,
      type: data['type'] as String,
      date: (data['date'] as Timestamp).toDate(),
      title: data['title'] as String,
      imageUrl: data['imageUrl'] as String?,
      content: data['content'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      metadata: data['metadata'] != null
          ? Map<String, dynamic>.from(data['metadata'] as Map)
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'date': Timestamp.fromDate(date),
      'title': title,
      'imageUrl': imageUrl,
      'content': content,
      'rating': rating,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
