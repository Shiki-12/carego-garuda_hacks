import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_navigation.dart';
import 'services/api_service.dart';

void main() {
  runApp(const CaregoApp());
}

class CaregoApp extends StatelessWidget {
  const CaregoApp({super.key});

  static const String appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CAREGO - Healthcare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0D9488),
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  String? _token;
  Map<String, dynamic>? _user;
  bool _showRegister = false;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userJson = prefs.getString('auth_user');

    if (token != null && userJson != null) {
      setState(() {
        _token = token;
        _user = jsonDecode(userJson);
      });
    }
    setState(() => _loading = false);

    // Check for app updates after UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdate();
    });
  }

  Future<void> _checkForUpdate() async {
    try {
      final versionInfo = await ApiService.checkAppVersion();
      if (versionInfo.isEmpty) return;

      final latestVersion = versionInfo['latestVersion'] as String? ?? '';
      final downloadUrl = versionInfo['downloadUrl'] as String? ?? '';
      final releaseNotes = versionInfo['releaseNotes'] as String? ?? '';
      final forceUpdate = versionInfo['forceUpdate'] as bool? ?? false;

      if (latestVersion.isNotEmpty && latestVersion != CaregoApp.appVersion && downloadUrl.isNotEmpty) {
        if (!mounted) return;
        _showUpdateDialog(latestVersion, downloadUrl, releaseNotes, forceUpdate);
      }
    } catch (_) {}
  }

  void _showUpdateDialog(String version, String url, String notes, bool force) {
    showDialog(
      context: context,
      barrierDismissible: !force,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.system_update, color: Color(0xFF0D9488), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Update Tersedia!',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('v${CaregoApp.appVersion} → v$version',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0D9488))),
            ),
            const SizedBox(height: 12),
            Text(notes, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600, height: 1.4)),
            if (force) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, size: 16, color: Colors.red.shade400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Update ini wajib untuk melanjutkan.',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.red.shade600, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!force)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Nanti Saja', style: GoogleFonts.inter(color: Colors.grey)),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openDownloadUrl(url);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Download Update', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _openDownloadUrl(String url) async {
    // Use a simple approach: show a snackbar with the URL
    // In production, use url_launcher package
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download APK terbaru di:\n$url', style: GoogleFonts.inter(fontSize: 12)),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
    }
  }

  Future<void> _handleLogin(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('auth_user', jsonEncode(user));
    setState(() {
      _token = token;
      _user = user;
    });
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
    setState(() {
      _token = null;
      _user = null;
      _showRegister = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0D9488)),
        ),
      );
    }

    // Authenticated: show main app
    if (_token != null && _user != null) {
      return MainNavigation(
        token: _token!,
        user: _user!,
        onLogout: _handleLogout,
      );
    }

    // Not authenticated: login or register
    if (_showRegister) {
      return RegisterScreen(
        onGoToLogin: () => setState(() => _showRegister = false),
        onLogin: _handleLogin,
      );
    }

    return LoginScreen(
      onGoToRegister: () => setState(() => _showRegister = true),
      onLogin: _handleLogin,
    );
  }
}
