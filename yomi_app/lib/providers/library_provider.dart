import 'package:flutter/material.dart';
import '../models/library_entry.dart';
import '../services/api_service.dart';

class LibraryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<LibraryEntry> _libraryEntries = [];
  bool _isLoading = false;

  List<LibraryEntry> get libraryEntries => _libraryEntries;
  bool get isLoading => _isLoading;

  Future<void> fetchLibrary(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _libraryEntries = await _apiService.getUserLibrary(userId);
    } catch (e) {
      print('Error fetching library: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToLibrary(int userId, int novelId) async {
    await _apiService.addToLibrary(userId, novelId);
    await fetchLibrary(userId);
  }

  Future<void> removeFromLibrary(int userId, int novelId) async {
    await _apiService.removeFromLibrary(userId, novelId);
    await fetchLibrary(userId);
  }

  Future<void> updateProgress(int userId, int novelId, int chapter) async {
    await _apiService.updateProgress(userId, novelId, chapter);
    // Locally update to avoid full refetch if possible, or just refetch
    final index = _libraryEntries.indexWhere((e) => e.novelId == novelId);
    if (index != -1) {
      _libraryEntries[index] = LibraryEntry(
        novelId: novelId,
        lastChapterRead: chapter,
        addedAt: _libraryEntries[index].addedAt,
      );
      notifyListeners();
    }
  }

  bool isInLibrary(int novelId) {
    return _libraryEntries.any((entry) => entry.novelId == novelId);
  }

  int getProgress(int novelId) {
    try {
      return _libraryEntries.firstWhere((entry) => entry.novelId == novelId).lastChapterRead;
    } catch (_) {
      return 1;
    }
  }
}
