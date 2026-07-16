import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Encore Cloud (managed database + hosting)
  // Local dev: http://10.0.2.2:4000 (Android emulator) or http://127.0.0.1:4000
  static const String baseUrl =
      'https://staging-testapp-8y92.encr.app';

  // ─── APP VERSION ─────────────────────────────────────────

  /// Check latest app version
  static Future<Map<String, dynamic>> checkAppVersion() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/app/version'),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode != 200) return {};
      return jsonDecode(res.body);
    } catch (_) {
      return {};
    }
  }

  // ─── AUTH ───────────────────────────────────────────────

  /// Login with email + password
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'CaregoApp/1.0',
        'Connection': 'keep-alive',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Login gagal');
    }
    return jsonDecode(res.body);
  }

  /// Send OTP for login
  static Future<Map<String, dynamic>> sendOtp(
      String identifier, String method) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/send-otp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'CaregoApp/1.0',
        'Connection': 'keep-alive',
      },
      body: jsonEncode({'identifier': identifier, 'method': method}),
    );
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Gagal mengirim OTP');
    }
    return jsonDecode(res.body);
  }

  /// Verify OTP for login
  static Future<Map<String, dynamic>> verifyOtp(
      String identifier, String code) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'CaregoApp/1.0',
        'Connection': 'keep-alive',
      },
      body: jsonEncode({'identifier': identifier, 'code': code}),
    );
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Kode OTP salah');
    }
    return jsonDecode(res.body);
  }

  /// Register – Step 1: Send OTP
  static Future<Map<String, dynamic>> registerSendOtp(
      String email, String phone, String method) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register-send-otp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'CaregoApp/1.0',
        'Connection': 'keep-alive',
      },
      body: jsonEncode({'email': email, 'phone': phone, 'method': method}),
    );
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Gagal mengirim OTP');
    }
    return jsonDecode(res.body);
  }

  /// Register – Step 2: Verify OTP & create account
  static Future<Map<String, dynamic>> registerVerifyOtp(
      String name,
      String email,
      String phone,
      String password,
      String code) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register-verify-otp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'CaregoApp/1.0',
        'Connection': 'keep-alive',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'code': code,
      }),
    );
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Registrasi gagal');
    }
    return jsonDecode(res.body);
  }

  /// Google OAuth (simulated)
  static Future<Map<String, dynamic>> googleAuth(
      String googleId, String email, String name) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/google'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'CaregoApp/1.0',
        'Connection': 'keep-alive',
      },
      body: jsonEncode({
        'googleId': googleId,
        'email': email,
        'name': name,
      }),
    );
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Google Auth gagal');
    }
    return jsonDecode(res.body);
  }

  // ─── USER ──────────────────────────────────────────────

  /// Get user wallet balance
  static Future<int> getBalance(int userId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/user/balance'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'CaregoApp/1.0',
        'Connection': 'keep-alive',
      },
      body: jsonEncode({'userId': userId}),
    );
    if (res.statusCode != 200) return 0;
    final body = jsonDecode(res.body);
    return body['balance'] as int? ?? 0;
  }

  /// Update Profile
  static Future<Map<String, dynamic>> updateProfile(
      int userId, {String? phone, String? photoBase64}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/user/profile/update'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'CaregoApp/1.0',
        'Connection': 'keep-alive',
      },
      body: jsonEncode({
        'userId': userId,
        if (phone != null) 'phone': phone,
        if (photoBase64 != null) 'photoBase64': photoBase64,
      }),
    );
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Gagal menyimpan profil');
    }
    return jsonDecode(res.body);
  }

  // ─── RECOMMENDATIONS ──────────────────────────────────

  /// Get all recommendations
  static Future<List<Map<String, dynamic>>> getRecommendations() async {
    final res = await http.get(
      Uri.parse('$baseUrl/ambulance/recommendations'),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode != 200) return [];
    final body = jsonDecode(res.body);
    final list = body['recommendations'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }
}
