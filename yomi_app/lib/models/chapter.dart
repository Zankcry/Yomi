class Chapter {
  final int chapterNumber;
  final String title;
  final String content;

  Chapter({
    required this.chapterNumber,
    required this.title,
    required this.content,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterNumber: json['chapter_number'] is int
          ? json['chapter_number']
          : int.tryParse(json['chapter_number']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}
