import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text('Pusat Bantuan', style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.support_agent, color: Color(0xFF3B82F6), size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hubungi CS', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E3A8A))),
                        const SizedBox(height: 4),
                        Text('Layanan 24/7 Siap Membantu', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF1D4ED8))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('FAQ', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey.shade800)),
            const SizedBox(height: 16),
            _buildFaqItem('Bagaimana cara memesan Ambulance?', 'Pilih menu Ambulance di Home atau tekan tombol + lalu pilih tujuan dan jenis ambulance.'),
            _buildFaqItem('Metode pembayaran apa saja yang tersedia?', 'Saat ini Carego mendukung pembayaran via CaregoPay, Kartu Kredit, Debit, dan Transfer Bank Virtual Account.'),
            _buildFaqItem('Apakah Caregiver tersertifikasi?', 'Ya, semua caregiver kami telah melewati proses seleksi ketat dan memiliki lisensi/sertifikasi medis resmi.'),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(question, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(answer, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
