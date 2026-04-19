// lib/views/kasus/detail_kasus_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/laporan_controller.dart';
import '../../controllers/kasus_controller.dart';
import '../../models/laporan_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/progress_card.dart';
import 'tambah_progress_view.dart';

class DetailKasusView extends StatefulWidget {
  final String laporanId;
  const DetailKasusView({required this.laporanId, Key? key}) : super(key: key);

  @override
  State<DetailKasusView> createState() => _DetailKasusViewState();
}

class _DetailKasusViewState extends State<DetailKasusView> {
  LaporanModel? _laporan;
  bool _isLoadingLaporan = true;
  bool _canComplete = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final lapCtrl = context.read<LaporanController>();
    final kasusCtrl = context.read<KasusController>();

    final laporan = await lapCtrl.getLaporanById(widget.laporanId);
    await kasusCtrl.getProgressByLaporan(widget.laporanId);

    if (laporan != null) {
      final canComplete =
          await kasusCtrl.canMarkAsComplete(widget.laporanId);
      if (mounted) {
        setState(() {
          _laporan = laporan;
          _canComplete = canComplete;
          _isLoadingLaporan = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoadingLaporan = false);
    }
  }

  Future<void> _handleAmbilKasus() async {
    final confirm = await Helpers.showConfirmDialog(
      context: context,
      title: 'Ambil Kasus Ini?',
      message:
          'Kamu akan bertanggung jawab menangani laporan "${_laporan!.judul}". Kasus ini tidak bisa diambil orang lain setelah kamu konfirmasi.',
      confirmText: 'Ya, Ambil',
    );
    if (!confirm || !mounted) return;

    final ctrl = context.read<KasusController>();
    final success = await ctrl.ambilKasus(widget.laporanId);

    if (!mounted) return;
    if (success) {
      Helpers.showSuccessSnackbar(context, 'Kasus berhasil diambil!');
      _loadData();
    } else {
      Helpers.showErrorSnackbar(
          context, ctrl.errorMessage ?? 'Gagal mengambil kasus.');
    }
  }

  Future<void> _handleSelesaikan() async {
    if (!_canComplete) {
      Helpers.showErrorSnackbar(context,
          'Tambahkan minimal 1 progress terlebih dahulu sebelum menyelesaikan kasus.');
      return;
    }

    final confirm = await Helpers.showConfirmDialog(
      context: context,
      title: 'Tandai Selesai?',
      message:
          'Pastikan perbaikan benar-benar sudah selesai. Status tidak bisa dikembalikan ke sebelumnya.',
      confirmText: 'Selesai',
      confirmColor: AppColors.statusSelesai,
    );
    if (!confirm || !mounted) return;

    final ctrl = context.read<KasusController>();
    final success = await ctrl.selesaikanKasus(widget.laporanId);

    if (!mounted) return;
    if (success) {
      Helpers.showSuccessSnackbar(context, 'Kasus ditandai selesai!');
      Navigator.pop(context);
    } else {
      Helpers.showErrorSnackbar(
          context, ctrl.errorMessage ?? 'Gagal menyelesaikan kasus.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = context.watch<AuthController>();
    final kasusCtrl = context.watch<KasusController>();
    final currentUserId = authCtrl.currentUser?.id;

    if (_isLoadingLaporan) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2)),
      );
    }

