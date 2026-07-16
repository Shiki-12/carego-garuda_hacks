import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/api_service.dart';

void main() {
  runApp(const CareGoApp());
}

class CareGoApp extends StatelessWidget {
  const CareGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareGo',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D9488),
        textTheme: GoogleFonts.interTextTheme(),
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
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      await ApiService.me();
      setState(() => _isAuthenticated = true);
    } catch (e) {
      setState(() => _isAuthenticated = false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF0D9488))),
      );
    }
    
    if (_isAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Home Screen (Stub)')),
      );
    }
    
    return const Scaffold(
      body: Center(child: Text('Login Screen (Stub)')),
    );
  }
}
