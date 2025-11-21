import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weave/data/models/book/book_dto.dart';

class NaverBookDataSource {
  static String get _clientId => dotenv.env['NAVER_CLIENT_ID'] ?? '';
  static String get _clientSecret => dotenv.env['NAVER_CLIENT_SECRET'] ?? '';
  static const String _baseUrl =
      'https://openapi.naver.com/v1/search/book.json';

  Future<List<BookDto>> searchBooks({
    required String query,
    int start = 1,
    int display = 10,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'query': query,
        'start': start.toString(),
        'display': display.toString(),
        'sort': 'sim', // 정확도순 정렬
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'X-Naver-Client-Id': _clientId,
        'X-Naver-Client-Secret': _clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> items = jsonData['items'] ?? [];
      return items.map((item) => BookDto.fromJson(item)).toList();
    } else {
      throw Exception('도서 검색 실패: ${response.statusCode}');
    }
  }
}
