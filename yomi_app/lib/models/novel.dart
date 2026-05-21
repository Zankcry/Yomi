class Novel {
  final int id;
  final String title;
  final String author;
  final String synopsis;
  final String? coverImage;
  final int totalChapters;
  final String? createdAt;

  Novel({
    required this.id,
    required this.title,
    required this.author,
    required this.synopsis,
    this.coverImage,
    required this.totalChapters,
    this.createdAt,
  });

  /// URL to load the cover image
  String get coverImageUrl =>
      coverImage != null && coverImage!.isNotEmpty
          ? './covers/$coverImage'
          : '';

  factory Novel.fromJson(Map<String, dynamic> json) {
    return Novel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      author: json['author'] ?? 'Unknown',
      synopsis: json['synopsis'] ?? '',
      coverImage: json['cover_image'],
      totalChapters: json['total_chapters'] is int
          ? json['total_chapters']
          : int.tryParse(json['total_chapters']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'],
    );
  }
}
