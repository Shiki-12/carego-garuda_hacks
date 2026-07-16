import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final String title;

  const MapPickerScreen({
    super.key,
    this.initialPosition,
    this.title = 'Pilih Lokasi',
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late final MapController _mapController;
  late LatLng _currentCenter;
  String _currentAddress = 'Mencari lokasi...';
  bool _isGeocoding = false;
  Timer? _debounceTimer;

  // Search autocomplete variables
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _searchDebounce;

  // Popular Hospitals list for Indonesian context
  final List<Map<String, dynamic>> _popularHospitals = [
    {
      'name': 'RS Fatmawati',
      'address': 'Jl. RS. Fatmawati Raya, Cilandak, Jakarta Selatan',
      'lat': -6.2771,
      'lng': 106.7974,
    },
    {
      'name': 'RS Pondok Indah',
      'address': 'Jl. Metro Pondok Indah, Kebayoran Lama, Jakarta Selatan',
      'lat': -6.2652,
      'lng': 106.7831,
    },
    {
      'name': 'RS Cipto Mangunkusumo (RSCM)',
      'address': 'Jl. Pangeran Diponegoro No.71, Senen, Jakarta Pusat',
      'lat': -6.1979,
      'lng': 106.8480,
    },
    {
      'name': 'RS Siloam Semanggi',
      'address': 'Jl. Garnisun Dalam No.2-3, Karet Semanggi, Jakarta Selatan',
      'lat': -6.2197,
      'lng': 106.8152,
    },
    {
      'name': 'RS Hermina Kemayoran',
      'address': 'Jl. Selangit B-10 Kav.4, Gunung Sahari Selatan, Jakarta Pusat',
      'lat': -6.1558,
      'lng': 106.8482,
    },
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Default to Jakarta if no initial position
    _currentCenter = widget.initialPosition ?? const LatLng(-6.2088, 106.8456);
    _reverseGeocode(_currentCenter);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ─── REVERSE GEOCODE (Coordinates to Address) ────────────
  Future<void> _reverseGeocode(LatLng coords) async {
    setState(() => _isGeocoding = true);
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=${coords.latitude}&lon=${coords.longitude}&format=json&addressdetails=1&accept-language=id');
      final response = await http.get(url, headers: {
        'User-Agent': 'CaregoApp/1.0',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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

        final fullText = parts.isNotEmpty ? parts.join(', ') : (data['display_name'] ?? 'Lokasi ditemukan');

        setState(() {
          _currentAddress = fullText;
        });
      }
    } catch (_) {
      setState(() {
        _currentAddress = 'Lat: ${coords.latitude.toStringAsFixed(4)}, Lng: ${coords.longitude.toStringAsFixed(4)}';
      });
    } finally {
      setState(() => _isGeocoding = false);
    }
  }

  // Debounced reverse geocoding on map drag
  void _onMapPositionChanged(MapPosition position, bool hasGesture) {
    if (!hasGesture) return;

    if (position.center != null) {
      _currentCenter = position.center!;
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 600), () {
        _reverseGeocode(_currentCenter);
      });
    }
  }

  // ─── SEARCH / AUTOCOMPLETE (Forward Geocode) ─────────────
  void _onSearchQueryChanged(String query) {
    _searchDebounce?.cancel();
    if (query.trim().length < 3) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isSearching = true);
      try {
        final url = Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&countrycodes=id&accept-language=id');
        final response = await http.get(url, headers: {
          'User-Agent': 'CaregoApp/1.0',
        });

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          setState(() {
            _searchResults = data.map((item) {
              return {
                'display_name': item['display_name'],
                'lat': double.parse(item['lat']),
                'lon': double.parse(item['lon']),
              };
            }).toList();
          });
        }
      } catch (_) {} finally {
        setState(() => _isSearching = false);
      }
    });
  }

  // Move camera to selected location
  void _moveToLocation(double lat, double lng, String name) {
    final target = LatLng(lat, lng);
    _currentCenter = target;
    _mapController.move(target, 16.0);
    _reverseGeocode(target);
    setState(() {
      _searchResults = [];
      _searchController.clear();
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title,
            style: GoogleFonts.inter(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ─── FLUTTER MAP ───────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 15.0,
              onPositionChanged: _onMapPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.carego.carego_mobile',
              ),
            ],
          ),

          // ─── FIXED PIN IN THE CENTER ───────────────────
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Text(
                      'Jemput di Sini',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFF0D9488),
                    size: 45,
                  ),
                ],
              ),
            ),
          ),

          // ─── SEARCH FLOATING CARD ─────────────────────
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchQueryChanged,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Cari Rumah Sakit / Alamat...',
                      hintStyle: GoogleFonts.inter(
                          fontSize: 14, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFF0D9488)),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF0D9488),
                                ),
                              ),
                            )
                          : _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchResults = []);
                                  },
                                )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
                // Autocomplete Results list
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final res = _searchResults[index];
                        final displayName = res['display_name'] as String;
                        final shortName = displayName.split(',').take(2).join(',');
                        final details = displayName.split(',').skip(2).take(2).join(',');

                        return ListTile(
                          leading: const Icon(Icons.location_on_outlined,
                              color: Color(0xFF0D9488)),
                          title: Text(shortName,
                              style: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: Text(details,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(fontSize: 11)),
                          onTap: () => _moveToLocation(res['lat'], res['lon'], shortName),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // ─── BOTTOM ADDRESS SHEET ──────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alamat Terpilih',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF0D9488)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _isGeocoding
                              ? const SizedBox(
                                  height: 20,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF0D9488),
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  _currentAddress,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800),
                                ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Popular shortcuts title
                    Text('Rekomendasi Rumah Sakit Terdekat',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700)),
                    const SizedBox(height: 12),

                    // Popular hospitals list
                    SizedBox(
                      height: 38,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _popularHospitals.length,
                        itemBuilder: (context, index) {
                          final h = _popularHospitals[index];
                          return GestureDetector(
                            onTap: () => _moveToLocation(h['lat'], h['lng'], h['name']),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_hospital,
                                      size: 14, color: Colors.red),
                                  const SizedBox(width: 6),
                                  Text(
                                    h['name'],
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Confirm selection button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isGeocoding
                            ? null
                            : () {
                                Navigator.pop(context, {
                                  'address': _currentAddress,
                                  'lat': _currentCenter.latitude,
                                  'lng': _currentCenter.longitude,
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Pilih Lokasi Ini',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
