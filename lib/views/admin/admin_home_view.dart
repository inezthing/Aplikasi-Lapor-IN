// lib/views/admin/admin_home_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../auth/login_view.dart';
import 'admin_verifikasi_view.dart';
import 'admin_pemerintah_view.dart';

class AdminHomeView extends StatefulWidget {
  const AdminHomeView({Key? key}) : super(key: key);

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  int _tab = 0; // 0=dashboard, 1=verifikasi, 2=pemerintah

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _DashboardTab(onGoTo: (i) => setState(() => _tab = i)),
      const AdminVerifikasiView(),
      const AdminPemerintahView(),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: tabs),
      bottomNavigationBar: _buildNav(),
    );
  }

  Widget _buildNav() {
    final ctrl = context.watch<AdminController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
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
              _navItem(0, Icons.dashboard_rounded,
                  Icons.dashboard_outlined, 'Dashboard'),
              _navItemBadge(
                1,
                Icons.verified_rounded,
                Icons.verified_outlined,
                'Verifikasi',
                ctrl.totalMenunggu,
              ),
              _navItemBadge(
                2,
                Icons.account_balance_rounded,
                Icons.account_balance_outlined,
                'Pemerintah',
                ctrl.totalDiteruskan,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData active, IconData inactive, String label) {
    final isActive = _tab == idx;
    return GestureDetector(
      onTap: () => setState(() => _tab = idx),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? active : inactive,
                color: isActive ? AppColors.primary : AppColors.textHint,
                size: 24),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isActive ? AppColors.primary : AppColors.textHint,
                )),
          ],
        ),
      ),
    );
  }

  Widget _navItemBadge(int idx, IconData active, IconData inactive,
      String label, int count) {
    final isActive = _tab == idx;
    return GestureDetector(
      onTap: () => setState(() => _tab = idx),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(isActive ? active : inactive,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textHint,
                    size: 24),
                if (count > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                          minWidth: 16, minHeight: 16),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isActive ? AppColors.primary : AppColors.textHint,
                )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DASHBOARD TAB
// ─────────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  final Function(int) onGoTo;
  const _DashboardTab({required this.onGoTo});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AdminController>();
    final authCtrl = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ctrl.loadDashboard(),
        child: CustomScrollView(
          slivers: [
            // Header admin
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A2060), AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(28)),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2),
                              ),
                              child: const Icon(
                                  Icons.admin_panel_settings_rounded,
                                  color: Colors.white,
                                  size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Halo, ${authCtrl.currentUser?.fullName ?? 'Admin'}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Text(
                                    'Panel Administrator',
                                    style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            // Logout
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.logout_rounded,
                                    color: Colors.white, size: 18),
                              ),
                              onPressed: () =>
                                  _handleLogout(context, authCtrl),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Stats grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.2,
                          children: [
                            _statCard('Total Laporan',
                                '${ctrl.totalLaporan}', Icons.article_outlined),
                            _statCard('Aktif Dikerjakan',
                                '${ctrl.totalAktif}', Icons.engineering_outlined),
                            _statCard(
                              'Menunggu Verifikasi',
                              '${ctrl.totalMenunggu}',
                              Icons.pending_actions_rounded,
                              highlight: ctrl.totalMenunggu > 0,
                            ),
                            _statCard(
                              'Ke Pemerintah',
                              '${ctrl.totalDiteruskan}',
                              Icons.account_balance_outlined,
                              highlight: ctrl.totalDiteruskan > 0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Aksi cepat
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: const Text(
                  'Aksi Cepat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _quickAction(
                    context,
                    icon: Icons.verified_outlined,
                    title: 'Verifikasi Kasus Selesai',
                    subtitle: '${ctrl.totalMenunggu} kasus menunggu persetujuan',
                    badge: ctrl.totalMenunggu,
                    color: AppColors.primary,
                    onTap: () => onGoTo(1),
                  ),
                  const SizedBox(height: 10),
                  _quickAction(
                    context,
                    icon: Icons.account_balance_outlined,
                    title: 'Kasus ke Pemerintah',
                    subtitle:
                        '${ctrl.totalDiteruskan} kasus menunggu persetujuan',
                    badge: ctrl.totalDiteruskan,
                    color: AppColors.statusTertunda,
                    onTap: () => onGoTo(2),
                  ),
                  const SizedBox(height: 10),
                  _quickAction(
                    context,
                    icon: Icons.list_alt_rounded,
                    title: 'Semua Laporan',
                    subtitle: '${ctrl.totalLaporan} total laporan terdaftar',
                    badge: 0,
                    color: AppColors.statusSelesai,
                    onTap: () {},
                  ),
                  const SizedBox(height: 30),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon,
      {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlight
            ? Colors.white.withOpacity(0.25)
            : Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: highlight
              ? Colors.white.withOpacity(0.5)
              : Colors.white.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    )),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required int badge,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textHint)),
                ],
              ),
            ),
            if (badge > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text('$badge',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(
      BuildContext context, AuthController ctrl) async {
    final confirm = await Helpers.showConfirmDialog(
      context: context,
      title: 'Keluar',
      message: 'Keluar dari panel admin?',
      confirmText: 'Keluar',
      confirmColor: AppColors.error,
    );
    if (!confirm || !context.mounted) return;
    await ctrl.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (_) => false,
    );
  }
}
