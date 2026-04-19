// lib/services/validation_service.dart
// Validasi yang memerlukan komunikasi ke database (cek duplikat email, dll).

import 'supabase_service.dart';

class ValidationService {
  ValidationService._();
  static final ValidationService instance = ValidationService._();

  final _db = SupabaseService.instance;

  /// Cek apakah email sudah terdaftar di sistem.
  /// Digunakan sebelum mendaftar agar pesan error lebih jelas.
  Future<bool> isEmailAlreadyRegistered(String email) async {
    try {
      final data = await _db.profilesTable
          .select('id')
          .eq('email', email.trim().toLowerCase())
          .maybeSingle();
      return data != null;
    } catch (_) {
      return false;
    }
  }

  /// Cek apakah laporan sudah dikunci (diambil petugas lain).
  Future<bool> isLaporanLocked(String laporanId) async {
    final data = await _db.laporanTable
        .select('is_locked')
        .eq('id', laporanId)
        .single();
    return data['is_locked'] as bool? ?? false;
  }

  /// Hitung jumlah progress yang sudah ada untuk sebuah laporan.
  /// Digunakan untuk cek syarat "minimal 1 progress" sebelum selesaikan kasus.
  Future<int> countProgressUpdates(String laporanId) async {
    final data = await _db.progressTable
        .select('id')
        .eq('laporan_id', laporanId);
    return (data as List).length;
  }
}
