// lib/views/profil/edit_profil_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/image_picker_widget.dart';

class EditProfilView extends StatefulWidget {
  const EditProfilView({Key? key}) : super(key: key);

  @override
  State<EditProfilView> createState() => _EditProfilViewState();
}

class _EditProfilViewState extends State<EditProfilView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaCtrl;
  late TextEditingController _lokasiCtrl;
  DateTime? _selectedDOB;
  File? _newAvatarFile;
  bool _avatarChanged = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().currentUser;
    _namaCtrl = TextEditingController(text: user?.fullName ?? '');
    _lokasiCtrl = TextEditingController(text: user?.lokasi ?? '');
    _selectedDOB = user?.dateOfBirth;
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _lokasiCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDOB ??
          DateTime(now.year - 25, now.month, now.day),
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final dobError = Validators.validateDateOfBirth(_selectedDOB);
    if (dobError != null) {
      Helpers.showErrorSnackbar(context, dobError);
      return;
    }

    final ctrl = context.read<AuthController>();

    // Upload avatar baru jika ada
    if (_avatarChanged && _newAvatarFile != null) {
      final avatarSuccess =
          await ctrl.updateProfilePicture(_newAvatarFile!);
      if (!avatarSuccess && mounted) {
        Helpers.showErrorSnackbar(
            context, ctrl.errorMessage ?? 'Gagal upload foto profil.');
        return;
      }
    }

    // Update data profil
    final success = await ctrl.updateProfile(
      fullName: _namaCtrl.text,
      lokasi: _lokasiCtrl.text,
      dateOfBirth: _selectedDOB!,
    );

    if (!mounted) return;

    if (success) {
      Helpers.showSuccessSnackbar(context, 'Profil berhasil diperbarui!');
      Navigator.pop(context);
    } else {
      Helpers.showErrorSnackbar(
          context, ctrl.errorMessage ?? 'Gagal memperbarui profil.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AuthController>();
    final user = ctrl.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: ctrl.isLoading ? null : _handleSave,
            child: ctrl.isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2))
                : const Text(
                    'Simpan',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar ──
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.border, width: 2),
                          ),
                          child: _avatarChanged && _newAvatarFile != null
                              ? ClipOval(
                                  child: Image.file(_newAvatarFile!,
                                      fit: BoxFit.cover))
                              : user?.avatarUrl != null
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: user!.avatarUrl!,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) =>
                                            _avatarPlaceholder(
                                                user.fullName),
                                      ),
                                    )
                                  : _avatarPlaceholder(user?.fullName),
                        ),
                        GestureDetector(
                          onTap: () => _showAvatarPicker(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _showAvatarPicker,
                      child: const Text(
                        'Ganti Foto Profil',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Nama ──
              _label('Nama Lengkap *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: Validators.validateFullName,
                decoration: _deco(
                    hint: 'Nama lengkap',
                    icon: Icons.person_outline_rounded),
              ),

              const SizedBox(height: 16),

              // ── Tanggal Lahir ──
              _label('Tanggal Lahir *'),
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
                      const Icon(Icons.edit_calendar_outlined,
                          color: AppColors.textHint, size: 18),
                    ],
                  ),
                ),
              ),
              if (_selectedDOB != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Usia: ${Helpers.calculateAge(_selectedDOB!)} tahun',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textHint),
                ),
              ],

              const SizedBox(height: 16),

              // ── Lokasi ──
              _label('Lokasi / Kota *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lokasiCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleSave(),
                validator: Validators.validateLokasi,
                decoration: _deco(
                    hint: 'Contoh: Palembang, Sumatera Selatan',
                    icon: Icons.location_on_outlined),
              ),

              const SizedBox(height: 32),

              // Info email (read-only)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.textHint, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Email (${user?.email ?? ''}) tidak dapat diubah dari aplikasi.',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textHint,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tombol simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: ctrl.isLoading ? null : _handleSave,
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
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Perubahan',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => ImagePickerWidget(
        selectedImage: _newAvatarFile,
        onImageSelected: (f) {
          setState(() {
            _newAvatarFile = f;
            _avatarChanged = true;
          });
          Navigator.pop(context);
        },
        height: 300,
        hint: 'Pilih Foto Profil',
      ),
    );
  }

  Widget _avatarPlaceholder(String? name) {
    return Container(
      color: AppColors.primaryBg,
      child: Center(
        child: Text(
          Helpers.getInitials(name),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 32,
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      );

  InputDecoration _deco({required String hint, required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.textHint, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
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
}
