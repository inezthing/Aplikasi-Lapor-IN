// lib/views/admin/admin_pemerintah_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';
import '../../models/laporan_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/status_badge.dart';

class AdminPemerintahView extends StatefulWidget {
  const AdminPemerintahView({Key? key}) : super(key: key);

  @override
  State<AdminPemerintahView> createState() => _AdminPemerintahViewState();
}

class _AdminPemerintahViewState extends State<AdminPemerintahView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AdminController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kasus ke Pemerintah'),
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ctrl.loadDashboard(),
          ),
        ],
      ),
      body: ctrl.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2))
          : ctrl.kasusDiteruskan.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_balance_outlined,
                          size: 64, color: AppColors.border),
                      const SizedBox(height: 16),
                      const Text(
                        'Tidak ada kasus yang diteruskan\nke pemerintah saat ini',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textHint, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ctrl.loadDashboard(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: ctrl.kasusDiteruskan.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) => _KasusPemerintahCard(
                      laporan: ctrl.kasusDiteruskan[i],
                    ),
                  ),
                ),
    );
  }
}

class _KasusPemerintahCard extends StatelessWidget {
  final LaporanModel laporan;
  const _KasusPemerintahCard({required this.laporan});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.statusTertundaBg,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_balance_outlined,
                              size: 12, color: AppColors.statusTertunda),
                          SizedBox(width: 4),
                          Text(
                            'Menunggu Persetujuan Admin',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.statusTertunda,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  laporan.judul,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                _infoRow(Icons.category_outlined, laporan.kategori),
                const SizedBox(height: 4),
                _infoRow(Icons.location_on_outlined, laporan.lokasi),
                const SizedBox(height: 4),
                _infoRow(Icons.engineering_outlined,
                    'Petugas: ${laporan.petugasNama ?? '-'}'),
                const SizedBox(height: 4),
                _infoRow(Icons.schedule_rounded,
                    'Diajukan: ${Helpers.formatDateTime(laporan.updatedAt ?? laporan.createdAt)}'),
                const SizedBox(height: 12),

                // Deskripsi singkat
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    laporan.deskripsi,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Catatan admin sebelumnya (jika ada penolakan sebelumnya)
                if (laporan.dibatalkanAlasan != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorBg,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                          color: AppColors.error.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catatan penolakan sebelumnya:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          laporan.dibatalkanAlasan!,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Aksi admin
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppColors.primary, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Jika disetujui, kasus akan berstatus "Diteruskan ke Pemerintah". '
                          'Jika ditolak, kasus dikembalikan ke daftar tersedia.',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Tolak
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showTolakDialog(context, laporan.id),
                        icon: const Icon(Icons.cancel_outlined,
                            size: 16, color: AppColors.error),
                        label: const Text('Tolak',
                            style: TextStyle(color: AppColors.error)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Setujui teruskan
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _showSetujuDialog(context, laporan.id),
                        icon: const Icon(Icons.send_rounded, size: 16),
                        label: const Text('Teruskan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusTertunda,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 13, color: AppColors.textHint),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );

  void _showSetujuDialog(BuildContext context, String laporanId) {
    final catatanCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text('Teruskan ke Pemerintah?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Kasus ini akan berstatus "Diteruskan ke Pemerintah" dan menjadi referensi untuk penanganan lebih lanjut.',
              style: TextStyle(
                  color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: catatanCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Catatan tambahan (opsional)...',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textHint)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final ctrl = context.read<AdminController>();
              final ok = await ctrl.verifikasiSetujuTerusan(
                laporanId: laporanId,
                catatan: catatanCtrl.text.trim().isEmpty
                    ? null
                    : catatanCtrl.text.trim(),
              );
              if (!context.mounted) return;
              if (ok) {
                Helpers.showSuccessSnackbar(
                    context, 'Kasus berhasil diteruskan ke pemerintah!');
              } else {
                Helpers.showErrorSnackbar(
                    context, ctrl.errorMessage ?? 'Gagal.');
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusTertunda),
            child: const Text('Ya, Teruskan'),
          ),
        ],
      ),
    );
  }

  void _showTolakDialog(BuildContext context, String laporanId) {
    final alasanCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text('Tolak Penerusan?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Kasus akan dikembalikan ke daftar tersedia untuk umum. '
              'Alasan penolakan akan disimpan sebagai catatan.',
              style: TextStyle(
                  color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: alasanCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tulis alasan penolakan (wajib)...',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textHint)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (alasanCtrl.text.trim().isEmpty) {
                Helpers.showErrorSnackbar(
                    context, 'Alasan penolakan wajib diisi.');
                return;
              }
              Navigator.pop(context);
              final ctrl = context.read<AdminController>();
              final ok = await ctrl.verifikasiTolakTerusan(
                laporanId: laporanId,
                alasan: alasanCtrl.text.trim(),
              );
              if (!context.mounted) return;
              if (ok) {
                Helpers.showInfoSnackbar(context,
                    'Kasus ditolak dan dikembalikan ke daftar tersedia.');
              } else {
                Helpers.showErrorSnackbar(
                    context, ctrl.errorMessage ?? 'Gagal.');
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Tolak & Kembalikan'),
          ),
        ],
      ),
    );
  }
}
