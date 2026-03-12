class Novel {
  final String id;
  final String title;
  final String author;
  final String synopsis;
  final String coverUrl;
  final int totalChapters;
  final DateTime? createdAt;

  Novel({
    required this.id,
    required this.title,
    required this.author,
    required this.synopsis,
    required this.coverUrl,
    required this.totalChapters,
    this.createdAt,
  });

  factory Novel.fromFirestore(Map<String, dynamic> data, String id) {
    return Novel(
      id: id,
      title: data['title'] ?? '',
      author: data['author'] ?? 'Unknown',
      synopsis: data['synopsis'] ?? '',
      coverUrl: data['coverUrl'] ?? '',
      totalChapters: data['totalChapters'] ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is String
              ? DateTime.parse(data['createdAt'])
              : (data['createdAt'] as dynamic).toDate())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'synopsis': synopsis,
      'coverUrl': coverUrl,
      'totalChapters': totalChapters,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }
}
