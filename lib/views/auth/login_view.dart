// lib/views/auth/login_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import 'register_view.dart';
import 'verify_email_view.dart';
import '../home/home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final ctrl = context.read<AuthController>();
    final result = await ctrl.signIn(
      email: _emailCtrl.text,
      password: _passCtrl.text,
    );

    if (!mounted) return;

    if (result == 'verified') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeView()),
        (_) => false,
      );
    } else if (result == 'unverified') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              VerifyEmailView(email: _emailCtrl.text.trim()),
        ),
      );
    } else if (result == 'error') {
      Helpers.showErrorSnackbar(context, ctrl.errorMessage ?? 'Terjadi kesalahan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AuthController>();

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryDark,
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Dekorasi lingkaran
          Positioned(
            top: -60,
            right: -60,
            child: _circle(200, Colors.white.withOpacity(0.06)),
          ),
          Positioned(
            top: 120,
            left: -80,
            child: _circle(160, Colors.white.withOpacity(0.05)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Logo & judul
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(AppRadius.xl),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.report_problem_rounded,
                            color: AppColors.primary,
                            size: 38,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          AppText.appName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppText.tagline,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 44),

                  // Form card
                  SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppRadius.xl),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                AppText.login,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Selamat datang kembali!',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textHint),
                              ),
                              const SizedBox(height: 24),

                              // Email
                              _fieldLabel(AppText.email),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: Validators.validateEmail,
                                decoration: _inputDeco(
                                  hint: 'nama@email.com',
                                  icon: Icons.email_outlined,
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Password
                              _fieldLabel(AppText.password),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscurePass,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleSignIn(),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Password wajib diisi'
                                    : null,
                                decoration: _inputDeco(
                                  hint: '••••••••',
                                  icon: Icons.lock_outline_rounded,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscurePass
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.textHint,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(
                                        () => _obscurePass = !_obscurePass),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Tombol Sign In
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      ctrl.isLoading ? null : _handleSignIn,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.md),
                                    ),
                                  ),
                                  child: ctrl.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          AppText.signIn,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Link ke Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterView()),
                        ),
                        child: const Text(
                          'Daftar Sekarang',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) => Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      );

  InputDecoration _inputDeco({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide:
              const BorderSide(color: AppColors.error, width: 2),
        ),
      );

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
