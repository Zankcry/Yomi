import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/novel.dart';
import '../models/chapter.dart';
import '../models/library_entry.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 📖 Get all novels for Browse screen
  Stream<List<Novel>> getAllNovels() {
    return _db.collection('novels').orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Novel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // 📖 Get a single novel
  Future<Novel> getNovel(String novelId) async {
    var doc = await _db.collection('novels').doc(novelId).get();
    return Novel.fromFirestore(doc.data()!, doc.id);
  }

  // 📖 Get chapters for a novel
  Stream<List<Chapter>> getChapters(String novelId) {
    return _db
        .collection('novels')
        .doc(novelId)
        .collection('chapters')
        .orderBy('chapterNumber')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Chapter.fromFirestore(doc.data()))
              .toList(),
        );
  }

  // 📚 CRUD - Add to Library (CREATE)
  Future<void> addToLibrary(String uid, String novelId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('library')
        .doc(novelId)
        .set(LibraryEntry(
          novelId: novelId,
          lastChapterRead: 1,
          addedAt: DateTime.now(),
        ).toMap());
  }

  // 📚 CRUD - Get Library (READ)
  Stream<List<LibraryEntry>> getUserLibrary(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('library')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LibraryEntry.fromFirestore(doc.data()))
              .toList(),
        );
  }

  // 📚 CRUD - Update Progress (UPDATE)
  Future<void> updateProgress(String uid, String novelId, int chapter) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('library')
        .doc(novelId)
        .update({'lastChapterRead': chapter});
  }

  // 📚 CRUD - Remove from Library (DELETE)
  Future<void> removeFromLibrary(String uid, String novelId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('library')
        .doc(novelId)
        .delete();
  }
}
