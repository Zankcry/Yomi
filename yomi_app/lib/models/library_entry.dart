class LibraryEntry {
  final int novelId;
  final int lastChapterRead;
  final DateTime addedAt;

  LibraryEntry({
    required this.novelId,
    required this.lastChapterRead,
    required this.addedAt,
  });

  factory LibraryEntry.fromJson(Map<String, dynamic> json) {
    return LibraryEntry(
      novelId: json['novel_id'] is int
          ? json['novel_id']
          : int.parse(json['novel_id'].toString()),
      lastChapterRead: json['last_chapter_read'] is int
          ? json['last_chapter_read']
          : int.tryParse(json['last_chapter_read']?.toString() ?? '1') ?? 1,
      addedAt: json['added_at'] != null
          ? DateTime.tryParse(json['added_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
