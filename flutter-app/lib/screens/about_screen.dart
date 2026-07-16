import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text('Tentang Aplikasi', style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(color: const Color(0xFFF0FDFA), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFCCFBF1))),
                child: const Icon(Icons.favorite, color: Color(0xFF0D9488), size: 50),
              ),
              const SizedBox(height: 24),
              Text('CAREGO', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF0D9488))),
              const SizedBox(height: 8),
              Text('Versi 1.0.0', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500)),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text('Aplikasi penyedia layanan kesehatan terpadu. Carego hadir untuk mempermudah akses kesehatan darurat, sewa alat medis, dan caregiver kapanpun Anda butuhkan.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600, height: 1.5)),
              ),
              const SizedBox(height: 100),
              Text('© 2026 PT Carego Medika Indonesia', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade400)),
            ],
          ),
        ),
      ),
    );
  }
}
