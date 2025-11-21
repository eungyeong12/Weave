class Diary {
  final String? id;
  final String userId;
  final DateTime date;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Diary({
    this.id,
    required this.userId,
    required this.date,
    required this.content,
    required this.imageUrls,
    required this.createdAt,
    required this.updatedAt,
  });

  Diary copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? content,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Diary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
