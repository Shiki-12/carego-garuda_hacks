import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onGoToLogin;
  final Function(String token, Map<String, dynamic> user) onLogin;

  const RegisterScreen({
    super.key,
    required this.onGoToLogin,
    required this.onLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 1; // 1: form, 2: verify OTP
  String _otpMethod = 'whatsapp';

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _otpCodeCtrl = TextEditingController();

  bool _showPassword = false;
  String _error = '';
  String _success = '';
  bool _loading = false;

  Future<void> _handleSendOtp() async {
    setState(() { _error = ''; _success = ''; });

    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Password dan konfirmasi tidak cocok');
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      setState(() => _error = 'Password minimal 6 karakter');
      return;
    }
    if (_otpMethod == 'whatsapp' && _phoneCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Nomor WhatsApp diperlukan');
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await ApiService.registerSendOtp(
        _emailCtrl.text.trim(),
        _phoneCtrl.text.trim(),
        _otpMethod,
      );
      setState(() {
        _success = res['message'] ?? 'OTP terkirim';
        _step = 2;
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleVerify() async {
    setState(() { _error = ''; _success = ''; _loading = true; });
    try {
      final res = await ApiService.registerVerifyOtp(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _phoneCtrl.text.trim(),
        _passwordCtrl.text,
        _otpCodeCtrl.text.trim(),
      );
      widget.onLogin(res['token'], res['user']);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0FDFA), Colors.white, Color(0xFFECFEFF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  // ── Logo ──
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D9488).withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.favorite, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 12),
                  Text('CAREGO',
                      style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F766E))),
                  const SizedBox(height: 4),
                  Text('Daftar Akun Baru Pasien',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey.shade400)),
                  const SizedBox(height: 24),

                  // ── Card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        if (_error.isNotEmpty) _msgBox(_error, true),
                        if (_success.isNotEmpty) _msgBox(_success, false),
                        if (_step == 1) _buildForm(),
                        if (_step == 2) _buildOtpVerify(),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Sudah punya akun? ',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey.shade400)),
                            GestureDetector(
                              onTap: widget.onGoToLogin,
                              child: Text('Masuk',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0D9488))),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────

  Widget _msgBox(String msg, bool isError) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0),
        ),
      ),
      child: Text(msg,
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isError
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF15803D))),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool required_ = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Icon(icon, size: 16, color: Colors.grey.shade400),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    obscureText: isPassword && !_showPassword,
                    keyboardType: keyboardType,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.grey.shade800),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                if (isPassword)
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showPassword = !_showPassword),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        _showPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _inputField(
          controller: _nameCtrl,
          label: 'Nama Lengkap',
          hint: 'Nama Lengkap',
          icon: Icons.person_outline,
        ),
        _inputField(
          controller: _emailCtrl,
          label: 'Email',
          hint: 'email@contoh.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        _inputField(
          controller: _phoneCtrl,
          label: 'Nomor WhatsApp',
          hint: 'Cth: 0812345678',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          required_: false,
        ),
        _inputField(
          controller: _passwordCtrl,
          label: 'Password',
          hint: 'Minimal 6 karakter',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        _inputField(
          controller: _confirmCtrl,
          label: 'Konfirmasi Password',
          hint: 'Ulangi password',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        // Method selector
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Metode Verifikasi OTP',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500)),
            const SizedBox(height: 8),
            Row(
              children: [
                _methodBtn('WhatsApp', Icons.phone, 'whatsapp'),
                const SizedBox(width: 12),
                _methodBtn('Email', Icons.email_outlined, 'email'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _loading ? null : _handleSendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: Text(_loading ? 'Mengirim Kode...' : 'Daftar & Kirim OTP',
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpVerify() {
    return Column(
      children: [
        Text('Masukkan Kode OTP',
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500)),
        const SizedBox(height: 8),
        TextField(
          controller: _otpCodeCtrl,
          maxLength: 6,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 16,
              color: Colors.grey.shade800),
          decoration: InputDecoration(
            counterText: '',
            hintText: '123456',
            hintStyle: GoogleFonts.inter(
                fontSize: 22, color: Colors.grey.shade300, letterSpacing: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF0D9488), width: 2)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kode dikirim ke ${_otpMethod == 'whatsapp' ? _phoneCtrl.text : _emailCtrl.text}',
          style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade400),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => setState(() => _step = 1),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade200),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Kembali',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey.shade600)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: Text(
                      _loading ? 'Mendaftar...' : 'Verifikasi & Daftar',
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _methodBtn(String label, IconData icon, String method) {
    final selected = _otpMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _otpMethod = method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF0FDFA) : Colors.transparent,
            border: Border.all(
                color: selected
                    ? const Color(0xFF0D9488)
                    : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 14,
                  color: selected
                      ? const Color(0xFF0F766E)
                      : Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? const Color(0xFF0F766E)
                        : Colors.grey.shade600,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
