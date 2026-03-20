import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/novel.dart';
import '../models/chapter.dart';
import '../models/library_entry.dart';

class ApiService {
  // Change this to your XAMPP server address
  // Use 10.0.2.2 for Android emulator, localhost for web/desktop
  static const String baseUrl = 'http://localhost/yomi_api/api.php';

  // ─── Auth ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200 || data['error'] != null) {
      throw Exception(data['error'] ?? 'Registration failed');
    }
    return data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200 || data['error'] != null) {
      throw Exception(data['error'] ?? 'Login failed');
    }
    return data;
  }

  // ─── Novels ────────────────────────────────────────────────────────────

  Future<List<Novel>> getAllNovels() async {
    final response = await http.get(Uri.parse('$baseUrl?action=get_novels'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load novels');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Novel.fromJson(json)).toList();
  }

  Future<Novel> getNovel(int novelId) async {
    final response = await http.get(Uri.parse('$baseUrl?action=get_novel&id=$novelId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load novel');
    }
    final data = jsonDecode(response.body);
    return Novel.fromJson(data);
  }

  Future<List<Chapter>> getChapters(int novelId) async {
    final response = await http.get(Uri.parse('$baseUrl?action=get_chapters&novel_id=$novelId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load chapters');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Chapter.fromJson(json)).toList();
  }

  // ─── Library ───────────────────────────────────────────────────────────

  Future<List<LibraryEntry>> getUserLibrary(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl?action=get_library&user_id=$userId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load library');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => LibraryEntry.fromJson(json)).toList();
  }

  Future<void> addToLibrary(int userId, int novelId) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=add_to_library'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'novel_id': novelId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add to library');
    }
  }

  Future<void> removeFromLibrary(int userId, int novelId) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=remove_from_library'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'novel_id': novelId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to remove from library');
    }
  }

  Future<void> updateProgress(int userId, int novelId, int chapter) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=update_progress'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'novel_id': novelId, 'chapter': chapter}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update progress');
    }
  }
}
