// lib/views/auth/verify_email_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../home/home_view.dart';

class VerifyEmailView extends StatefulWidget {
  final String email;
  const VerifyEmailView({required this.email, Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  Timer? _checkTimer;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // Cek otomatis tiap 5 detik apakah email sudah diverifikasi
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _autoCheckVerification();
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _autoCheckVerification() async {
    final ctrl = context.read<AuthController>();
    final verified = await ctrl.checkEmailVerified();
    if (verified && mounted) {
      _checkTimer?.cancel();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeView()),
        (_) => false,
      );
    }
  }

  Future<void> _manualCheck() async {
    final ctrl = context.read<AuthController>();
    final verified = await ctrl.checkEmailVerified();
    if (!mounted) return;

    if (verified) {
      _checkTimer?.cancel();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeView()),
        (_) => false,
      );
    } else {
      Helpers.showInfoSnackbar(
          context, 'Email belum diverifikasi. Cek inbox/spam emailmu.');
    }
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown > 0) return;

    final ctrl = context.read<AuthController>();
    final success = await ctrl.resendVerificationEmail(widget.email);

    if (!mounted) return;

    if (success) {
      Helpers.showSuccessSnackbar(
          context, 'Email verifikasi dikirim ulang ke ${widget.email}');
      // Cooldown 60 detik agar tidak spam
      setState(() => _resendCooldown = 60);
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        setState(() => _resendCooldown--);
        if (_resendCooldown <= 0) t.cancel();
      });
    } else {
      Helpers.showErrorSnackbar(
          context, ctrl.errorMessage ?? 'Gagal mengirim ulang email.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Ilustrasi email
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_unread_rounded,
                    color: AppColors.primary, size: 56),
              ),

              const SizedBox(height: 32),

              const Text(
                'Cek Emailmu!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6),
                  children: [
                    const TextSpan(
                        text: 'Kami sudah mengirimkan link verifikasi ke\n'),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(
                        text:
                            '\n\nKlik link di email tersebut untuk mengaktifkan akun, lalu kembali ke sini.'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Info cek otomatis
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Memantau status verifikasi...',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.primary),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Tips
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.statusTertundaBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.statusTertunda.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.tips_and_updates_outlined,
                            color: AppColors.statusTertunda, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Tips',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.statusTertunda,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• Cek folder Spam / Junk jika tidak ada di Inbox\n'
                      '• Pastikan email yang didaftarkan benar\n'
                      '• Link verifikasi berlaku selama 24 jam',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.statusTertunda.withOpacity(0.9),
                          height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tombol "Sudah Verifikasi"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: ctrl.isLoading ? null : _manualCheck,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: ctrl.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Sudah Verifikasi — Masuk',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 12),

              // Tombol kirim ulang
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _resendCooldown > 0 ? null : _resendEmail,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Text(
                    _resendCooldown > 0
                        ? 'Kirim ulang dalam ${_resendCooldown}s'
                        : 'Kirim Ulang Email',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text(
                  'Kembali ke Login',
                  style: TextStyle(color: AppColors.textHint, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
