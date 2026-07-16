import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RentalScreen extends StatelessWidget {
  const RentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.medical_services,
                        color: Color(0xFFF97316), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rental Alat Kesehatan',
                            style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800)),
                        Text('Sewa peralatan medis berkualitas',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.medical_services,
                          color: Color(0xFFF97316), size: 40),
                    ),
                    const SizedBox(height: 20),
                    Text('Rental Alat Kesehatan',
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800)),
                    const SizedBox(height: 8),
                    Text('Fitur ini akan segera hadir.',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
