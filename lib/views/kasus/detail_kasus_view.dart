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
    if (!mounted) return;
    setState(() => _isLoadingLaporan = true);

    final lapCtrl = context.read<LaporanController>();
    final kasusCtrl = context.read<KasusController>();

    final laporan = await lapCtrl.getLaporanById(widget.laporanId);
    await kasusCtrl.getProgressByLaporan(widget.laporanId);

    if (!mounted) return;

    if (laporan != null) {
      final canComplete = await kasusCtrl.canMarkAsComplete(widget.laporanId);
      setState(() {
        _laporan = laporan;
        _canComplete = canComplete;
        _isLoadingLaporan = false;
      });
    } else {
      setState(() => _isLoadingLaporan = false);
    }
  }

  Future<void> _handleAmbilKasus() async {
    final confirm = await Helpers.showConfirmDialog(
      context: context,
      title: 'Ambil Kasus Ini?',
      message:
          'Kamu akan bertanggung jawab menangani laporan "${_laporan!.judul}". '
          'Kasus ini tidak bisa diambil orang lain setelah kamu konfirmasi.',
      confirmText: 'Ya, Ambil',
    );
    if (!confirm || !mounted) return;

    final ctrl = context.read<KasusController>();
    final success = await ctrl.ambilKasus(widget.laporanId);

    if (!mounted) return;
    if (success) {
      Helpers.showSuccessSnackbar(context, 'Kasus berhasil diambil!');
      await _loadData();
      if (mounted) {
        await context.read<LaporanController>().getAvailableLaporan();
      }
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
          'Pastikan perbaikan benar-benar sudah selesai. '
          'Admin akan memverifikasi laporan ini.',
      confirmText: 'Selesai',
      confirmColor: AppColors.statusSelesai,
    );
    if (!confirm || !mounted) return;

    final ctrl = context.read<KasusController>();
    final success = await ctrl.selesaikanKasus(widget.laporanId);

    if (!mounted) return;
    if (success) {
      Helpers.showSuccessSnackbar(
          context, 'Kasus diajukan ke admin untuk diverifikasi.');
      await _loadData();
    } else {
      Helpers.showErrorSnackbar(
          context, ctrl.errorMessage ?? 'Gagal menyelesaikan kasus.');
    }
  }

  // ─────────────────────────────────────────────
  // HANDLER: Teruskan ke Pemerintah
  // Muncul dialog pilihan: Selesaikan sendiri ATAU Teruskan
  // ─────────────────────────────────────────────
  Future<void> _handleTeruskankePemerintah() async {
    if (!_canComplete) {
      Helpers.showErrorSnackbar(context,
          'Tambahkan minimal 1 progress/bukti sebelum meneruskan ke pemerintah.');
      return;
    }

    // Dialog konfirmasi dengan penjelasan dampak
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Row(
          children: [
            Icon(Icons.account_balance_outlined,
                color: AppColors.warning, size: 22),
            SizedBox(width: 8),
            Text(
              'Teruskan ke Pemerintah?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Text(
          'Kasus ini akan diteruskan ke instansi pemerintah terkait untuk ditindaklanjuti.\n\n'
          'Kamu tidak lagi menjadi penanggung jawab utama setelah diteruskan. '
          'Admin akan memverifikasi permintaan ini terlebih dahulu.',
          style: TextStyle(
              fontSize: 13, color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textHint)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            child: const Text('Ya, Teruskan',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final ctrl = context.read<KasusController>();
    final success = await ctrl.teruskankePemerintah(widget.laporanId);

    if (!mounted) return;
    if (success) {
      Helpers.showSuccessSnackbar(
          context, 'Kasus diteruskan ke pemerintah. Menunggu verifikasi admin.');
      await _loadData();
    } else {
      Helpers.showErrorSnackbar(
          context, ctrl.errorMessage ?? 'Gagal meneruskan ke pemerintah.');
    }
  }

  // ─────────────────────────────────────────────
  // HANDLER: Batalkan Kasus
  // ─────────────────────────────────────────────
  Future<void> _handleBatalkan() async {
    final alasanCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text('Batalkan Penanganan?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kasus akan dikembalikan ke daftar tersedia. Tulis alasan pembatalan:',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: alasanCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Tidak bisa dijangkau, bukan wilayah saya...',
                hintStyle:
                    const TextStyle(fontSize: 12, color: AppColors.textHint),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textHint)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            child: const Text('Batalkan Kasus',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    if (alasanCtrl.text.trim().isEmpty) {
      Helpers.showErrorSnackbar(context, 'Alasan pembatalan wajib diisi.');
      return;
    }

    final ctrl = context.read<KasusController>();
    final success = await ctrl.batalkanKasus(
      laporanId: widget.laporanId,
      alasan: alasanCtrl.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      Helpers.showSuccessSnackbar(context, 'Penanganan kasus dibatalkan.');
      Navigator.pop(context);
    } else {
      Helpers.showErrorSnackbar(
          context, ctrl.errorMessage ?? 'Gagal membatalkan kasus.');
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

    final isMyCase = currentUserId != null && lap.petugasId == currentUserId;
    final isMyReport = currentUserId != null && lap.pelaporId == currentUserId;
    final isAvailable = !lap.isLocked;

    // Status flags untuk kontrol tombol
    final isMenungguVerifikasi = lap.verifikasiStatus == 'menunggu_verifikasi';
    final isDiteruskan = lap.diteruskanKePemerintah;
    final isBuktiKurang = lap.verifikasiStatus == 'bukti_kurang';
    final isSelesai = lap.status == AppStatus.selesai ||
        lap.status == AppStatus.diteruskan;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
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
                          placeholder: (_, __) =>
                              Container(color: AppColors.primaryBg),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.primaryBg,
                            child: const Icon(Icons.image_outlined,
                                color: AppColors.primary, size: 48),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.4),
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

                  _infoRow(Icons.location_on_rounded, lap.lokasi),

                  if (lap.pelaporNama != null) ...[
                    const SizedBox(height: 8),
                    _infoRow(Icons.person_outline_rounded,
                        'Dilaporkan oleh ${lap.pelaporNama}'),
                  ],

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

                  // ── Progress Section ──
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
                      // Tombol Tambah Progress: hanya jika aktif menangani
                      // dan kasus belum selesai/diteruskan/menunggu verifikasi
                      if (isMyCase &&
                          !isSelesai &&
                          !isMenungguVerifikasi &&
                          !isDiteruskan)
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
                            'Tambah Progress',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
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

                  // ══════════════════════════════════════
                  // ACTION BUTTONS
                  // ══════════════════════════════════════

                  // [1] Ambil Kasus — tersedia dan bukan laporan sendiri
                  if (isAvailable && !isMyReport)
                    _ActionCard(
                      icon: Icons.engineering_outlined,
                      title: 'Ambil Kasus Ini',
                      subtitle:
                          'Kamu akan bertanggung jawab menangani laporan ini',
                      buttonText: 'Ambil Kasus Ini',
                      buttonColor: AppColors.primary,
                      onPressed:
                          kasusCtrl.isLoading ? null : _handleAmbilKasus,
                      isLoading: kasusCtrl.isLoading,
                    ),

                  // [2] Tombol aksi untuk petugas yang menangani (non-selesai)
                  if (isMyCase && !isSelesai) ...[

                    // [2a] Bukti kurang — admin minta tambah progress lagi
                    if (isBuktiKurang)
                      _InfoBanner(
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.error,
                        message:
                            'Admin meminta bukti tambahan. Tambahkan progress baru, '
                            'lalu ajukan kembali.',
                        note: lap.verifikasiCatatan,
                      ),

                    // [2b] Sudah diajukan, menunggu admin
                    if (isMenungguVerifikasi && !isDiteruskan)
                      _InfoBanner(
                        icon: Icons.hourglass_top_rounded,
                        color: AppColors.warning,
                        message:
                            'Kasus sedang menunggu verifikasi admin. Tidak perlu tindakan.',
                      ),

                    // [2c] Sudah diteruskan, menunggu admin
                    if (isDiteruskan)
                      _InfoBanner(
                        icon: Icons.account_balance_outlined,
                        color: AppColors.warning,
                        message:
                            'Kasus telah diteruskan ke pemerintah. Menunggu verifikasi admin.',
                      ),

                    // [2d] Tombol aksi — hanya tampil jika belum ada pending verifikasi
                    if (!isMenungguVerifikasi && !isDiteruskan) ...[
                      if (_canComplete) ...[
                        // Tombol Selesaikan
                        _ActionCard(
                          icon: Icons.check_circle_outline_rounded,
                          title: 'Tandai Kasus Selesai',
                          subtitle:
                              'Kamu sudah menangani kasus ini. Admin akan memverifikasi.',
                          buttonText: 'Tandai Selesai',
                          buttonColor: AppColors.statusSelesai,
                          onPressed: kasusCtrl.isLoading
                              ? null
                              : _handleSelesaikan,
                          isLoading: kasusCtrl.isLoading,
                        ),

                        // Tombol Teruskan ke Pemerintah
                        _ActionCard(
                          icon: Icons.account_balance_outlined,
                          title: 'Teruskan ke Pemerintah',
                          subtitle:
                              'Kasus membutuhkan penanganan instansi pemerintah. '
                              'Admin akan memverifikasi permintaan ini.',
                          buttonText: 'Teruskan ke Pemerintah',
                          buttonColor: AppColors.warning,
                          onPressed: kasusCtrl.isLoading
                              ? null
                              : _handleTeruskankePemerintah,
                          isLoading: kasusCtrl.isLoading,
                        ),
                      ] else
                        // Belum ada progress
                        _InfoBanner(
                          icon: Icons.info_outline_rounded,
                          color: AppColors.statusTertunda,
                          message:
                              'Tambahkan minimal 1 progress sebelum bisa menyelesaikan '
                              'atau meneruskan kasus ini ke pemerintah.',
                        ),

                      // Tombol Batalkan (selalu ada selama aktif menangani)
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: kasusCtrl.isLoading
                              ? null
                              : _handleBatalkan,
                          icon: const Icon(Icons.cancel_outlined,
                              size: 16, color: AppColors.error),
                          label: const Text('Batalkan Penanganan',
                              style: TextStyle(color: AppColors.error)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            padding:
                                const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],

                  // [3] Badge selesai
                  if (lap.status == AppStatus.selesai)
                    _InfoBanner(
                      icon: Icons.check_circle_rounded,
                      color: AppColors.statusSelesai,
                      message: 'Kasus ini sudah selesai ditangani dan diverifikasi admin.',
                    ),

                  // [4] Badge diteruskan ke pemerintah
                  if (lap.status == AppStatus.diteruskan)
                    _InfoBanner(
                      icon: Icons.account_balance_rounded,
                      color: AppColors.primary,
                      message:
                          'Kasus ini telah diteruskan dan diverifikasi admin untuk ditangani pemerintah.',
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
            style:
                const TextStyle(fontSize: 12, color: AppColors.textHint)),
      );

  Widget _infoRow(IconData icon, String text) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary)),
          ),
        ],
      );
}

// ─────────────────────────────────────────────
// ACTION CARD
// ─────────────────────────────────────────────
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
      margin: const EdgeInsets.only(bottom: 12),
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
                  fontSize: 12, color: AppColors.textHint, height: 1.4)),
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

// ─────────────────────────────────────────────
// INFO BANNER (menggantikan _ActionCard untuk status-only)
// ─────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  final String? note;

  const _InfoBanner({
    required this.icon,
    required this.color,
    required this.message,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                      fontSize: 13, color: color, height: 1.4,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          if (note != null && note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Catatan admin: $note',
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                  height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

