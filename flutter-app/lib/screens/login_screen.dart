import 'dart:async';
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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
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

  // Resend OTP timer
  Timer? _resendTimer;
  int _resendCountdown = 0;

  String _error = '';
  String _success = '';
  bool _loading = false;

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
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _animController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _otpIdentifierCtrl.dispose();
    _otpCodeCtrl.dispose();
    super.dispose();
  }

  // ─── Validation ────────────────────────────────────────
  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email tidak boleh kosong';
    final regex = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$');
    if (!regex.hasMatch(email)) return 'Format email tidak valid';
    return null;
  }

  String? _validatePhone(String phone) {
    if (phone.isEmpty) return 'Nomor WhatsApp tidak boleh kosong';
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length < 9) return 'Nomor WhatsApp minimal 9 digit';
    if (cleaned.length > 15) return 'Nomor WhatsApp terlalu panjang';
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

  // ─── Password login ────────────────────────────────────
  Future<void> _handlePasswordLogin() async {
    final emailErr = _validateEmail(_emailCtrl.text.trim());
    if (emailErr != null) {
      setState(() => _error = emailErr);
      return;
    }
    if (_passwordCtrl.text.isEmpty) {
      setState(() => _error = 'Password tidak boleh kosong');
      return;
    }
    setState(() {
      _error = '';
      _success = '';
      _loading = true;
    });
    try {
      final res = await ApiService.login(
          _emailCtrl.text.trim(), _passwordCtrl.text);
      widget.onLogin(res['token'], res['user']);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── OTP send ──────────────────────────────────────────
  Future<void> _handleSendOtp() async {
    final identifier = _otpIdentifierCtrl.text.trim();
    if (_otpType == 'whatsapp') {
      final err = _validatePhone(identifier);
      if (err != null) {
        setState(() => _error = err);
        return;
      }
    } else {
      final err = _validateEmail(identifier);
      if (err != null) {
        setState(() => _error = err);
        return;
      }
    }
    setState(() {
      _error = '';
      _success = '';
      _loading = true;
    });
    try {
      final res = await ApiService.sendOtp(identifier, _otpType);
      setState(() {
        _success = res['message'] ?? 'OTP terkirim';
        _otpStep = 2;
      });
      _startResendTimer();
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── OTP verify ────────────────────────────────────────
  Future<void> _handleVerifyOtp() async {
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
      final res = await ApiService.verifyOtp(
          _otpIdentifierCtrl.text.trim(), _otpCodeCtrl.text.trim());
      widget.onLogin(res['token'], res['user']);
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
      final res = await ApiService.sendOtp(
          _otpIdentifierCtrl.text.trim(), _otpType);
      setState(() => _success = res['message'] ?? 'OTP terkirim ulang');
      _startResendTimer();
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── Google auth ───────────────────────────────────────
  Future<void> _handleGoogleLogin() async {
    setState(() {
      _error = '';
      _success = '';
      _loading = true;
    });
    try {
      final res = await ApiService.googleAuth(
        'google_oauth_${DateTime.now().millisecondsSinceEpoch}',
        'user@gmail.com',
        'Google User',
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
          // ── Background gradient + decorative blobs ──
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
          // Top-right blob
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0D9488).withOpacity(0.08),
                    const Color(0xFF0D9488).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Bottom-left blob
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF14B8A6).withOpacity(0.06),
                    const Color(0xFF14B8A6).withOpacity(0.0),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // ── App Logo ──
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF0D9488).withOpacity(0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D9488),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.favorite,
                                  color: Colors.white, size: 36),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text('CAREGO',
                          style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F766E),
                              letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text('Layanan Kesehatan Terpercaya',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w400)),
                      const SizedBox(height: 28),

                      // ── Main Card ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0D9488).withOpacity(0.06),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: Colors.grey.shade100.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                              color: Colors.grey.shade100.withOpacity(0.8)),
                        ),
                        child: Column(
                          children: [
                            // ── Tab toggle ──
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(14),
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
                            if (_error.isNotEmpty)
                              _msgBox(_error, true),
                            if (_success.isNotEmpty)
                              _msgBox(_success, false),

                            // ── Form ──
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _loginTab == 0
                                  ? _buildPasswordForm()
                                  : _buildOtpForm(),
                            ),

                            const SizedBox(height: 18),
                            // ── Divider ──
                            Row(children: [
                              Expanded(
                                  child:
                                      Divider(color: Colors.grey.shade100)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14),
                                child: Text('atau',
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Colors.grey.shade400)),
                              ),
                              Expanded(
                                  child:
                                      Divider(color: Colors.grey.shade100)),
                            ]),
                            const SizedBox(height: 18),

                            // ── Google button ──
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed:
                                    _loading ? null : _handleGoogleLogin,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: Colors.grey.shade200),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Text('G',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              foreground: Paint()
                                                ..shader =
                                                    const LinearGradient(
                                                  colors: [
                                                    Color(0xFF4285F4),
                                                    Color(0xFFEA4335),
                                                    Color(0xFFFBBC05),
                                                    Color(0xFF34A853),
                                                  ],
                                                ).createShader(
                                                        const Rect.fromLTWH(
                                                            0, 0, 20, 20)),
                                            )),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text('Masuk dengan Google',
                                        style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700)),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),
                            // ── Register link ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Belum punya akun? ',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey.shade400)),
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

  // ─── Helpers ───────────────────────────────────────────

  Widget _buildTab(String label, int index) {
    final selected = _loginTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _loginTab = index;
          _error = '';
          _success = '';
          _otpStep = 1;
          _otpCodeCtrl.clear();
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Center(
            child: Text(label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            size: 16,
            color: isError ? const Color(0xFFDC2626) : const Color(0xFF15803D),
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
    return Column(
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
                child: Icon(icon, size: 18, color: const Color(0xFF0D9488)),
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
    );
  }

  Widget _buildPasswordForm() {
    return Column(
      key: const ValueKey('password_form'),
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
        const SizedBox(height: 22),
        _primaryButton(
          onPressed: _handlePasswordLogin,
          label: 'Masuk',
          loadingLabel: 'Memproses...',
        ),
      ],
    );
  }

  Widget _buildOtpForm() {
    if (_otpStep == 1) {
      return Column(
        key: const ValueKey('otp_send_form'),
        children: [
          // Method selector
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Metode Verifikasi',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _otpMethodBtn('WhatsApp', Icons.chat_rounded, 'whatsapp'),
                  const SizedBox(width: 12),
                  _otpMethodBtn('Email', Icons.mail_outline_rounded, 'email'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _inputField(
            controller: _otpIdentifierCtrl,
            label: _otpType == 'whatsapp' ? 'Nomor WhatsApp' : 'Alamat Email',
            hint: _otpType == 'whatsapp'
                ? 'Cth: 081234567890'
                : 'email@contoh.com',
            icon: _otpType == 'whatsapp'
                ? Icons.phone_outlined
                : Icons.email_outlined,
            keyboardType: _otpType == 'whatsapp'
                ? TextInputType.phone
                : TextInputType.emailAddress,
          ),
          const SizedBox(height: 22),
          _primaryButton(
            onPressed: _handleSendOtp,
            label: 'Kirim Kode OTP',
            loadingLabel: 'Mengirim...',
          ),
        ],
      );
    }

    // OTP verify step
    return Column(
      key: const ValueKey('otp_verify_form'),
      children: [
        // Header
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
                  _otpType == 'whatsapp'
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
                    Text('Kode OTP Terkirim!',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F766E))),
                    const SizedBox(height: 2),
                    Text(
                      'Dikirim ke ${_otpIdentifierCtrl.text}',
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
                    _otpStep = 1;
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
                onPressed: _handleVerifyOtp,
                label: 'Verifikasi',
                loadingLabel: 'Verifikasi...',
              ),
            ),
          ],
        ),
      ],
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

  Widget _otpMethodBtn(String label, IconData icon, String method) {
    final selected = _otpType == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _otpType = method),
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
