// lib/views/laporan/buat_laporan_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/laporan_controller.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/image_picker_widget.dart';

class BuatLaporanView extends StatefulWidget {
  const BuatLaporanView({Key? key}) : super(key: key);

  @override
  State<BuatLaporanView> createState() => _BuatLaporanViewState();
}

class _BuatLaporanViewState extends State<BuatLaporanView> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _lokasiCtrl = TextEditingController();
  final _deskCtrl = TextEditingController();
  String? _selectedKategori;
  File? _selectedImage;

  @override
  void dispose() {
    _judulCtrl.dispose();
    _lokasiCtrl.dispose();
    _deskCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final ctrl = context.read<LaporanController>();
    final success = await ctrl.createLaporan(
      judul: _judulCtrl.text,
      kategori: _selectedKategori!,
      lokasi: _lokasiCtrl.text,
      deskripsi: _deskCtrl.text,
      fotoFile: _selectedImage,
    );

    if (!mounted) return;

    if (success) {
      Helpers.showSuccessSnackbar(
          context, 'Laporan berhasil dikirim! Terima kasih.');
      _resetForm();
    } else {
      Helpers.showErrorSnackbar(
          context, ctrl.errorMessage ?? 'Gagal mengirim laporan.');
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _judulCtrl.clear();
    _lokasiCtrl.clear();
    _deskCtrl.clear();
    setState(() {
      _selectedKategori = null;
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<LaporanController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buat Laporan'),
        backgroundColor: Colors.white,
        leading: const SizedBox(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.report_problem_rounded,
                        color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Laporkan Keluhanmu!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Isi form dengan lengkap agar laporan dapat diproses',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ── Judul ──
              _label('Judul Laporan *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _judulCtrl,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator: Validators.validateJudulLaporan,
                decoration: _deco(
                  hint: 'Contoh: Jalan berlubang di depan pasar',
                  icon: Icons.title_rounded,
                ),
              ),

              const SizedBox(height: 16),

              // ── Kategori ──
              _label('Kategori *'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                validator: Validators.validateKategori,
                decoration: _deco(
                  hint: 'Pilih kategori laporan',
                  icon: Icons.category_rounded,
                ),
                items: AppKategori.list
                    .map((k) => DropdownMenuItem(
                          value: k,
                          child: Text(k, style: const TextStyle(fontSize: 14)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedKategori = v),
                borderRadius: BorderRadius.circular(AppRadius.md),
                dropdownColor: Colors.white,
              ),

              const SizedBox(height: 16),

              // ── Lokasi ──
              _label('Lokasi Kejadian *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lokasiCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: Validators.validateLokasiKejadian,
                decoration: _deco(
                  hint: 'Contoh: Jl. Sudirman No. 5, dekat lampu merah',
                  icon: Icons.location_on_outlined,
                ),
              ),

              const SizedBox(height: 16),

              // ── Deskripsi ──
              _label('Deskripsi Kerusakan *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _deskCtrl,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                validator: Validators.validateDeskripsi,
                decoration: InputDecoration(
                  hintText:
                      'Jelaskan secara detail kondisi kerusakan, kapan pertama kali ditemukan, dampaknya, dll...',
                  hintStyle: const TextStyle(
                      color: AppColors.textHint, fontSize: 13),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 64, left: 4),
                    child: Icon(Icons.description_outlined,
                        color: AppColors.primary, size: 20),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
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
                ),
              ),

              const SizedBox(height: 16),

              // ── Foto ──
              _label('Bukti Foto (opsional)'),
              const SizedBox(height: 4),
              const Text(
                'Foto akan membantu proses verifikasi laporan',
                style:
                    TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
              const SizedBox(height: 10),
              ImagePickerWidget(
                selectedImage: _selectedImage,
                onImageSelected: (f) =>
                    setState(() => _selectedImage = f),
                height: 160,
                hint: 'Tambah Foto Bukti',
              ),

              const SizedBox(height: 30),

              // ── Tombol Kirim ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: ctrl.isLoading ? null : _handleSubmit,
                  icon: ctrl.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(
                    ctrl.isLoading
                        ? 'Mengirim...'
                        : AppText.kirimLaporan,
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
