import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'ambulance_screen.dart';
import 'caregiver_screen.dart';
import 'rental_screen.dart';
import 'wallet_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const HomeScreen({super.key, required this.userId, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _balance = 0;
  List<Map<String, dynamic>> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final balance = await ApiService.getBalance(widget.userId);
      final recs = await ApiService.getRecommendations();
      setState(() {
        _balance = balance;
        _recommendations = recs;
      });
    } catch (_) {}
  }

  String _formatCurrency(int amount) {
    final str = amount.toString();
    final result = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) result.write('.');
      result.write(str[i]);
    }
    return result.toString();
  }

  void _showComingSoon(String serviceName) {
    showDialog(
      context: context,
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
              child: const Icon(Icons.rocket_launch, color: Color(0xFF0D9488), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Segera Hadir!',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        content: Text(
          'Layanan "$serviceName" sedang dalam tahap pengembangan dan akan segera tersedia untuk Anda.',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Mengerti', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _navigateToService(String serviceName) {
    switch (serviceName) {
      case 'Ambulance':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AmbulanceScreen(initialType: 0)));
        break;
      case 'Caregiver /\nPenunggu':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CaregiverScreen()));
        break;
      case 'Sewa Alat Kesehatan':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const RentalScreen()));
        break;
      default:
        _showComingSoon(serviceName.replaceAll('\n', ' '));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF0D9488),
          onRefresh: _fetchData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildHeroBanner(),
                _buildServiceGrid(),
                _buildTrustBanner(),
                _buildRecommendations(),
                _buildHelpBanner(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCCFBF1)),
            ),
            child: const Icon(Icons.favorite, color: Color(0xFF0D9488), size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CAREGO',
                    style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0D9488))),
                Text('Semua Kebutuhan Pasien dalam Satu Genggaman',
                    style: GoogleFonts.inter(
                        fontSize: 9, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          // Notification bell
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined,
                    color: Colors.grey.shade700, size: 24),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                },
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.red.shade500,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Center(
                    child: Text('3',
                        style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          // Wallet
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => WalletScreen(userId: widget.userId)));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                  ),
                ],
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.credit_card,
                        size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Saldo',
                          style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500)),
                      Text('Rp ${_formatCurrency(_balance)}',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800)),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right,
                      size: 14, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HERO BANNER ──────────────────────────────────────
  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF5F7),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Right side image
            Positioned(
              right: 0,
              bottom: 0,
              top: 0,
              width: MediaQuery.of(context).size.width * 0.4,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: Image.network(
                  'https://images.unsplash.com/photo-1579684385127-1ef15d508118?q=80&w=800&auto=format&fit=crop',
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.7),
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFD1E8EB),
                    child: const Icon(Icons.medical_services,
                        size: 50, color: Color(0xFF0D9488)),
                  ),
                ),
              ),
            ),
            // Text content
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Layanan Lengkap\nUntuk Pasien & Keluarga',
                        style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF134E4A),
                            height: 1.3)),
                    const SizedBox(height: 8),
                    Text(
                      'Ambulance, penginapan, alat kesehatan, caregiver, dan layanan lainnya siap membantu.',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF115E59),
                          height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AmbulanceScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0D9488).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text('Pesan Sekarang',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Pagination dots
            Positioned(
              left: 20,
              bottom: 16,
              child: Row(
                children: [
                  Container(
                      width: 20,
                      height: 5,
                      decoration: BoxDecoration(
                          color: const Color(0xFF0D9488),
                          borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 4),
                  _dot(),
                  const SizedBox(width: 4),
                  _dot(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot() => Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          color: const Color(0xFFB2DFDB),
          borderRadius: BorderRadius.circular(4),
        ),
      );

  // ─── SERVICE GRID ─────────────────────────────────────
  Widget _buildServiceGrid() {
    final services = [
      _ServiceItem('Ambulance', Icons.emergency, const Color(0xFFFEF2F2),
          const Color(0xFFEF4444)),
      _ServiceItem('Penginapan Dekat RS', Icons.domain, const Color(0xFFEFF6FF),
          const Color(0xFF3B82F6)),
      _ServiceItem('Sewa Alat Kesehatan', Icons.medical_services,
          const Color(0xFFF0FDFA), const Color(0xFF0D9488)),
      _ServiceItem('Perlengkapan Bayi', Icons.child_care,
          const Color(0xFFFFF7ED), const Color(0xFFF97316)),
      _ServiceItem('Caregiver /\nPenunggu', Icons.person_add_alt_1,
          const Color(0xFFF5F3FF), const Color(0xFF8B5CF6)),
      _ServiceItem('Perawatan Pasien', Icons.healing, const Color(0xFFFDF2F8),
          const Color(0xFFEC4899)),
      _ServiceItem('Layanan Jenazah', Icons.local_shipping, const Color(0xFFF0F9FF),
          const Color(0xFF0EA5E9)),
      _ServiceItem('Lainnya', Icons.grid_view, const Color(0xFFF5F5F5),
          Colors.grey.shade600),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Layanan Utama',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800)),
              GestureDetector(
                onTap: () => _showAllServices(),
                child: Row(
                  children: [
                    Text('Lihat Semua',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0D9488))),
                    const Icon(Icons.chevron_right,
                        size: 14, color: Color(0xFF0D9488)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final s = services[index];
              return GestureDetector(
                onTap: () => _navigateToService(s.label),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: s.bgColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(s.icon, color: s.iconColor, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(s.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAllServices() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final allServices = [
          {'name': 'Ambulance', 'icon': Icons.local_hospital, 'color': const Color(0xFFEF4444), 'available': true},
          {'name': 'Caregiver', 'icon': Icons.people, 'color': const Color(0xFF0D9488), 'available': true},
          {'name': 'Alat Kesehatan', 'icon': Icons.medical_services, 'color': const Color(0xFFF97316), 'available': true},
          {'name': 'Penginapan', 'icon': Icons.hotel, 'color': const Color(0xFF3B82F6), 'available': false},
          {'name': 'Konsultasi', 'icon': Icons.chat_bubble_outline, 'color': const Color(0xFF8B5CF6), 'available': false},
          {'name': 'Obat & Resep', 'icon': Icons.medication, 'color': const Color(0xFFEC4899), 'available': false},
          {'name': 'Cek Lab', 'icon': Icons.science, 'color': const Color(0xFF0EA5E9), 'available': false},
          {'name': 'Home Care', 'icon': Icons.home, 'color': const Color(0xFF10B981), 'available': false},
          {'name': 'Fisioterapi', 'icon': Icons.accessibility_new, 'color': const Color(0xFF6366F1), 'available': false},
          {'name': 'Nutrisi', 'icon': Icons.restaurant, 'color': const Color(0xFFF59E0B), 'available': false},
        ];

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 24),
              Text('Semua Layanan', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey.shade800)),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, mainAxisSpacing: 20, crossAxisSpacing: 12, childAspectRatio: 0.8,
                ),
                itemCount: allServices.length,
                itemBuilder: (context, index) {
                  final s = allServices[index];
                  final available = s['available'] as bool;
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToService(s['name'] as String);
                    },
                    child: Opacity(
                      opacity: available ? 1.0 : 0.5,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 52, height: 52,
                                decoration: BoxDecoration(
                                  color: (s['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(s['icon'] as IconData, color: s['color'] as Color, size: 24),
                              ),
                              if (!available)
                                Positioned(
                                  right: 0, top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.orange, borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text('Soon', style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w700, color: Colors.white)),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(s['name'] as String,
                              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── TRUST BANNER ─────────────────────────────────────
  Widget _buildTrustBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F9F8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCCFBF1)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCCFBF1)),
              ),
              child: const Icon(Icons.verified_user,
                  color: Color(0xFF0D9488), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mitra Terverifikasi & Terpercaya',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF115E59))),
                  const SizedBox(height: 2),
                  Text(
                    'Semua mitra kami telah melalui proses verifikasi untuk keamanan Anda.',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF0F766E),
                        height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text('Mitra Terverifikasi', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _infoRow(Icons.verified, 'Semua ambulance berlisensi Kemenkes'),
                        const SizedBox(height: 12),
                        _infoRow(Icons.badge, 'Caregiver bersertifikat perawat'),
                        const SizedBox(height: 12),
                        _infoRow(Icons.health_and_safety, 'Alat kesehatan berstandar SNI'),
                        const SizedBox(height: 12),
                        _infoRow(Icons.star, 'Rating minimum 4.0 untuk semua mitra'),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text('Mengerti', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFB2DFDB)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Selengkapnya',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0D9488))),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right,
                        size: 14, color: Color(0xFF0D9488)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0D9488)),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700, height: 1.3))),
      ],
    );
  }

  // ─── RECOMMENDATIONS ──────────────────────────────────
  Widget _buildRecommendations() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rekomendasi untuk Anda',
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800)),
                GestureDetector(
                  onTap: () => _showComingSoon('Semua Rekomendasi'),
                  child: Row(
                    children: [
                      Text('Lihat Semua',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0D9488))),
                      const Icon(Icons.chevron_right,
                          size: 14, color: Color(0xFF0D9488)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: _recommendations.isEmpty
                ? Center(
                    child: Text('Memuat rekomendasi...',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.grey.shade400)))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _recommendations.length,
                    itemBuilder: (context, index) {
                      final rec = _recommendations[index];
                      return _buildRecCard(rec);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecCard(Map<String, dynamic> rec) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AmbulanceScreen()));
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      rec['image'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFEAF5F7),
                        child: const Icon(Icons.image,
                            color: Color(0xFF0D9488), size: 30),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(rec['tagLabel'] ?? '',
                            style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rec['title'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 3),
                      Text(
                        '${(rec['rating'] as num?)?.toStringAsFixed(1) ?? '0.0'}',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700),
                      ),
                      Text(' (${rec['reviews'] ?? 0})',
                          style: GoogleFonts.inter(
                              fontSize: 10, color: Colors.grey.shade400)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(rec['price'] ?? '',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0D9488))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HELP BANNER ──────────────────────────────────────
  Widget _buildHelpBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF5F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.headset_mic,
                  color: Color(0xFF0D9488), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Butuh Bantuan?',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800)),
                  const SizedBox(height: 2),
                  Text('Hubungi customer service kami',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text('Hubungi Kami', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _contactRow(Icons.phone, 'Telepon', '0800-123-4567'),
                        const SizedBox(height: 16),
                        _contactRow(Icons.chat, 'WhatsApp', '+62 812-3456-7890'),
                        const SizedBox(height: 16),
                        _contactRow(Icons.email, 'Email', 'cs@carego.id'),
                        const SizedBox(height: 16),
                        _contactRow(Icons.access_time, 'Jam Operasional', '24 Jam, 7 Hari'),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text('Tutup', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Hubungi Kami',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF0D9488)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade500)),
              Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceItem {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  _ServiceItem(this.label, this.icon, this.bgColor, this.iconColor);
}
