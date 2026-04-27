import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// SUPABASE CONFIG
// ─────────────────────────────────────────────
class SupabaseConfig {
  static const String url = 'https://XXXXXXXXXXXX.supabase.co'; // ganti dengan URL kamu
  static const String anonKey = 'eyJXXXXXXXXXXXXXXXXXXXX'; // ganti dengan anon key kamu

  // Bucket names
  static const String avatarBucket = 'avatars';
  static const String laporanPhotoBucket = 'laporan-photos';
  static const String progressPhotoBucket = 'laporan-photos'; // subfolder berbeda
}

// ─────────────────────────────────────────────
// WARNA UTAMA
// ─────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1A6BFF);
  static const Color primaryDark = Color(0xFF0A3FCC);
  static const Color primaryLight = Color(0xFF4D8FFF);
  static const Color primaryBg = Color(0xFFEEF3FF);

  static const Color background = Color(0xFFF5F7FF);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE0E7FF);

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textHint = Color(0xFF8A94A6);

  // Status colors
  static const Color statusBelum = Color(0xFFFF6B35);
  static const Color statusBelumBg = Color(0xFFFFF0EC);
  static const Color statusDikerjakan = Color(0xFF1A6BFF);
  static const Color statusDikerjakanBg = Color(0xFFEEF3FF);
  static const Color statusTertunda = Color(0xFFFFB800);
  static const Color statusTertundaBg = Color(0xFFFFF8E7);
  static const Color statusSelesai = Color(0xFF00C896);
  static const Color statusSelesaiBg = Color(0xFFE8FFF8);

  static const Color error = Color(0xFFFF4747);
  static const Color errorBg = Color(0xFFFFECEC);
  static const Color success = Color(0xFF00C896);
  static const Color successBg = Color(0xFFE8FFF8);
  static const Color warning = Color(0xFFFFB800);
}

// ─────────────────────────────────────────────
// TEKS & TYPOGRAPHY
// ─────────────────────────────────────────────
class AppText {
  AppText._();

  static const String appName = 'LaporIn';
  static const String tagline = 'Laporkan kerusakan di sekitarmu dengan mudah dan cepat';

  // Auth
  static const String login = 'Masuk';
  static const String register = 'Daftar';
  static const String signIn = 'Sign In';
  static const String signUp = 'Buat Akun';
  static const String logout = 'Keluar';
  static const String verifyEmail = 'Verifikasi Email';

  // Form labels
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Konfirmasi Password';
  static const String fullName = 'Nama Lengkap';
  static const String dateOfBirth = 'Tanggal Lahir';
  static const String lokasi = 'Lokasi / Kota';

  // Laporan
  static const String judulLaporan = 'Judul Laporan';
  static const String kategori = 'Kategori';
  static const String lokasiKejadian = 'Lokasi Kejadian';
  static const String deskripsi = 'Deskripsi';
  static const String buktiFoto = 'Bukti Foto';
  static const String kirimLaporan = 'Kirim Laporan';
  static const String buatLaporan = 'Buat Laporan';

  // Kasus
  static const String ambilKasus = 'Ambil Kasus Ini';
  static const String tambahProgress = 'Tambah Progress';
  static const String tandaiSelesai = 'Tandai Selesai';
  static const String kasusAktif = 'Kasus Aktif';

  // Nav labels
  static const String home = 'Home';
  static const String lapor = 'Lapor';
  static const String kasus = 'Kasus';
  static const String profil = 'Profil';
}

// ─────────────────────────────────────────────
// KATEGORI LAPORAN
// ─────────────────────────────────────────────
class AppKategori {
  AppKategori._();

  static const List<String> list = [
    'Infrastruktur',
    'Lingkungan',
    'Penerangan',
    'Drainase',
    'Fasilitas Umum',
    'Lainnya',
  ];
}

// ─────────────────────────────────────────────
// STATUS LAPORAN
// ─────────────────────────────────────────────
class AppStatus {
  AppStatus._();

  static const String belumDimulai = 'belum_dimulai';
  static const String dikerjakan = 'dikerjakan';
  static const String tertunda = 'tertunda';
  static const String selesai = 'selesai';
  // FIX: tambahkan status valid yang ada di DB
  static const String diteruskan = 'diteruskan';

  static String getLabel(String status) {
    switch (status) {
      case belumDimulai:
        return 'Belum Dimulai';
      case dikerjakan:
        return 'Dikerjakan';
      case tertunda:
        return 'Tertunda';
      case selesai:
        return 'Selesai';
      case diteruskan:
        return 'Diteruskan ke Pemerintah';
      default:
        return 'Tidak Diketahui';
    }
  }

  static Color getColor(String status) {
    switch (status) {
      case belumDimulai:
        return AppColors.statusBelum;
      case dikerjakan:
        return AppColors.statusDikerjakan;
      case tertunda:
        return AppColors.statusTertunda;
      case selesai:
        return AppColors.statusSelesai;
      case diteruskan:
        return AppColors.warning;
      default:
        return AppColors.textHint;
    }
  }

  static Color getBgColor(String status) {
    switch (status) {
      case belumDimulai:
        return AppColors.statusBelumBg;
      case dikerjakan:
        return AppColors.statusDikerjakanBg;
      case tertunda:
        return AppColors.statusTertundaBg;
      case selesai:
        return AppColors.statusSelesaiBg;
      case diteruskan:
        return const Color(0xFFFFF8E7);
      default:
        return AppColors.background;
    }
  }
}

// ─────────────────────────────────────────────
// SPACING & RADIUS
// ─────────────────────────────────────────────
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;
}

// ─────────────────────────────────────────────
// ROUTE NAMES
// ─────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String main = '/main';
  static const String home = '/home';
  static const String buatLaporan = '/buat-laporan';
  static const String kasusList = '/kasus-list';
  static const String detailKasus = '/detail-kasus';
  static const String tambahProgress = '/tambah-progress';
  static const String profil = '/profil';
  static const String editProfil = '/edit-profil';
}
