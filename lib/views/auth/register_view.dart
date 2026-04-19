// lib/views/auth/register_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import 'verify_email_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _lokasiCtrl = TextEditingController();
  DateTime? _selectedDOB;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _lokasiCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Pilih Tanggal Lahir',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDOB = picked);
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    // Cek tanggal lahir
    final dobError = Validators.validateDateOfBirth(_selectedDOB);
    if (dobError != null) {
      Helpers.showErrorSnackbar(context, dobError);
      return;
    }

    final ctrl = context.read<AuthController>();
    final success = await ctrl.signUp(
      email: _emailCtrl.text,
      password: _passCtrl.text,
      fullName: _namaCtrl.text,
      dateOfBirth: _selectedDOB!,
      lokasi: _lokasiCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              VerifyEmailView(email: _emailCtrl.text.trim()),
        ),
      );
    } else {
      Helpers.showErrorSnackbar(
          context, ctrl.errorMessage ?? 'Pendaftaran gagal.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buat Akun',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bergabung dengan LaporIn',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Isi data dirimu untuk mulai melaporkan',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Nama Lengkap ──
              _sectionLabel('Nama Lengkap *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: Validators.validateFullName,
                decoration: _deco(
                    hint: 'Nama lengkap sesuai KTP',
                    icon: Icons.person_outline_rounded),
              ),

              const SizedBox(height: 16),

              // ── Email ──
              _sectionLabel('Email *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.validateEmail,
                decoration: _deco(
                    hint: 'nama@email.com',
                    icon: Icons.email_outlined),
              ),

              const SizedBox(height: 16),

              // ── Password ──
              _sectionLabel('Password *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscurePass,
                textInputAction: TextInputAction.next,
                validator: Validators.validatePassword,
                decoration: _deco(
                  hint: 'Min 8 karakter, ada huruf & angka',
                  icon: Icons.lock_outline_rounded,
                  suffix: _eyeIcon(
                    _obscurePass,
                    () => setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Konfirmasi Password ──
              _sectionLabel('Konfirmasi Password *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmPassCtrl,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    Validators.validateConfirmPassword(v, _passCtrl.text),
                decoration: _deco(
                  hint: 'Ulangi password',
                  icon: Icons.lock_outline_rounded,
                  suffix: _eyeIcon(
                    _obscureConfirm,
                    () => setState(
                        () => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Tanggal Lahir ──
              _sectionLabel('Tanggal Lahir *'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cake_outlined,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDOB != null
                            ? DateFormat('d MMMM yyyy', 'id_ID')
                                .format(_selectedDOB!)
                            : 'Pilih tanggal lahir',
                        style: TextStyle(
                          fontSize: 14,
                          color: _selectedDOB != null
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.calendar_today_outlined,
                          color: AppColors.textHint, size: 18),
                    ],
                  ),
                ),
              ),
              if (_selectedDOB != null) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    'Usia: ${Helpers.calculateAge(_selectedDOB!)} tahun',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textHint),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // ── Lokasi ──
              _sectionLabel('Lokasi / Kota *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lokasiCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleSignUp(),
                validator: Validators.validateLokasi,
                decoration: _deco(
                    hint: 'Contoh: Palembang, Sumatera Selatan',
                    icon: Icons.location_on_outlined),
              ),

              const SizedBox(height: 32),

              // ── Tombol Daftar ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: ctrl.isLoading ? null : _handleSignUp,
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
                      : const Text(AppText.signUp,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 16),

              // Link kembali ke Login
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textHint),
                      children: [
                        TextSpan(text: 'Sudah punya akun? '),
                        TextSpan(
                          text: 'Masuk',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      );

  InputDecoration _deco(
          {required String hint,
          required IconData icon,
          Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.textHint, fontSize: 13),
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

  Widget _eyeIcon(bool obscure, VoidCallback onTap) => IconButton(
        icon: Icon(
          obscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: AppColors.textHint,
          size: 20,
        ),
        onPressed: onTap,
      );
}
