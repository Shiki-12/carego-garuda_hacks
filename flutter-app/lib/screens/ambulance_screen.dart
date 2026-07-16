import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'map_picker_screen.dart';
import 'package:latlong2/latlong.dart';

class AmbulanceScreen extends StatefulWidget {
  final int initialType; // 0 = Darurat, 1 = Transportasi, 2 = Ambulance Jenazah

  const AmbulanceScreen({super.key, this.initialType = 0});

  @override
  State<AmbulanceScreen> createState() => _AmbulanceScreenState();
}

class _AmbulanceScreenState extends State<AmbulanceScreen> {
  late int _selectedType;
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isLocating = false;
  bool _isCalculating = false;

  // GPS coordinates
  double? _pickupLat;
  double? _pickupLng;
  double? _destLat;
  double? _destLng;
  double? _distanceKm;

  // Price config per type: [baseFare, pricePerKm]
  final List<List<int>> _pricing = [
    [150000, 15000], // Darurat (ALS)
    [100000, 10000], // Transportasi (BLS)
    [200000, 12000], // Ambulance Jenazah
  ];

  final List<Map<String, dynamic>> _serviceTypes = [
    {
      'title': 'Darurat (ALS)',
      'desc': 'Fasilitas ICU & Perawat',
      'icon': Icons.emergency,
      'color': const Color(0xFFEF4444),
      'bgColor': const Color(0xFFFEF2F2),
    },
    {
      'title': 'Transportasi (BLS)',
      'desc': 'Antar Jemput Stabil',
      'icon': Icons.directions_car,
      'color': const Color(0xFF3B82F6),
      'bgColor': const Color(0xFFEFF6FF),
    },
    {
      'title': 'Ambulance Jenazah',
      'desc': 'Antar Jenazah',
      'icon': Icons.local_shipping,
      'color': const Color(0xFF0EA5E9),
      'bgColor': const Color(0xFFF0F9FF),
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  // ─── OPEN MAP PICKER SCREEN ─────────────────────────────
  Future<void> _openMapPicker(bool isPickup) async {
    final initialPos = isPickup
        ? (_pickupLat != null ? LatLng(_pickupLat!, _pickupLng!) : null)
        : (_destLat != null ? LatLng(_destLat!, _destLng!) : null);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          title: isPickup ? 'Pilih Lokasi Penjemputan' : 'Pilih Lokasi Tujuan',
          initialPosition: initialPos,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        if (isPickup) {
          _pickupController.text = result['address'];
          _pickupLat = result['lat'];
          _pickupLng = result['lng'];
        } else {
          _destinationController.text = result['address'];
          _destLat = result['lat'];
          _destLng = result['lng'];
        }
      });

      // Re-calculate route if both are present
      if (_pickupLat != null && _destLat != null) {
        _calculateRoute();
      }
    }
  }

  // ─── GET CURRENT GPS LOCATION ──────────────────────────
  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Izin lokasi ditolak. Aktifkan di pengaturan HP.');
          setState(() => _isLocating = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showError('Izin lokasi diblokir permanen. Buka pengaturan HP untuk mengaktifkan.');
        setState(() => _isLocating = false);
        return;
      }

      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('GPS tidak aktif. Nyalakan lokasi di HP Anda.');
        setState(() => _isLocating = false);
        return;
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      _pickupLat = position.latitude;
      _pickupLng = position.longitude;

      // Reverse geocode using Nominatim (OSM)
      final address = await _reverseGeocode(position.latitude, position.longitude);

      setState(() {
        _pickupController.text = address;
        _isLocating = false;
      });

      // If destination already has coordinates, calculate distance
      if (_destLat != null && _destLng != null) {
        _calculateRoute();
      }
    } catch (e) {
      _showError('Gagal mendapatkan lokasi: ${e.toString()}');
      setState(() => _isLocating = false);
    }
  }

  // ─── REVERSE GEOCODE (Nominatim / OSM) ─────────────────
  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&addressdetails=1&accept-language=id');
      final response = await http.get(url, headers: {
        'User-Agent': 'CaregoApp/1.0',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Build a clean address
        final address = data['address'];
        final parts = <String>[];
        if (address['road'] != null) parts.add(address['road']);
        if (address['suburb'] != null) parts.add(address['suburb']);
        if (address['city'] != null) {
          parts.add(address['city']);
        } else if (address['town'] != null) {
          parts.add(address['town']);
        } else if (address['village'] != null) {
          parts.add(address['village']);
        }
        return parts.isNotEmpty ? parts.join(', ') : (data['display_name'] ?? 'Lokasi ditemukan');
      }
    } catch (_) {}
    return 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
  }

  // ─── SEARCH LOCATION (Forward Geocode) ─────────────────
  Future<void> _searchDestination() async {
    final query = _destinationController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isCalculating = true);

    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1&countrycodes=id&accept-language=id');
      final response = await http.get(url, headers: {
        'User-Agent': 'CaregoApp/1.0',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          _destLat = double.tryParse(data[0]['lat']);
          _destLng = double.tryParse(data[0]['lon']);

          // Update text field with better name
          final displayName = data[0]['display_name'] as String;
          final shortName = displayName.split(',').take(3).join(',');
          setState(() {
            _destinationController.text = shortName;
          });

          // Calculate route if pickup is set
          if (_pickupLat != null && _pickupLng != null) {
            await _calculateRoute();
          }
        } else {
          _showError('Lokasi "$query" tidak ditemukan. Coba nama yang lebih spesifik.');
        }
      }
    } catch (e) {
      _showError('Gagal mencari lokasi tujuan.');
    }

    setState(() => _isCalculating = false);
  }

  // ─── CALCULATE ROUTE DISTANCE (OSRM) ──────────────────
  Future<void> _calculateRoute() async {
    if (_pickupLat == null || _destLat == null) return;

    setState(() => _isCalculating = true);

    try {
      final url = Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/$_pickupLng,$_pickupLat;$_destLng,$_destLat?overview=false');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final distanceMeters = data['routes'][0]['distance'] as num;
          setState(() {
            _distanceKm = distanceMeters / 1000.0;
          });
        }
      }
    } catch (_) {
      // Fallback: calculate straight-line distance
      final distMeters = Geolocator.distanceBetween(
          _pickupLat!, _pickupLng!, _destLat!, _destLng!);
      setState(() {
        _distanceKm = (distMeters / 1000.0) * 1.3; // ~30% road correction
      });
    }

    setState(() => _isCalculating = false);
  }

  // ─── CALCULATE PRICE ───────────────────────────────────
  int _calculatePrice() {
    final baseFare = _pricing[_selectedType][0];
    final perKm = _pricing[_selectedType][1];
    if (_distanceKm != null) {
      return baseFare + (perKm * _distanceKm!.ceil());
    }
    return baseFare; // Only base fare if no distance yet
  }

  String _formatCurrency(int amount) {
    final str = amount.toString();
    final result = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) result.write('.');
    }
    return 'Rp ${result.toString().split('').reversed.join()}';
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _submitOrder() {
    if (_pickupController.text.isEmpty || _destinationController.text.isEmpty) {
      _showError('Lokasi jemput dan tujuan harus diisi!');
      return;
    }
    if (_patientNameController.text.isEmpty) {
      _showError('Nama pasien harus diisi!');
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    final price = _calculatePrice();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(32),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0FDFA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    color: Color(0xFF0D9488), size: 50),
              ),
              const SizedBox(height: 24),
              Text('Pesanan Diterima!',
                  style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade900)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _summaryRow('Layanan', _serviceTypes[_selectedType]['title']),
                    if (_distanceKm != null)
                      _summaryRow('Jarak', '${_distanceKm!.toStringAsFixed(1)} km'),
                    _summaryRow('Total', _formatCurrency(price)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ambulance terdekat sedang diproses dan akan segera menuju lokasi penjemputan Anda.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 13, color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text('Kembali ke Beranda',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13, color: Colors.grey.shade600)),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentService = _serviceTypes[_selectedType];
    final price = _calculatePrice();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Pesan Ambulance',
            style: GoogleFonts.inter(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── SERVICE TYPE SELECTOR ─────────────────
            Text('Jenis Layanan',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800)),
            const SizedBox(height: 16),
            Row(
              children: List.generate(_serviceTypes.length, (index) {
                final isSelected = _selectedType == index;
                final type = _serviceTypes[index];
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                          right: index < _serviceTypes.length - 1 ? 10 : 0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (type['bgColor'] as Color)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? (type['color'] as Color)
                              : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: (type['color'] as Color)
                                      .withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          Icon(type['icon'] as IconData,
                              color: isSelected
                                  ? (type['color'] as Color)
                                  : Colors.grey.shade400,
                              size: 28),
                          const SizedBox(height: 10),
                          Text(
                            type['title'] as String,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? (type['color'] as Color)
                                    : Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            type['desc'] as String,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                                fontSize: 9,
                                color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // ─── LOCATION SECTION ─────────────────────
            Text('Detail Lokasi',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800)),
            const SizedBox(height: 16),

            // Pickup location with GPS button
            _buildLocationField(
              controller: _pickupController,
              label: 'Lokasi Penjemputan',
              hint: 'Pilih lokasi penjemputan di peta',
              icon: Icons.my_location,
              iconColor: const Color(0xFF0D9488),
              isLoading: _isLocating,
              onGpsTap: () => _openMapPicker(true),
            ),
            const SizedBox(height: 16),

            // Destination location with search
            _buildLocationField(
              controller: _destinationController,
              label: 'Lokasi Tujuan',
              hint: 'Cari rumah sakit / tujuan di peta',
              icon: Icons.location_on,
              iconColor: Colors.red,
              isLoading: _isCalculating,
              onGpsTap: () => _openMapPicker(false),
              gpsIcon: Icons.search,
            ),

            // Distance info card
            if (_distanceKm != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.route, color: Color(0xFF0D9488), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jarak Tempuh',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: Colors.grey.shade600)),
                          Text('${_distanceKm!.toStringAsFixed(1)} km',
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0D9488))),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Estimasi Harga',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.grey.shade600)),
                        Text(_formatCurrency(price),
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade900)),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // ─── PATIENT INFO ─────────────────────────
            Text(_selectedType == 2 ? 'Informasi Jenazah' : 'Informasi Pasien',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800)),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _patientNameController,
              label: _selectedType == 2 ? 'Nama Jenazah' : 'Nama Pasien',
              hint: 'Masukkan nama lengkap',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _notesController,
              label: 'Catatan Tambahan',
              hint: _selectedType == 2
                  ? 'Misal: Butuh peti, arah tujuan pemakaman...'
                  : 'Misal: Patah tulang, butuh oksigen, alergi obat...',
              icon: Icons.notes,
              maxLines: 3,
            ),

            // ─── PRICE BREAKDOWN ──────────────────────
            const SizedBox(height: 32),
            Text('Rincian Biaya',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _priceRow('Tarif Dasar (${_serviceTypes[_selectedType]['title']})',
                      _formatCurrency(_pricing[_selectedType][0])),
                  if (_distanceKm != null) ...[
                    const Divider(height: 20),
                    _priceRow(
                        'Jarak ${_distanceKm!.toStringAsFixed(1)} km × ${_formatCurrency(_pricing[_selectedType][1])}/km',
                        _formatCurrency(_pricing[_selectedType][1] * _distanceKm!.ceil())),
                  ],
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Estimasi',
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade900)),
                      Text(_formatCurrency(price),
                          style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0D9488))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emergency, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text('Pesan Sekarang — ${_formatCurrency(price)}',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── LOCATION FIELD WITH GPS BUTTON ────────────────────
  Widget _buildLocationField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor,
    required bool isLoading,
    required VoidCallback onGpsTap,
    IconData? gpsIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: GoogleFonts.inter(fontSize: 14),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle:
                      GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade400),
                  prefixIcon:
                      Icon(icon, color: iconColor, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF0D9488), width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isLoading ? null : onGpsTap,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Icon(gpsIcon ?? Icons.gps_fixed,
                        color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── NORMAL TEXT FIELD ─────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade400),
            prefixIcon: maxLines == 1
                ? Icon(icon, color: Colors.grey.shade500, size: 20)
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF0D9488), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13, color: Colors.grey.shade600)),
        ),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800)),
      ],
    );
  }
}
