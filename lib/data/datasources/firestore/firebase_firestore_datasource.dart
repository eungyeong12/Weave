import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weave/data/models/diary/diary_dto.dart';
import 'package:weave/data/models/record/record_dto.dart';

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

  Future<DiaryDto> updateDailyDiary({
    required String diaryId,
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
        'updatedAt': Timestamp.fromDate(now),
      };

      // 기존 문서 업데이트 (createdAt은 유지)
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('diaries')
          .doc(diaryId)
          .update(diaryData);

      // 업데이트된 문서를 다시 읽어서 반환
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('diaries')
          .doc(diaryId)
          .get();

      final data = doc.data();
      if (data == null) {
        throw Exception('업데이트된 문서 데이터를 읽을 수 없습니다.');
      }
      return DiaryDto.fromFirestore(data, doc.id);
    } catch (e) {
      throw Exception('일기 업데이트 실패: $e');
    }
  }

  Future<RecordDto> saveRecord({
    required String userId,
    required String type,
    required DateTime date,
    required String title,
    String? imageUrl,
    required String content,
    required double rating,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final now = DateTime.now();

      final recordData = {
        'userId': userId,
        'type': type,
        'date': Timestamp.fromDate(date),
        'title': title,
        'imageUrl': imageUrl,
        'content': content,
        'rating': rating,
        'metadata': metadata,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      // 사용자별 기록 컬렉션에 저장
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('records')
          .add(recordData);

      // 저장된 문서를 다시 읽어서 반환
      final doc = await docRef.get();
      final data = doc.data();
      if (data == null) {
        throw Exception('저장된 문서 데이터를 읽을 수 없습니다.');
      }
      return RecordDto.fromFirestore(data, doc.id);
    } catch (e) {
      throw Exception('기록 저장 실패: $e');
    }
  }

  Future<RecordDto> updateRecord({
    required String recordId,
    required String userId,
    required String type,
    required DateTime date,
    required String title,
    String? imageUrl,
    required String content,
    required double rating,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final now = DateTime.now();

      final recordData = {
        'userId': userId,
        'type': type,
        'date': Timestamp.fromDate(date),
        'title': title,
        'imageUrl': imageUrl,
        'content': content,
        'rating': rating,
        'metadata': metadata,
        'updatedAt': Timestamp.fromDate(now),
      };

      // 기존 문서 업데이트 (createdAt은 유지)
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('records')
          .doc(recordId)
          .update(recordData);

      // 업데이트된 문서를 다시 읽어서 반환
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('records')
          .doc(recordId)
          .get();

      final data = doc.data();
      if (data == null) {
        throw Exception('업데이트된 문서 데이터를 읽을 수 없습니다.');
      }
      return RecordDto.fromFirestore(data, doc.id);
    } catch (e) {
      throw Exception('기록 업데이트 실패: $e');
    }
  }

  Future<List<RecordDto>> getRecords({
    required String userId,
    int? year,
    int? month,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('records');

      // 년도와 월이 지정된 경우 날짜 범위로 필터링
      if (year != null && month != null) {
        final startDate = DateTime(year, month, 1);
        final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
        query = query
            .where(
              'date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
            )
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final querySnapshot = await query.orderBy('date', descending: true).get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return RecordDto.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('기록 조회 실패: $e');
    }
  }

  Future<List<DiaryDto>> getDiaries({
    required String userId,
    int? year,
    int? month,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('diaries');

      // 년도와 월이 지정된 경우 날짜 범위로 필터링
      if (year != null && month != null) {
        final startDate = DateTime(year, month, 1);
        final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
        query = query
            .where(
              'date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
            )
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final querySnapshot = await query.orderBy('date', descending: true).get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DiaryDto.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('일기 조회 실패: $e');
    }
  }
}
