import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

class Helpers {
  Helpers._();

  // ─────────────────────────────────────────────
  // FORMAT TANGGAL
  // ─────────────────────────────────────────────

  /// Format: "16 Apr 2026"
  static String formatDate(DateTime dt) {
    return DateFormat('d MMM yyyy', 'id_ID').format(dt);
  }

  /// Format: "16 April 2026"
  static String formatDateLong(DateTime dt) {
    return DateFormat('d MMMM yyyy', 'id_ID').format(dt);
  }

  /// Format: "16 Apr 2026, 08:30"
  static String formatDateTime(DateTime dt) {
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dt);
  }

  /// Format: "Maret 2026" (untuk group per bulan)
  static String formatMonth(int bulan, int tahun) {
    final dt = DateTime(tahun, bulan);
    return DateFormat('MMMM yyyy', 'id_ID').format(dt);
  }

  /// Hitung umur dari tanggal lahir
  static int calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// Format tanggal relatif: "Baru saja", "2 jam lalu", "3 hari lalu"
  static String formatRelative(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return formatDate(dt);
  }

  // ─────────────────────────────────────────────
  // SNACKBAR
  // ─────────────────────────────────────────────

  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        margin: const EdgeInsets.all(AppSpacing.md),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        margin: const EdgeInsets.all(AppSpacing.md),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        margin: const EdgeInsets.all(AppSpacing.md),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DIALOG KONFIRMASI
  // ─────────────────────────────────────────────

  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        content: Text(message, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText, style: const TextStyle(color: AppColors.textHint)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ─────────────────────────────────────────────
  // LOADING DIALOG
  // ─────────────────────────────────────────────

  static void showLoadingDialog(BuildContext context, {String message = 'Memproses...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          content: Row(
            children: [
              const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
              const SizedBox(width: 20),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  // ─────────────────────────────────────────────
  // STORAGE PATH HELPERS
  // ─────────────────────────────────────────────

  /// Path avatar: "avatars/{userId}/avatar.jpg"
  static String avatarPath(String userId) => '$userId/avatar.jpg';

  /// Path foto laporan: "laporan-photos/laporan/{laporanId}/{timestamp}.jpg"
  static String laporanPhotoPath(String laporanId) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return 'laporan/$laporanId/$ts.jpg';
  }

  /// Path foto progress: "laporan-photos/progress/{laporanId}/{timestamp}.jpg"
  static String progressPhotoPath(String laporanId) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return 'progress/$laporanId/$ts.jpg';
  }

  // ─────────────────────────────────────────────
  // INISIAL NAMA (untuk avatar placeholder)
  // ─────────────────────────────────────────────

  static String getInitials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
