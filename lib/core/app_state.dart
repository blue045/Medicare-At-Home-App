import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'api_client.dart';

class AppState extends ChangeNotifier {
  AppState(this.api);

  final ApiClient api;
  UserProfile? user;
  bool restoring = true;

  bool get isLoggedIn => user != null && (api.token ?? '').isNotEmpty;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    api.token = prefs.getString('store_token');
    if (api.token != null && api.token!.isNotEmpty) {
      try {
        final data = await api.getJson('/api/store/auth/me');
        user = UserProfile.fromJson(data['user']);
      } catch (_) {
        await prefs.remove('store_token');
        api.token = null;
      }
    }
    restoring = false;
    notifyListeners();
  }

  Future<void> login({required String identifier, required String password}) async {
    final data = await api.postJson('/api/store/auth/login', {
      'identifier': identifier,
      'password': password,
    });
    await _saveSession(data);
  }

  Future<void> signup({
    required String fullName,
    required String age,
    required String email,
    required String phone,
    required String password,
  }) async {
    final data = await api.postJson('/api/store/auth/signup', {
      'fullName': fullName,
      'age': age,
      'email': email,
      'phone': phone,
      'password': password,
    });
    await _saveSession(data);
  }

  Future<void> refreshMe() async {
    final data = await api.getJson('/api/store/auth/me');
    user = UserProfile.fromJson(data['user']);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('store_token');
    api.token = null;
    user = null;
    notifyListeners();
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    final token = data['token']?.toString() ?? '';
    if (token.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('store_token', token);
    api.token = token;
    user = UserProfile.fromJson(data['user']);
    notifyListeners();
  }
}
