import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:weave/data/models/book/book_dto.dart';
import 'package:flutter/foundation.dart';

class NaverBookDataSource {
  NaverBookDataSource();

  Future<List<BookDto>> searchBooks({
    required String query,
    int start = 1,
    int display = 10,
  }) async {
    try {
      debugPrint('🔍 Firebase HTTP Functions 호출 시작: searchBooks');
      debugPrint('📝 검색어: $query, 시작: $start, 표시: $display');

      // Firebase 프로젝트 정보 가져오기
      final projectId = Firebase.app().options.projectId;

      // HTTP Functions URL 구성
      // 기본 리전은 us-central1이지만, 배포된 리전을 확인해야 함
      final functionUrl =
          'https://us-central1-$projectId.cloudfunctions.net/searchBooksHttp';

      debugPrint('📞 Functions URL: $functionUrl');

      // HTTP POST 요청
      final uri = Uri.parse(functionUrl).replace(
        queryParameters: {
          'query': query,
          'start': start.toString(),
          'display': display.toString(),
        },
      );

      debugPrint('📤 HTTP 요청 전송 중...');
      final response = await http.get(uri);

      debugPrint('✅ HTTP 응답 받음: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('도서 검색 실패: HTTP ${response.statusCode}');
      }

      // JSON 파싱 (Int64 문제 없음)
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseData['success'] == true && responseData['data'] != null) {
        final jsonData = responseData['data'] as Map<String, dynamic>;

        // 문자열로 변환된 숫자를 다시 숫자로 변환
        final convertedData = _convertStringNumbers(jsonData);

        final List<dynamic> items = convertedData['items'] ?? [];
        return items.map((item) {
          final itemMap = item is Map
              ? _convertStringNumbers(item as Map<String, dynamic>)
              : item;
          return BookDto.fromJson(itemMap as Map<String, dynamic>);
        }).toList();
      } else {
        throw Exception('도서 검색 실패: 응답 데이터가 올바르지 않습니다.');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ 오류 발생: $e');
      debugPrint('📋 Stack trace: $stackTrace');

      if (e.toString().contains('ClientException') ||
          e.toString().contains('CORS')) {
        throw Exception(
          '웹에서는 Firebase Functions를 통해 호출해야 합니다. '
          'Functions가 배포되었는지 확인해주세요.',
        );
      }
      throw Exception('도서 검색 중 오류가 발생했습니다: $e');
    }
  }

  // 문자열로 변환된 숫자를 다시 숫자로 변환하는 헬퍼 함수
  Map<String, dynamic> _convertStringNumbers(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    for (final entry in map.entries) {
      final value = entry.value;
      if (value is Map) {
        result[entry.key] = _convertStringNumbers(
          value as Map<String, dynamic>,
        );
      } else if (value is List) {
        result[entry.key] = value.map((item) {
          if (item is Map) {
            return _convertStringNumbers(item as Map<String, dynamic>);
          }
          return item;
        }).toList();
      } else if (value is String) {
        // 숫자 문자열인지 확인하고 변환
        final numValue = int.tryParse(value);
        if (numValue != null) {
          result[entry.key] = numValue;
        } else {
          final doubleValue = double.tryParse(value);
          if (doubleValue != null) {
            result[entry.key] = doubleValue;
          } else {
            result[entry.key] = value;
          }
        }
      } else {
        result[entry.key] = value;
      }
    }
    return result;
  }
}
