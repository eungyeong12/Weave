import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:weave/data/models/movie/movie_dto.dart';
import 'package:flutter/foundation.dart';

class TmdbMovieDataSource {
  TmdbMovieDataSource();

  Future<List<MovieDto>> searchMovies({
    required String query,
    int page = 1,
  }) async {
    try {
      debugPrint('🔍 Firebase HTTP Functions 호출 시작: searchMovies');
      debugPrint('📝 검색어: $query, 페이지: $page');

      // Firebase 프로젝트 정보 가져오기
      final projectId = Firebase.app().options.projectId;

      // HTTP Functions URL 구성
      final functionUrl =
          'https://us-central1-$projectId.cloudfunctions.net/searchMoviesHttp';

      debugPrint('📞 Functions URL: $functionUrl');

      // HTTP GET 요청
      final uri = Uri.parse(
        functionUrl,
      ).replace(queryParameters: {'query': query, 'page': page.toString()});

      debugPrint('📤 HTTP 요청 전송 중...');
      final response = await http.get(uri);

      debugPrint('✅ HTTP 응답 받음: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('영화 검색 실패: HTTP ${response.statusCode}');
      }

      // JSON 파싱
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseData['success'] == true && responseData['data'] != null) {
        final jsonData = responseData['data'] as Map<String, dynamic>;
        final List<dynamic> results = jsonData['results'] ?? [];
        return results.map((item) {
          final itemMap = item is Map
              ? item as Map<String, dynamic>
              : jsonDecode(item.toString()) as Map<String, dynamic>;
          return MovieDto.fromJson(itemMap);
        }).toList();
      } else {
        throw Exception('영화 검색 실패: 응답 데이터가 올바르지 않습니다.');
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
      throw Exception('영화 검색 중 오류가 발생했습니다: $e');
    }
  }
}
