// lib/views/kasus/tambah_progress_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/kasus_controller.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/image_picker_widget.dart';

class TambahProgressView extends StatefulWidget {
  final String laporanId;
  const TambahProgressView({required this.laporanId, Key? key})
      : super(key: key);

  @override
  State<TambahProgressView> createState() => _TambahProgressViewState();
}

class _TambahProgressViewState extends State<TambahProgressView> {
  final _formKey = GlobalKey<FormState>();
  final _deskCtrl = TextEditingController();
  File? _selectedImage;

  @override
  void dispose() {
    _deskCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Foto wajib ada
    if (_selectedImage == null) {
      Helpers.showErrorSnackbar(
          context, 'Foto progress wajib dilampirkan.');
      return;
    }

    final ctrl = context.read<KasusController>();
    final success = await ctrl.addProgressUpdate(
      laporanId: widget.laporanId,
      deskripsi: _deskCtrl.text,
      fotoFile: _selectedImage!,
    );

    if (!mounted) return;

    if (success) {
      Helpers.showSuccessSnackbar(
          context, 'Progress berhasil ditambahkan!');
      Navigator.pop(context);
    } else {
      Helpers.showErrorSnackbar(
          context, ctrl.errorMessage ?? 'Gagal menambah progress.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<KasusController>();
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tambah Progress'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.update_rounded,
                            color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Update Progress Pengerjaan',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Foto wajib dilampirkan sebagai bukti pengerjaan. Timestamp akan otomatis tercatat.',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary.withOpacity(0.8),
                          height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Timestamp info
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        color: AppColors.textHint, size: 18),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Waktu Progress',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textHint),
                        ),
                        Text(
                          Helpers.formatDateTime(now),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Text(
                        'Otomatis',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Foto progress — WAJIB
              _label('Foto Progress * (Wajib)'),
              const SizedBox(height: 4),
              Text(
                'Foto harus menunjukkan kondisi pengerjaan saat ini',
                style: TextStyle(
                    fontSize: 12,
                    color: _selectedImage == null
                        ? AppColors.error
                        : AppColors.textHint),
              ),
              const SizedBox(height: 10),
              ImagePickerWidget(
                selectedImage: _selectedImage,
                onImageSelected: (f) =>
                    setState(() => _selectedImage = f),
                height: 200,
                hint: 'Ambil Foto Progress',
              ),

              // Indicator foto wajib
              if (_selectedImage == null) ...[
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: AppColors.error, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Foto wajib dilampirkan',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              // Deskripsi progress
              _label('Deskripsi Progress *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _deskCtrl,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                validator: Validators.validateDeskripsiProgress,
                decoration: InputDecoration(
                  hintText:
                      'Jelaskan apa yang sudah dikerjakan hari ini, kendala yang dihadapi, dan rencana selanjutnya...',
                  hintStyle: const TextStyle(
                      color: AppColors.textHint, fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide:
                        const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide:
                        const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide:
                        const BorderSide(color: AppColors.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(
                        color: AppColors.error, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Tombol submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: ctrl.isLoading ? null : _handleSubmit,
                  icon: ctrl.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.upload_rounded, size: 18),
                  label: Text(
                    ctrl.isLoading ? 'Mengunggah...' : 'Simpan Progress',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
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

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      );
}
