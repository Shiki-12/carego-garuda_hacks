import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _user;
  int _balance = 0;
  List<dynamic> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await ApiService.me();
      final balance = await ApiService.getBalance(user.id);
      final recs = await ApiService.getRecommendations();
      
      setState(() {
        _user = user;
        _balance = balance;
        _recommendations = recs;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF0D9488))));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CareGo', style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () async {
              await ApiService.logout();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, ${_user?.name ?? 'User'}!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Saldo Wallet', style: TextStyle(color: Colors.white)),
                  Text('Rp $_balance', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Layanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildServiceIcon(Icons.local_hospital, 'Ambulance'),
                _buildServiceIcon(Icons.person, 'Perawat'),
                _buildServiceIcon(Icons.medical_services, 'Alat Medis'),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Rekomendasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_recommendations.isEmpty)
              const Text('Tidak ada rekomendasi saat ini.')
            else
              ..._recommendations.map((rec) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text(rec['title']),
                  subtitle: Text(rec['description']),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceIcon(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: const Color(0xFF0D9488).withOpacity(0.1),
          child: Icon(icon, size: 30, color: const Color(0xFF0D9488)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
