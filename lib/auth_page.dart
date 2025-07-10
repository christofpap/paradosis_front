import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl;

  AuthService({required this.baseUrl});

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Optional: store tokens
      final role = data['role']; // e.g. "Courier"

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userRole', role);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> register(String username, String password, String role) async {
    final url = Uri.parse('$baseUrl/auth/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'role': role,
        'gdprConsent': DateTime.now().toUtc().toIso8601String()
      }),
    );

    return response.statusCode == 200;
  }
}
