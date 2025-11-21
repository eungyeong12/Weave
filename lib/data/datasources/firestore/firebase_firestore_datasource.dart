import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weave/data/models/diary/diary_dto.dart';

class FirebaseFirestoreDatasource {
  final FirebaseFirestore _firestore;

  FirebaseFirestoreDatasource(this._firestore);

  Future<DiaryDto> saveDailyDiary({
    required String userId,
    required DateTime date,
    required String content,
    required List<String> imageUrls,
  }) async {
    try {
      final now = DateTime.now();

      final diaryData = {
        'userId': userId,
        'date': Timestamp.fromDate(date),
        'content': content,
        'imageUrls': imageUrls,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      // 사용자별 일기 컬렉션에 저장
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('diaries')
          .add(diaryData);

      // 저장된 문서를 다시 읽어서 반환
      final doc = await docRef.get();
      final data = doc.data();
      if (data == null) {
        throw Exception('저장된 문서 데이터를 읽을 수 없습니다.');
      }
      return DiaryDto.fromFirestore(data, doc.id);
    } catch (e) {
      throw Exception('일기 저장 실패: $e');
    }
  }
}
