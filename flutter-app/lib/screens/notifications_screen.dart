import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text('Notifikasi', style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.notifications_off_outlined, color: Colors.grey, size: 40),
              ),
              const SizedBox(height: 20),
              Text('Belum Ada Notifikasi', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey.shade800)),
              const SizedBox(height: 8),
              Text('Semua pemberitahuan pesanan dan info \nakan muncul di sini.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}
