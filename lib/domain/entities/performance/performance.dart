class Performance {
  final String title;
  final String? venue;
  final String? startDate;
  final String? endDate;
  final String? posterUrl;
  final String? genre;
  final String? cast;
  final String? runtime;
  final String? ageRating;
  final String? id;

  const Performance({
    required this.title,
    this.venue,
    this.startDate,
    this.endDate,
    this.posterUrl,
    this.genre,
    this.cast,
    this.runtime,
    this.ageRating,
    this.id,
  });
}
