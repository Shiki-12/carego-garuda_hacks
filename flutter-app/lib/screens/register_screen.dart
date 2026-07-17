import 'dart:async';
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

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
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

  // Resend timer
  Timer? _resendTimer;
  int _resendCountdown = 0;

  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _animController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _otpCodeCtrl.dispose();
    super.dispose();
  }

  // ─── Validation ────────────────────────────────────────
  String? _validateForm() {
    if (_nameCtrl.text.trim().isEmpty) return 'Nama lengkap tidak boleh kosong';
    if (_nameCtrl.text.trim().length < 3) return 'Nama minimal 3 karakter';

    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return 'Email tidak boleh kosong';
    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(email)) return 'Format email tidak valid';

    final phone = _phoneCtrl.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.isEmpty) return 'Nomor WhatsApp tidak boleh kosong';
    if (phone.length < 9) return 'Nomor WhatsApp minimal 9 digit';

    if (_passwordCtrl.text.length < 6) return 'Password minimal 6 karakter';
    if (_passwordCtrl.text != _confirmCtrl.text) {
      return 'Password dan konfirmasi tidak cocok';
    }

    return null;
  }

  // ─── Resend timer ──────────────────────────────────────
  void _startResendTimer() {
    _resendCountdown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown <= 0) {
        timer.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  // ─── Send OTP ──────────────────────────────────────────
  Future<void> _handleSendOtp() async {
    final validationError = _validateForm();
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    setState(() {
      _error = '';
      _success = '';
      _loading = true;
    });
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
      _startResendTimer();
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── Resend OTP ────────────────────────────────────────
  Future<void> _handleResendOtp() async {
    if (_resendCountdown > 0) return;
    setState(() {
      _error = '';
      _success = '';
      _loading = true;
    });
    try {
      final res = await ApiService.registerSendOtp(
        _emailCtrl.text.trim(),
        _phoneCtrl.text.trim(),
        _otpMethod,
      );
      setState(() => _success = res['message'] ?? 'OTP terkirim ulang');
      _startResendTimer();
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── Verify OTP ────────────────────────────────────────
  Future<void> _handleVerify() async {
    if (_otpCodeCtrl.text.trim().length != 6) {
      setState(() => _error = 'Kode OTP harus 6 digit');
      return;
    }
    setState(() {
      _error = '';
      _success = '';
      _loading = true;
    });
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
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF0FDFA),
                  Colors.white,
                  Color(0xFFECFEFF),
                  Color(0xFFF0FFF4),
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
          // Top-left blob
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF14B8A6).withOpacity(0.07),
                    const Color(0xFF14B8A6).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Bottom-right blob
          Positioned(
            bottom: -70,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0D9488).withOpacity(0.06),
                    const Color(0xFF0D9488).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // ── Main content ──
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      // ── Logo ──
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF0D9488).withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D9488),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.favorite,
                                  color: Colors.white, size: 32),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Buat Akun Baru',
                          style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F766E))),
                      const SizedBox(height: 4),
                      Text('Daftar untuk memulai layanan CareGo',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey.shade400)),
                      const SizedBox(height: 24),

                      // ── Step indicator ──
                      _buildStepIndicator(),
                      const SizedBox(height: 20),

                      // ── Card ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0D9488)
                                  .withOpacity(0.06),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color:
                                  Colors.grey.shade100.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                              color:
                                  Colors.grey.shade100.withOpacity(0.8)),
                        ),
                        child: Column(
                          children: [
                            if (_error.isNotEmpty) _msgBox(_error, true),
                            if (_success.isNotEmpty)
                              _msgBox(_success, false),

                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _step == 1
                                  ? _buildForm()
                                  : _buildOtpVerify(),
                            ),

                            const SizedBox(height: 22),
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
                                          color:
                                              const Color(0xFF0D9488))),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step Indicator ────────────────────────────────────
  Widget _buildStepIndicator() {
    return Row(
      children: [
        _stepDot(1, 'Isi Data'),
        Expanded(
          child: Container(
            height: 2,
            color: _step >= 2
                ? const Color(0xFF0D9488)
                : Colors.grey.shade200,
          ),
        ),
        _stepDot(2, 'Verifikasi'),
      ],
    );
  }

  Widget _stepDot(int step, String label) {
    final active = _step >= step;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? const Color(0xFF0D9488) : Colors.grey.shade200,
            boxShadow: active
                ? [
                    BoxShadow(
                        color: const Color(0xFF0D9488).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Center(
            child: active
                ? (step < _step
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text('$step',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)))
                : Text('$step',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active
                    ? const Color(0xFF0F766E)
                    : Colors.grey.shade400)),
      ],
    );
  }

  // ─── Helpers ───────────────────────────────────────────

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
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            size: 16,
            color:
                isError ? const Color(0xFFDC2626) : const Color(0xFF15803D),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(msg,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isError
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF15803D))),
          ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50.withOpacity(0.5),
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child:
                      Icon(icon, size: 18, color: const Color(0xFF0D9488)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    obscureText: isPassword && !_showPassword,
                    keyboardType: keyboardType,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: Colors.grey.shade800),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: GoogleFonts.inter(
                          fontSize: 13, color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 15),
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
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
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

  Widget _primaryButton({
    required VoidCallback onPressed,
    required String label,
    required String loadingLabel,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D9488),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF0D9488).withOpacity(0.6),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: _loading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(loadingLabel,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ],
              )
            : Text(label,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      key: const ValueKey('register_form'),
      children: [
        _inputField(
          controller: _nameCtrl,
          label: 'Nama Lengkap',
          hint: 'Masukkan nama lengkap Anda',
          icon: Icons.person_outline_rounded,
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
          hint: 'Cth: 081234567890',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        _inputField(
          controller: _passwordCtrl,
          label: 'Password',
          hint: 'Minimal 6 karakter',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
        ),
        _inputField(
          controller: _confirmCtrl,
          label: 'Konfirmasi Password',
          hint: 'Ulangi password Anda',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
        ),

        // OTP Method selector
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kirim Kode Verifikasi via',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Row(
              children: [
                _methodBtn('WhatsApp', Icons.chat_rounded, 'whatsapp'),
                const SizedBox(width: 12),
                _methodBtn('Email', Icons.mail_outline_rounded, 'email'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 22),
        _primaryButton(
          onPressed: _handleSendOtp,
          label: 'Daftar & Kirim Kode OTP',
          loadingLabel: 'Mengirim...',
        ),
      ],
    );
  }

  Widget _buildOtpVerify() {
    final destination = _otpMethod == 'whatsapp'
        ? _phoneCtrl.text.trim()
        : _emailCtrl.text.trim();

    return Column(
      key: const ValueKey('otp_verify_form'),
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDFA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF99F6E4)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _otpMethod == 'whatsapp'
                      ? Icons.chat_rounded
                      : Icons.mail_outline_rounded,
                  size: 18,
                  color: const Color(0xFF0F766E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kode Verifikasi Terkirim!',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F766E))),
                    const SizedBox(height: 2),
                    Text(
                      'Dikirim ke $destination',
                      style: GoogleFonts.inter(
                          fontSize: 10, color: Colors.grey.shade500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // OTP Input
        Text('Masukkan 6 Digit Kode',
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600)),
        const SizedBox(height: 10),
        TextField(
          controller: _otpCodeCtrl,
          maxLength: 6,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 12,
              color: const Color(0xFF0F766E)),
          decoration: InputDecoration(
            counterText: '',
            hintText: '• • • • • •',
            hintStyle: GoogleFonts.inter(
                fontSize: 24,
                color: Colors.grey.shade300,
                letterSpacing: 12),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: Color(0xFF0D9488), width: 2)),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),

        const SizedBox(height: 12),
        // Resend timer
        _resendCountdown > 0
            ? Text('Kirim ulang dalam ${_resendCountdown}s',
                style: GoogleFonts.inter(
                    fontSize: 11, color: Colors.grey.shade400))
            : GestureDetector(
                onTap: _loading ? null : _handleResendOtp,
                child: Text('Kirim Ulang Kode OTP',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0D9488))),
              ),

        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _step = 1;
                    _otpCodeCtrl.clear();
                    _error = '';
                    _success = '';
                    _resendTimer?.cancel();
                    _resendCountdown = 0;
                  }),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade200),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Kembali',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.grey.shade600)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _primaryButton(
                onPressed: _handleVerify,
                label: 'Verifikasi',
                loadingLabel: 'Mendaftar...',
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF0FDFA) : Colors.transparent,
            border: Border.all(
                color: selected
                    ? const Color(0xFF0D9488)
                    : Colors.grey.shade200,
                width: selected ? 1.5 : 1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected
                      ? const Color(0xFF0F766E)
                      : Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? const Color(0xFF0F766E)
                        : Colors.grey.shade500,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