    if (_laporan == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Laporan tidak ditemukan')),
      );
    }

    final lap = _laporan!;
    final isMyCase = lap.isHandledBy(currentUserId ?? '');
    final isMyReport = lap.isSubmittedBy(currentUserId ?? '');
    final isAvailable = !lap.isLocked;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero image app bar
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.textPrimary, size: 20),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: lap.fotoUrl != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: lap.fotoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                              color: AppColors.primaryBg),
                          errorWidget: (_, __, ___) =>
                              Container(color: AppColors.primaryBg,
                                  child: const Icon(Icons.image_outlined,
                                      color: AppColors.primary, size: 48)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.5)
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: AppColors.primaryBg,
                      child: const Center(
                        child: Icon(Icons.report_problem_rounded,
                            color: AppColors.primary, size: 70),
                      ),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status + kategori + tanggal
                  Row(
                    children: [
                      StatusBadge(status: lap.status),
                      const SizedBox(width: 8),
                      _chip(lap.kategori),
                      const Spacer(),
                      Text(
                        Helpers.formatDate(lap.createdAt),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textHint),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Judul
                  Text(
                    lap.judul,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Lokasi
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBg,
                          borderRadius:
                              BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(Icons.location_on_rounded,
                            color: AppColors.primary, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          lap.lokasi,
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),

                  // Info pelapor
                  if (lap.pelaporNama != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBg,
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Icon(Icons.person_outline_rounded,
                              color: AppColors.primary, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Dilaporkan oleh ${lap.pelaporNama}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],

                  // Info petugas
                  if (lap.petugasNama != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBg,
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Icon(Icons.engineering_outlined,
                              color: AppColors.primary, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Ditangani oleh ${lap.petugasNama}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Divider(color: AppColors.border, thickness: 1),
                  const SizedBox(height: 16),

                  // Deskripsi
                  const Text(
                    'Deskripsi Kerusakan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      lap.deskripsi,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Timeline progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Update Progress',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (isMyCase)
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TambahProgressView(
                                laporanId: widget.laporanId,
                              ),
                            ),
                          ).then((_) => _loadData()),
                          icon: const Icon(Icons.add_rounded,
                              size: 16, color: AppColors.primary),
                          label: const Text(
                            AppText.tambahProgress,
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            backgroundColor: AppColors.primaryBg,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (kasusCtrl.currentProgressList.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.update_outlined,
                              color: AppColors.border, size: 36),
                          SizedBox(height: 10),
                          Text(
                            'Belum ada update progress',
                            style: TextStyle(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    )
                  else
                    ...kasusCtrl.currentProgressList
                        .map((p) => ProgressCard(progress: p))
                        .toList(),

                  const SizedBox(height: 24),

                  // ── Action Buttons ──
                  // Ambil kasus (jika tersedia & bukan milik sendiri)
                  if (isAvailable && !isMyReport)
                    _ActionCard(
                      icon: Icons.engineering_outlined,
                      title: 'Ambil Kasus Ini',
                      subtitle:
                          'Kamu akan bertanggung jawab menangani laporan ini',
                      buttonText: AppText.ambilKasus,
                      buttonColor: AppColors.primary,
                      onPressed: kasusCtrl.isLoading
                          ? null
                          : _handleAmbilKasus,
                      isLoading: kasusCtrl.isLoading,
                    ),

                  // Tandai selesai (jika kasus milik user ini & ada progress)
                  if (isMyCase &&
                      lap.status != AppStatus.selesai) ...[
                    if (_canComplete)
                      _ActionCard(
                        icon: Icons.check_circle_outline_rounded,
                        title: 'Tandai Kasus Selesai',
                        subtitle:
                            'Perbaikan sudah selesai dilakukan',
                        buttonText: AppText.tandaiSelesai,
                        buttonColor: AppColors.statusSelesai,
                        onPressed: kasusCtrl.isLoading
                            ? null
                            : _handleSelesaikan,
                        isLoading: kasusCtrl.isLoading,
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.statusTertundaBg,
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                              color: AppColors.statusTertunda
                                  .withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: AppColors.statusTertunda, size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tambahkan minimal 1 progress sebelum bisa menyelesaikan kasus ini.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.statusTertunda,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],

                  // Sudah selesai badge
                  if (lap.status == AppStatus.selesai)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.statusSelesaiBg,
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                            color: AppColors.statusSelesai
                                .withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: AppColors.statusSelesai, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Kasus ini sudah selesai ditangani',
                            style: TextStyle(
                              color: AppColors.statusSelesai,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
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

  Widget _chip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textHint)),
      );
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.buttonColor,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: buttonColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: buttonColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: buttonColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: buttonColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                  height: 1.4)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(buttonText,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
