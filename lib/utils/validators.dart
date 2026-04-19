// lib/utils/validators.dart
// Semua fungsi validasi form — tidak ada dependensi Flutter, murni logika.

class Validators {
  Validators._();

  // ─────────────────────────────────────────────
  // EMAIL
  // ─────────────────────────────────────────────
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    final trimmed = value.trim();
    // Harus ada @
    if (!trimmed.contains('@')) {
      return 'Email harus mengandung karakter @';
    }
    // Format regex standar
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Format email tidak valid (contoh: nama@domain.com)';
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // PASSWORD
  // ─────────────────────────────────────────────
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    if (!hasLetter) {
      return 'Password harus mengandung huruf';
    }
    if (!hasDigit) {
      return 'Password harus mengandung angka';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (value != password) {
      return 'Password tidak cocok';
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // NAMA LENGKAP
  // ─────────────────────────────────────────────
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap wajib diisi';
    }
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    if (trimmed.length > 100) {
      return 'Nama terlalu panjang (maks 100 karakter)';
    }
    // Tidak boleh hanya angka
    final onlyNumbers = RegExp(r'^[0-9]+$');
    if (onlyNumbers.hasMatch(trimmed)) {
      return 'Nama tidak boleh hanya berisi angka';
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // TANGGAL LAHIR
  // ─────────────────────────────────────────────
  static String? validateDateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Tanggal lahir wajib diisi';
    }
    final now = DateTime.now();
    // Tidak boleh masa depan
    if (value.isAfter(now)) {
      return 'Tanggal lahir tidak boleh di masa depan';
    }
    // Minimal umur 15 tahun
    final minAge = DateTime(now.year - 15, now.month, now.day);
    if (value.isAfter(minAge)) {
      return 'Usia minimal 15 tahun untuk mendaftar';
    }
    // Maksimal umur 120 tahun (sanity check)
    final maxAge = DateTime(now.year - 120, now.month, now.day);
    if (value.isBefore(maxAge)) {
      return 'Tanggal lahir tidak valid';
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // LOKASI (profil)
  // ─────────────────────────────────────────────
  static String? validateLokasi(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Lokasi wajib diisi';
    }
    if (value.trim().length < 3) {
      return 'Lokasi minimal 3 karakter';
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // JUDUL LAPORAN
  // ─────────────────────────────────────────────
  static String? validateJudulLaporan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Judul laporan wajib diisi';
    }
    if (value.trim().length < 10) {
      return 'Judul minimal 10 karakter agar jelas';
    }
    if (value.trim().length > 100) {
      return 'Judul terlalu panjang (maks 100 karakter)';
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // KATEGORI
  // ─────────────────────────────────────────────
  static String? validateKategori(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kategori wajib dipilih';
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // LOKASI KEJADIAN (laporan — lebih spesifik)
  // ─────────────────────────────────────────────
  static String? validateLokasiKejadian(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Lokasi kejadian wajib diisi';
    }
    if (value.trim().length < 10) {
      return 'Lokasi kejadian minimal 10 karakter (harap spesifik)';
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // DESKRIPSI LAPORAN
  // ─────────────────────────────────────────────
  static String? validateDeskripsi(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Deskripsi wajib diisi';
    }
    if (value.trim().length < 30) {
      return 'Deskripsi minimal 30 karakter agar laporan jelas';
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // DESKRIPSI PROGRESS
  // ─────────────────────────────────────────────
  static String? validateDeskripsiProgress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Deskripsi progress wajib diisi';
    }
    if (value.trim().length < 20) {
      return 'Deskripsi progress minimal 20 karakter';
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // FIELD GENERIK (tidak boleh kosong)
  // ─────────────────────────────────────────────
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }
}
