import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserData {
  final int id;
  final String email;

  UserData({required this.id, required this.email});
}

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  UserData? _user;
  bool _isLoading = false;

  UserData? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      final data = await _apiService.login(email, password);
      _user = UserData(
        id: data['user_id'],
        email: data['email'],
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password) async {
    _setLoading(true);
    try {
      final data = await _apiService.register(email, password);
      _user = UserData(
        id: data['user_id'],
        email: data['email'],
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
