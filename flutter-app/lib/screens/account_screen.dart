import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_screen.dart';
import 'wallet_screen.dart';
import 'orders_screen.dart';
import 'notifications_screen.dart';
import 'help_center_screen.dart';
import 'about_screen.dart';

class AccountScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;

  const AccountScreen({super.key, required this.user, required this.onLogout});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late Map<String, dynamic> _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _loadLocalUser();
  }

  Future<void> _loadLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('auth_user') ?? prefs.getString('user');
    if (userJson != null) {
      if (mounted) {
        setState(() {
          _user = jsonDecode(userJson);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = _user['photo_url'] as String?;
    ImageProvider? imageProvider;
    
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('data:image')) {
        imageProvider = MemoryImage(base64Decode(photoUrl.split(',')[1]));
      } else {
        imageProvider = NetworkImage(photoUrl);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                        image: imageProvider != null ? DecorationImage(image: imageProvider, fit: BoxFit.cover) : null,
                      ),
                      child: imageProvider == null ? Center(
                        child: Text(
                          (_user['name'] as String? ?? 'U')[0].toUpperCase(),
                          style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ) : null,
                    ),
                    const SizedBox(height: 12),
                    Text(_user['name'] ?? 'User',
                        style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(_user['email'] ?? '',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (_user['role'] as String? ?? 'patient').toUpperCase(),
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Menu items
              _menuGroup([
                _MenuItem(Icons.person_outline, 'Profil Saya', () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(user: _user)));
                  _loadLocalUser(); // Reload after returning
                }),
                _MenuItem(Icons.credit_card, 'Saldo & Pembayaran', () {
                  final int userId = _user['id'] is int ? _user['id'] : int.tryParse(_user['id']?.toString() ?? '0') ?? 0;
                  Navigator.push(context, MaterialPageRoute(builder: (_) => WalletScreen(userId: userId)));
                }),
                _MenuItem(Icons.receipt_long_outlined, 'Riwayat Pesanan', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
                }),
              ]),
              const SizedBox(height: 12),
              _menuGroup([
                _MenuItem(Icons.notifications_outlined, 'Notifikasi', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                }),
                _MenuItem(Icons.help_outline, 'Pusat Bantuan', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterScreen()));
                }),
                _MenuItem(Icons.info_outline, 'Tentang Aplikasi', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
                }),
              ]),
              const SizedBox(height: 12),
              _menuGroup([
                _MenuItem(Icons.logout, 'Keluar', widget.onLogout, isDestructive: true),
              ]),
              const SizedBox(height: 40),
              Text('CAREGO v1.0.0',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: Colors.grey.shade400)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuGroup(List<_MenuItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon,
                    color: item.isDestructive
                        ? const Color(0xFFEF4444)
                        : Colors.grey.shade600,
                    size: 22),
                title: Text(item.label,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: item.isDestructive
                            ? const Color(0xFFEF4444)
                            : Colors.grey.shade800)),
                trailing: item.isDestructive
                    ? null
                    : Icon(Icons.chevron_right,
                        size: 18, color: Colors.grey.shade400),
                onTap: item.onTap,
              ),
              if (i < items.length - 1)
                Divider(
                    height: 1,
                    indent: 56,
                    color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  _MenuItem(this.icon, this.label, this.onTap, {this.isDestructive = false});
}
