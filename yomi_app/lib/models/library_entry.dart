import 'package:cloud_firestore/cloud_firestore.dart';

class LibraryEntry {
  final String novelId;
  final int lastChapterRead;
  final DateTime addedAt;

  LibraryEntry({
    required this.novelId,
    required this.lastChapterRead,
    required this.addedAt,
  });

  factory LibraryEntry.fromFirestore(Map<String, dynamic> data) {
    return LibraryEntry(
      novelId: data['novelId'] ?? '',
      lastChapterRead: data['lastChapterRead'] ?? 1,
      addedAt: data['addedAt'] != null ? (data['addedAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'novelId': novelId,
      'lastChapterRead': lastChapterRead,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }
}
