import 'package:flutter/material.dart';
import '../models/library_entry.dart';
import '../services/firestore_service.dart';

class LibraryProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<LibraryEntry> _libraryEntries = [];
  bool _isLoading = false;

  List<LibraryEntry> get libraryEntries => _libraryEntries;
  bool get isLoading => _isLoading;

  void fetchLibrary(String uid) {
    _firestoreService.getUserLibrary(uid).listen((entries) {
      _libraryEntries = entries;
      notifyListeners();
    });
  }

  Future<void> addToLibrary(String uid, String novelId) async {
    await _firestoreService.addToLibrary(uid, novelId);
  }

  Future<void> removeFromLibrary(String uid, String novelId) async {
    await _firestoreService.removeFromLibrary(uid, novelId);
  }

  Future<void> updateProgress(String uid, String novelId, int chapter) async {
    await _firestoreService.updateProgress(uid, novelId, chapter);
  }

  bool isInLibrary(String novelId) {
    return _libraryEntries.any((entry) => entry.novelId == novelId);
  }

  int getProgress(String novelId) {
    try {
      return _libraryEntries.firstWhere((entry) => entry.novelId == novelId).lastChapterRead;
    } catch (_) {
      return 1;
    }
  }
}
