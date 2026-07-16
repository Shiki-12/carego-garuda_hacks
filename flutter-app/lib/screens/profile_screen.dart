import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> _user;
  bool _isLoading = false;
  bool _hasChanges = false;
  final ImagePicker _picker = ImagePicker();

  String? _newPhone;
  String? _newPhotoBase64;

  @override
  void initState() {
    super.initState();
    _user = Map<String, dynamic>.from(widget.user);
  }

  Future<void> _updateLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_user', jsonEncode(_user));
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,' + base64Encode(bytes);
      
      setState(() {
        _newPhotoBase64 = base64Image;
        _hasChanges = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error mengambil gambar: $e')),
        );
      }
    }
  }

  Future<void> _editPhone() async {
    final TextEditingController phoneController = TextEditingController(text: _newPhone ?? _user['phone'] ?? '');
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Nomor Telepon', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Contoh: 08123456789',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, phoneController.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
            child: Text('Terapkan', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != (_user['phone'] ?? '')) {
      setState(() {
        _newPhone = result;
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final userId = _user['id'] is int ? _user['id'] : int.parse(_user['id'].toString());
      await ApiService.updateProfile(
        userId, 
        phone: _newPhone, 
        photoBase64: _newPhotoBase64
      );
      
      setState(() {
        if (_newPhone != null) _user['phone'] = _newPhone;
        if (_newPhotoBase64 != null) _user['photo_url'] = _newPhotoBase64;
        _hasChanges = false;
        _newPhone = null;
        _newPhotoBase64 = null;
        _isLoading = false;
      });
      await _updateLocalUser();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perubahan profil berhasil disimpan')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = _newPhotoBase64 ?? _user['photo_url'] as String?;
    ImageProvider? imageProvider;
    
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('data:image')) {
        imageProvider = MemoryImage(base64Decode(photoUrl.split(',')[1]));
      } else {
        imageProvider = NetworkImage(photoUrl);
      }
    }

    final currentPhone = _newPhone ?? _user['phone'] ?? 'Belum diatur';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text('Profil Saya', style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D9488).withOpacity(0.1),
                                shape: BoxShape.circle,
                                image: imageProvider != null ? DecorationImage(image: imageProvider, fit: BoxFit.cover) : null,
                              ),
                              child: imageProvider == null
                                  ? Center(
                                      child: Text(
                                        (_user['name'] as String? ?? 'U')[0].toUpperCase(),
                                        style: GoogleFonts.inter(
                                            fontSize: 40,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF0D9488)),
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D9488),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildField('Nama Lengkap', _user['name'] ?? '-'),
                        const SizedBox(height: 16),
                        _buildField('Email', _user['email'] ?? '-'),
                        const SizedBox(height: 16),
                        _buildField('Nomor Telepon', currentPhone, onTap: _editPhone, isEditable: true),
                        const SizedBox(height: 16),
                        _buildField('Role', (_user['role'] as String? ?? 'patient').toUpperCase()),
                      ],
                    ),
                  ),
                ),
                if (_hasChanges)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                      ]
                    ),
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Simpan Perubahan', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  )
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0D9488)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value, {VoidCallback? onTap, bool isEditable = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isEditable ? Colors.white : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isEditable ? const Color(0xFF0D9488).withOpacity(0.3) : Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade800, fontWeight: FontWeight.w500)),
                if (isEditable)
                  const Icon(Icons.edit, size: 16, color: Color(0xFF0D9488)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
