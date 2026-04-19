// lib/views/profil/profil_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/laporan_controller.dart';
import '../../controllers/kasus_controller.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/stat_widget.dart';
import 'edit_profil_view.dart';
import '../auth/login_view.dart';

class ProfilView extends StatelessWidget {
  const ProfilView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authCtrl = context.watch<AuthController>();
    final lapCtrl = context.watch<LaporanController>();
    final kasusCtrl = context.watch<KasusController>();
    final user = authCtrl.currentUser;

    final totalSubmitted = lapCtrl.mySubmittedLaporan.length;
    final totalHandled = kasusCtrl.myActiveCases.length;
    final selesai = lapCtrl.mySubmittedLaporan
        .where((l) => l.status == AppStatus.selesai)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context, authCtrl, user),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Statistik
                _sectionTitle('Statistik'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    StatWidget(
                      value: '$totalSubmitted',
                      label: 'Dilaporkan',
                      color: AppColors.primary,
                      bgColor: AppColors.primaryBg,
                    ),
                    const SizedBox(width: 10),
                    StatWidget(
                      value: '$totalHandled',
                      label: 'Ditangani',
                      color: AppColors.statusTertunda,
                      bgColor: AppColors.statusTertundaBg,
                    ),
                    const SizedBox(width: 10),
                    StatWidget(
                      value: '$selesai',
                      label: 'Selesai',
                      color: AppColors.statusSelesai,
                      bgColor: AppColors.statusSelesaiBg,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Info pribadi
                _sectionTitle('Informasi Pribadi'),
                const SizedBox(height: 10),
                _infoCard([
                  _infoRow(Icons.person_outline_rounded, 'Nama Lengkap',
                      user?.fullName ?? '-'),
                  _infoRow(Icons.email_outlined, 'Email',
                      user?.email ?? '-'),
                  _infoRow(
                    Icons.cake_outlined,
                    'Tanggal Lahir',
                    user?.dateOfBirth != null
                        ? Helpers.formatDateLong(user!.dateOfBirth!)
                        : '-',
                  ),
                  _infoRow(
                    Icons.person_4_outlined,
                    'Usia',
                    user?.dateOfBirth != null
                        ? '${Helpers.calculateAge(user!.dateOfBirth!)} tahun'
                        : '-',
                  ),
                  _infoRow(Icons.location_on_outlined, 'Lokasi',
                      user?.lokasi ?? '-'),
                  _infoRow(
                    Icons.verified_outlined,
                    'Status Akun',
                    user?.isVerified == true
                        ? 'Terverifikasi'
                        : 'Belum Terverifikasi',
                    valueColor: user?.isVerified == true
                        ? AppColors.statusSelesai
                        : AppColors.statusBelum,
                  ),
                ]),

                const SizedBox(height: 20),

                // Pengaturan
                _sectionTitle('Pengaturan'),
                const SizedBox(height: 10),
                _menuCard([
                  _menuItem(
                    Icons.edit_outlined,
                    'Edit Profil',
                    'Ubah nama, lokasi, tanggal lahir',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfilView()),
                    ),
                  ),
                  _menuItem(
                    Icons.notifications_outlined,
                    'Notifikasi',
                    'Atur preferensi notifikasi',
                    onTap: () {},
                  ),
                  _menuItem(
                    Icons.security_outlined,
                    'Keamanan',
                    'Password dan keamanan akun',
                    onTap: () {},
                  ),
                  _menuItem(
                    Icons.help_outline_rounded,
                    'Bantuan',
                    'Pusat bantuan dan FAQ',
                    onTap: () {},
                  ),
                  _menuItem(
                    Icons.info_outline_rounded,
                    'Tentang Aplikasi',
                    'LaporIn v1.0.0',
                    onTap: () {},
                    showDivider: false,
                  ),
                ]),

                const SizedBox(height: 16),

                // Tombol Logout
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.errorBg),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      onTap: () => _handleLogout(context, authCtrl),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.errorBg,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: const Icon(Icons.logout_rounded,
                                  color: AppColors.error, size: 18),
                            ),
                            const SizedBox(width: 14),
                            const Text(
                              'Keluar',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthController authCtrl, user) {
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profil Saya',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: user?.avatarUrl != null
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: user!.avatarUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                  color: Colors.white.withOpacity(0.2)),
                              errorWidget: (_, __, ___) => Center(
                                child: Text(
                                  Helpers.getInitials(user.fullName),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              Helpers.getInitials(user?.fullName),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 28,
                              ),
                            ),
                          ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfilView()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: AppColors.primary, size: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Text(
                user?.fullName ?? 'Pengguna',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style:
                    const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),

              if (user?.isVerified == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded,
                          color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Pengguna Terverifikasi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textHint,
          letterSpacing: 0.5,
        ),
      );

  Widget _infoCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: children),
      );

  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child:
                Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textHint)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: children),
      );

  Widget _menuItem(
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(subtitle,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textHint)),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppColors.textHint, size: 20),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        if (showDivider)
          const Divider(
              height: 1, color: AppColors.border, indent: 16),
      ],
    );
  }

  Future<void> _handleLogout(
      BuildContext context, AuthController ctrl) async {
    final confirm = await Helpers.showConfirmDialog(
      context: context,
      title: 'Keluar',
      message: 'Kamu yakin ingin keluar dari aplikasi?',
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
