import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  // Use http://10.0.2.2:4000 for local Android emulator
  static const String baseUrl = 'http://10.0.2.2:4000';
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // --- Auth Service ---

  static Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
      await setToken(authResponse.token);
      return authResponse;
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Login failed');
    }
  }

  static Future<User> me() async {
    final token = await getToken();
    if (token == null) throw Exception('No session');
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/me'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );
    
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      await clearToken();
      throw Exception('Session expired');
    }
  }
  
  static Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );
      await clearToken();
    }
  }

  // --- User Service ---
  static Future<int> getBalance(int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/balance'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['balance'];
    }
    throw Exception('Failed to get balance');
  }

  static Future<bool> updateProfile(int userId, {String? phone, String? photoBase64}) async {
    final Map<String, dynamic> body = {'userId': userId};
    if (phone != null) body['phone'] = phone;
    if (photoBase64 != null) body['photoBase64'] = photoBase64;

    final response = await http.post(
      Uri.parse('$baseUrl/user/profile/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return response.statusCode == 200;
  }

  // --- Ambulance Service ---
  static Future<List<dynamic>> getRecommendations() async {
    final response = await http.get(Uri.parse('$baseUrl/ambulance/recommendations'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Failed to get recommendations');
  }

  static Future<Map<String, dynamic>> bookAmbulance(int userId, int providerId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ambulance/book'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'providerId': providerId}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Booking failed');
  }
}

