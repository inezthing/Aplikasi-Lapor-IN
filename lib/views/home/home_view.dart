// lib/views/home/home_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/laporan_controller.dart';
import '../../controllers/kasus_controller.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/laporan_card.dart';
import '../../widgets/my_kasus_card.dart';
import '../../widgets/stat_widget.dart';
import '../laporan/buat_laporan_view.dart';
import '../laporan/kasus_list_view.dart';
import '../kasus/detail_kasus_view.dart';
import '../profil/profil_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final lapCtrl = context.read<LaporanController>();
    final kasusCtrl = context.read<KasusController>();
    await Future.wait([
      lapCtrl.getAvailableLaporan(),
      lapCtrl.getMySubmittedLaporan(),
      kasusCtrl.getMyActiveCases(),
    ]);
  }

  void _navigateTo(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(onNavigate: _navigateTo),
      const BuatLaporanView(),
      const KasusListView(),
      const ProfilView(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, Icons.home_outlined, AppText.home),
              _navItem(1, Icons.add_circle_rounded,
                  Icons.add_circle_outline_rounded, AppText.lapor),
              _navItem(2, Icons.folder_special_rounded,
                  Icons.folder_special_outlined, AppText.kasus),
              _navItem(3, Icons.person_rounded,
                  Icons.person_outline_rounded, AppText.profil),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData activeIcon, IconData inactiveIcon,
      String label) {
    final isActive = _currentIndex == idx;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = idx),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? AppColors.primary : AppColors.textHint,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB KONTEN HOME
// ─────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  final Function(int) onNavigate;
  const _HomeTab({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final authCtrl = context.watch<AuthController>();
    final lapCtrl = context.watch<LaporanController>();
    final kasusCtrl = context.watch<KasusController>();
    final user = authCtrl.currentUser;

    final totalLaporan = lapCtrl.mySubmittedLaporan.length;
    final dikerjakanCount = kasusCtrl.myActiveCases
        .where((k) => k.status == AppStatus.dikerjakan)
        .length;
    final selesaiCount = lapCtrl.mySubmittedLaporan
        .where((l) => l.status == AppStatus.selesai)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await lapCtrl.getAvailableLaporan();
          await lapCtrl.getMySubmittedLaporan();
          await kasusCtrl.getMyActiveCases();
        },
        child: CustomScrollView(
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: _buildHeader(context, user?.fullName, user?.lokasi,
                  totalLaporan, dikerjakanCount, selesaiCount),
            ),

            // ── Widget: Kasus yang Sedang Saya Tangani ──
            if (kasusCtrl.myActiveCases.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kasus yang Saya Tangani',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${kasusCtrl.myActiveCases.length} aktif',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 230,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    itemCount: kasusCtrl.myActiveCases.length,
                    itemBuilder: (ctx, i) {
                      final kasus = kasusCtrl.myActiveCases[i];
                      return MyKasusCard(
                        laporan: kasus,
                        onTap: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) => DetailKasusView(
                              laporanId: kasus.id,
                            ),
                          ),
                        ).then((_) => kasusCtrl.getMyActiveCases()),
                      );
                    },
                  ),
                ),
              ),
            ],

            // ── Widget: Laporan yang Saya Buat ──
            if (lapCtrl.mySubmittedLaporan.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Laporan Saya',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onNavigate(2),
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      if (i >= lapCtrl.mySubmittedLaporan.length) return null;
                      final lap = lapCtrl.mySubmittedLaporan[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: LaporanCard(
                          laporan: lap,
                          showPetugas: true,
                          onTap: () => Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) => DetailKasusView(
                                laporanId: lap.id,
                              ),
                            ),
                          ).then((_) => lapCtrl.getMySubmittedLaporan()),
                        ),
                      );
                    },
                    childCount: lapCtrl.mySubmittedLaporan.length > 3
                        ? 3
                        : lapCtrl.mySubmittedLaporan.length,
                  ),
                ),
              ),
            ],

            // ── Laporan Terbaru (semua) ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Laporan Terkini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onNavigate(2),
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (lapCtrl.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2)),
                ),
              )
            else if (lapCtrl.availableLaporan.isEmpty)
              SliverToBoxAdapter(
                child: _emptyState(
                    'Belum ada laporan tersedia', Icons.inbox_outlined),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      if (i >= lapCtrl.availableLaporan.length) return null;
                      final lap = lapCtrl.availableLaporan[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: LaporanCard(
                          laporan: lap,
                          onTap: () => Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetailKasusView(laporanId: lap.id),
                            ),
                          ).then((_) {
                            lapCtrl.getAvailableLaporan();
                            kasusCtrl.getMyActiveCases();
                          }),
                        ),
                      );
                    },
                    childCount: lapCtrl.availableLaporan.length > 5
                        ? 5
                        : lapCtrl.availableLaporan.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String? nama,
    String? lokasi,
    int total,
    int dikerjakan,
    int selesai,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User row
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 2),
                    ),
                    child: Center(
                      child: Text(
                        Helpers.getInitials(nama),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${nama ?? 'Pengguna'}! 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (lokasi != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  color: Colors.white70, size: 12),
                              const SizedBox(width: 3),
                              Text(
                                lokasi,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      child: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 20),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Widget laporan keluhan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Laporkan Keluhanmu!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bantu perbaiki fasilitas umum di sekitarmu.',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => onNavigate(1),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(AppText.buatLaporan),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Statistik personal
              Row(
                children: [
                  StatWidget(
                    value: '$total',
                    label: 'Laporan Saya',
                    color: Colors.white,
                    bgColor: Colors.white.withOpacity(0.15),
                  ),
                  const SizedBox(width: 10),
                  StatWidget(
                    value: '$dikerjakan',
                    label: 'Dikerjakan',
                    color: Colors.white,
                    bgColor: Colors.white.withOpacity(0.15),
                  ),
                  const SizedBox(width: 10),
                  StatWidget(
                    value: '$selesai',
                    label: 'Selesai',
                    color: Colors.white,
                    bgColor: Colors.white.withOpacity(0.15),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(String msg, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(icon, size: 56, color: AppColors.border),
          const SizedBox(height: 12),
          Text(msg,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textHint)),
        ],
      ),
    );
  }
}
