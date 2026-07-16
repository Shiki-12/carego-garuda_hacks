import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onGoToRegister;
  final Function(String token, Map<String, dynamic> user) onLogin;

  const LoginScreen({
    super.key,
    required this.onGoToRegister,
    required this.onLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Tab: 0 = password, 1 = otp
  int _loginTab = 0;

  // Password fields
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showPassword = false;

  // OTP fields
  int _otpStep = 1; // 1: send, 2: verify
  String _otpType = 'whatsapp';
  final _otpIdentifierCtrl = TextEditingController();
  final _otpCodeCtrl = TextEditingController();

  String _error = '';
  String _success = '';
  bool _loading = false;

  // ─── Password login ───────────────────────────────────
  Future<void> _handlePasswordLogin() async {
    setState(() { _error = ''; _success = ''; _loading = true; });
    try {
      final res = await ApiService.login(
          _emailCtrl.text.trim(), _passwordCtrl.text);
      widget.onLogin(res['token'], res['user']);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  // ─── OTP send ─────────────────────────────────────────
  Future<void> _handleSendOtp() async {
    setState(() { _error = ''; _success = ''; _loading = true; });
    try {
      final res = await ApiService.sendOtp(
          _otpIdentifierCtrl.text.trim(), _otpType);
      setState(() { _success = res['message'] ?? 'OTP terkirim'; _otpStep = 2; });
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  // ─── OTP verify ───────────────────────────────────────
  Future<void> _handleVerifyOtp() async {
    setState(() { _error = ''; _success = ''; _loading = true; });
    try {
      final res = await ApiService.verifyOtp(
          _otpIdentifierCtrl.text.trim(), _otpCodeCtrl.text.trim());
      widget.onLogin(res['token'], res['user']);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  // ─── Google auth ──────────────────────────────────────
  Future<void> _handleGoogleLogin() async {
    setState(() { _error = ''; _success = ''; _loading = true; });
    try {
      final res = await ApiService.googleAuth(
        'google_oauth_10398492084',
        'budi.google@gmail.com',
        'Budi Santoso (Google)',
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  Text('Layanan Kesehatan Terpercaya',
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
                        // ── Tab toggle ──
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              _buildTab('Password', 0),
                              _buildTab('Kode OTP', 1),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Messages ──
                        if (_error.isNotEmpty) _msgBox(_error, true),
                        if (_success.isNotEmpty) _msgBox(_success, false),

                        // ── Form ──
                        if (_loginTab == 0) _buildPasswordForm(),
                        if (_loginTab == 1) _buildOtpForm(),

                        const SizedBox(height: 16),
                        // ── Divider ──
                        Row(children: [
                          Expanded(child: Divider(color: Colors.grey.shade100)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('atau',
                                style: GoogleFonts.inter(
                                    fontSize: 10, color: Colors.grey.shade400)),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade100)),
                        ]),
                        const SizedBox(height: 16),

                        // ── Google button ──
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: _loading ? null : _handleGoogleLogin,
                            icon: Icon(Icons.g_mobiledata,
                                color: Colors.red.shade400, size: 22),
                            label: Text('Masuk dengan Google',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade200),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        // ── Register link ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Belum punya akun? ',
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: Colors.grey.shade400)),
                            GestureDetector(
                              onTap: widget.onGoToRegister,
                              child: Text('Daftar Sekarang',
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

  Widget _buildTab(String label, int index) {
    final selected = _loginTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _loginTab = index;
          _error = '';
          _success = '';
          _otpStep = 1;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selected
                ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]
                : [],
          ),
          child: Center(
            child: Text(label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? const Color(0xFF0F766E)
                      : Colors.grey.shade500,
                )),
          ),
        ),
      ),
    );
  }

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
  }) {
    return Column(
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
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade800),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.inter(
                        fontSize: 12, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (isPassword)
                GestureDetector(
                  onTap: () => setState(() => _showPassword = !_showPassword),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordForm() {
    return Column(
      children: [
        _inputField(
          controller: _emailCtrl,
          label: 'Email',
          hint: 'email@contoh.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _inputField(
          controller: _passwordCtrl,
          label: 'Password',
          hint: 'Masukkan password',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _loading ? null : _handlePasswordLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: Text(_loading ? 'Memproses...' : 'Masuk',
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpForm() {
    if (_otpStep == 1) {
      return Column(
        children: [
          // Method selector
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Metode Kirim',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _otpMethodBtn('WhatsApp', Icons.phone, 'whatsapp'),
                  const SizedBox(width: 12),
                  _otpMethodBtn('Email', Icons.email_outlined, 'email'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _inputField(
            controller: _otpIdentifierCtrl,
            label: _otpType == 'whatsapp' ? 'Nomor WhatsApp' : 'Email',
            hint: _otpType == 'whatsapp' ? 'Cth: 0812345678' : 'email@contoh.com',
            icon: _otpType == 'whatsapp' ? Icons.phone : Icons.email_outlined,
            keyboardType: _otpType == 'whatsapp'
                ? TextInputType.phone
                : TextInputType.emailAddress,
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
              child: Text(_loading ? 'Mengirim...' : 'Kirim Kode OTP',
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      );
    }

    // OTP verify
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
                borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 8),
        Text('Kode telah dikirim ke ${_otpIdentifierCtrl.text}',
            style: GoogleFonts.inter(
                fontSize: 10, color: Colors.grey.shade400)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => setState(() => _otpStep = 1),
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
                  onPressed: _loading ? null : _handleVerifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: Text(_loading ? 'Verifikasi...' : 'Verifikasi',
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

  Widget _otpMethodBtn(String label, IconData icon, String method) {
    final selected = _otpType == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _otpType = method),
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
              Icon(icon, size: 14,
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
