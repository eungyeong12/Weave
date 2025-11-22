class Record {
  final String? id;
  final String userId;
  final String type; // 'book', 'movie', 'performance'
  final DateTime date;
  final String title;
  final String? imageUrl;
  final String content;
  final double rating;
  final Map<String, dynamic>? metadata; // 타입별 추가 정보
  final DateTime createdAt;
  final DateTime updatedAt;

  const Record({
    this.id,
    required this.userId,
    required this.type,
    required this.date,
    required this.title,
    this.imageUrl,
    required this.content,
    required this.rating,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  Record copyWith({
    String? id,
    String? userId,
    String? type,
    DateTime? date,
    String? title,
    String? imageUrl,
    String? content,
    double? rating,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Record(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      date: date ?? this.date,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      content: content ?? this.content,
      rating: rating ?? this.rating,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
