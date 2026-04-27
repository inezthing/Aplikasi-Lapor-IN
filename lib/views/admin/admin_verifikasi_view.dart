// lib/views/admin/admin_verifikasi_view.dart
// Admin verifikasi kasus yang user ajukan "Selesai"

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/kasus_controller.dart';
import '../../models/laporan_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/progress_card.dart';

class AdminVerifikasiView extends StatefulWidget {
  const AdminVerifikasiView({Key? key}) : super(key: key);

  @override
  State<AdminVerifikasiView> createState() => _AdminVerifikasiViewState();
}

class _AdminVerifikasiViewState extends State<AdminVerifikasiView> {
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
        title: const Text('Verifikasi Kasus Selesai'),
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
          : ctrl.kasusMenungguVerifikasi.isEmpty
              ? _emptyState(
                  'Tidak ada kasus yang menunggu verifikasi',
                  Icons.verified_outlined,
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ctrl.loadDashboard(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: ctrl.kasusMenungguVerifikasi.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) => _KasusVerifikasiCard(
                      laporan: ctrl.kasusMenungguVerifikasi[i],
                    ),
                  ),
                ),
    );
  }

  Widget _emptyState(String msg, IconData icon) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.border),
            const SizedBox(height: 16),
            Text(msg,
                style: const TextStyle(
                    color: AppColors.textHint, fontSize: 14)),
          ],
        ),
      );
}

// ─────────────────────────────────────────────
// CARD KASUS MENUNGGU VERIFIKASI
// ─────────────────────────────────────────────
class _KasusVerifikasiCard extends StatelessWidget {
  final LaporanModel laporan;
  const _KasusVerifikasiCard({required this.laporan});

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
          // Header kasus
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusBadge(status: laporan.status),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.statusTertundaBg,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Text(
                        'Menunggu Verifikasi',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.statusTertunda,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  laporan.judul,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                _infoRow(Icons.location_on_outlined, laporan.lokasi),
                const SizedBox(height: 4),
                _infoRow(Icons.engineering_outlined,
                    'Petugas: ${laporan.petugasNama ?? '-'}'),
                const SizedBox(height: 4),
                _infoRow(Icons.person_outline_rounded,
                    'Pelapor: ${laporan.pelaporNama ?? '-'}'),
                const SizedBox(height: 4),
                _infoRow(Icons.schedule_rounded,
                    'Diajukan: ${Helpers.formatDateTime(laporan.updatedAt ?? laporan.createdAt)}'),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Tombol lihat detail progress sebelum verifikasi
          _DetailProgressSection(laporanId: laporan.id),

          const Divider(height: 1, color: AppColors.border),

          // Aksi admin
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Tombol Bukti Kurang
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showBuktiKurangDialog(context, laporan.id),
                    icon: const Icon(Icons.close_rounded,
                        size: 16, color: AppColors.error),
                    label: const Text('Bukti Kurang',
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
                // Tombol Setuju Selesai
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showSetujuDialog(context, laporan.id),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Setuju Selesai'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusSelesai,
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
        title: const Text('Setujui Kasus Selesai?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Kasus akan ditandai sebagai SELESAI. Petugas tidak dapat menambah progress lagi.',
              style: TextStyle(
                  color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: catatanCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Catatan admin (opsional)...',
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
              final ok = await ctrl.verifikasiSetujuSelesai(
                laporanId: laporanId,
                catatan: catatanCtrl.text.trim().isEmpty
                    ? null
                    : catatanCtrl.text.trim(),
              );
              if (!context.mounted) return;
              if (ok) {
                Helpers.showSuccessSnackbar(
                    context, 'Kasus berhasil diverifikasi selesai!');
              } else {
                Helpers.showErrorSnackbar(
                    context, ctrl.errorMessage ?? 'Gagal verifikasi.');
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusSelesai),
            child: const Text('Ya, Setujui'),
          ),
        ],
      ),
    );
  }

  void _showBuktiKurangDialog(BuildContext context, String laporanId) {
    final catatanCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text('Bukti Kurang',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Petugas akan diminta menambah bukti progress lagi. Tulis catatan yang jelas.',
              style: TextStyle(
                  color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: catatanCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tulis catatan untuk petugas (wajib)...',
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
              if (catatanCtrl.text.trim().isEmpty) {
                Helpers.showErrorSnackbar(
                    context, 'Catatan wajib diisi.');
                return;
              }
              Navigator.pop(context);
              final ctrl = context.read<AdminController>();
              final ok = await ctrl.verifikasiBuktiKurang(
                laporanId: laporanId,
                catatan: catatanCtrl.text.trim(),
              );
              if (!context.mounted) return;
              if (ok) {
                Helpers.showInfoSnackbar(
                    context, 'Feedback terkirim ke petugas.');
              } else {
                Helpers.showErrorSnackbar(
                    context, ctrl.errorMessage ?? 'Gagal.');
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Kirim Feedback'),
          ),
        ],
      ),
    );
  }
}

// Widget untuk load dan tampilkan progress
class _DetailProgressSection extends StatefulWidget {
  final String laporanId;
  const _DetailProgressSection({required this.laporanId});

  @override
  State<_DetailProgressSection> createState() =>
      _DetailProgressSectionState();
}

class _DetailProgressSectionState extends State<_DetailProgressSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final kasusCtrl = context.watch<KasusController>();

    return Column(
      children: [
        // Toggle lihat progress
        InkWell(
          onTap: () async {
            if (!_expanded) {
              await context
                  .read<KasusController>()
                  .getProgressByLaporan(widget.laporanId);
            }
            setState(() => _expanded = !_expanded);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.update_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  _expanded ? 'Sembunyikan Progress' : 'Lihat Bukti Progress',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: kasusCtrl.currentProgressList.isEmpty
                ? const Text(
                    'Belum ada progress',
                    style: TextStyle(color: AppColors.textHint),
                  )
                : Column(
                    children: kasusCtrl.currentProgressList
                        .map((p) => ProgressCard(progress: p))
                        .toList(),
                  ),
          ),
        ],
      ],
    );
  }
}
