class Chapter {
  final int chapterNumber;
  final String title;
  final String content;

  Chapter({
    required this.chapterNumber,
    required this.title,
    required this.content,
  });

  factory Chapter.fromFirestore(Map<String, dynamic> data) {
    return Chapter(
      chapterNumber: data['chapterNumber'] ?? 0,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chapterNumber': chapterNumber,
      'title': title,
      'content': content,
    };
  }
}
