import 'package:weave/domain/entities/performance/performance.dart';

class PerformanceDto extends Performance {
  const PerformanceDto({
    required super.title,
    super.venue,
    super.startDate,
    super.endDate,
    super.posterUrl,
    super.genre,
    super.cast,
    super.runtime,
    super.ageRating,
    super.id,
  });

  factory PerformanceDto.fromJson(Map<String, dynamic> json) {
    // 포스터 URL 처리
    String? posterUrl;
    if (json['poster'] != null && json['poster'].toString().isNotEmpty) {
      final path = json['poster'].toString();
      if (path.startsWith('http')) {
        posterUrl = path;
      } else {
        posterUrl = 'http://kopis.or.kr$path';
      }
    }

    return PerformanceDto(
      title: json['prfnm'] ?? json['prfName'] ?? '',
      venue: json['fcltynm'] ?? json['fcltyName'],
      startDate: json['prfpdfrom'] ?? json['prfpdFrom'],
      endDate: json['prfpdto'] ?? json['prfpdTo'],
      posterUrl: posterUrl,
      genre: json['genrenm'] ?? json['genreName'],
      cast: json['prfcast'] ?? json['prfcast'],
      runtime: json['prfruntime'] ?? json['prfruntime'],
      ageRating: json['prfage'] ?? json['prfage'],
      id: json['mt20id'] ?? json['mt20Id'],
    );
  }
}
