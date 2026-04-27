// lib/services/admin_service.dart
// Komunikasi ke Supabase khusus untuk operasi admin.
// Dipanggil oleh AdminController, TIDAK oleh View.

import '../models/laporan_model.dart';
import 'supabase_service.dart';

class AdminService {
  AdminService._();
  static final AdminService instance = AdminService._();

  final _db = SupabaseService.instance;

  // ─────────────────────────────────────────────
  // CEK ROLE ADMIN
  // ─────────────────────────────────────────────

  /// Cek apakah user yang login adalah admin.
  Future<bool> isCurrentUserAdmin() async {
    final userId = _db.currentUserId;
    if (userId == null) return false;

    try {
      final data = await _db.profilesTable
          .select('role')
          .eq('id', userId)
          .single();
      return data['role'] == 'admin';
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // GET KASUS MENUNGGU VERIFIKASI SELESAI
  // Kasus yang user pencet "Selesaikan" — admin perlu verifikasi
  // ─────────────────────────────────────────────

  Future<List<LaporanModel>> getKasusMenungguVerifikasiSelesai() async {
    final data = await _db.laporanTable
        .select('''
          *,
          pelapor:profiles!pelapor_id(full_name, avatar_url),
          petugas:profiles!petugas_id(full_name, avatar_url)
        ''')
        .eq('verifikasi_status', 'menunggu_verifikasi')
        .eq('diteruskan_ke_pemerintah', false)
        .order('verifikasi_at', ascending: true);

    return (data as List).map((j) => LaporanModel.fromJson(j)).toList();
  }

  // ─────────────────────────────────────────────
  // GET KASUS DITERUSKAN KE PEMERINTAH
  // Kasus yang user pencet "Teruskan ke Pemerintah"
  // ─────────────────────────────────────────────

  Future<List<LaporanModel>> getKasusDiteruskanKePemerintah() async {
    final data = await _db.laporanTable
        .select('''
          *,
          pelapor:profiles!pelapor_id(full_name, avatar_url),
          petugas:profiles!petugas_id(full_name, avatar_url)
        ''')
        .eq('diteruskan_ke_pemerintah', true)
        .eq('verifikasi_status', 'menunggu_verifikasi')
        .order('updated_at', ascending: true);

    return (data as List).map((j) => LaporanModel.fromJson(j)).toList();
  }

  // ─────────────────────────────────────────────
  // GET SEMUA LAPORAN (untuk overview admin)
  // ─────────────────────────────────────────────

  Future<List<LaporanModel>> getAllLaporan() async {
    final data = await _db.laporanTable
        .select('''
          *,
          pelapor:profiles!pelapor_id(full_name, avatar_url),
          petugas:profiles!petugas_id(full_name, avatar_url)
        ''')
        .order('created_at', ascending: false);

    return (data as List).map((j) => LaporanModel.fromJson(j)).toList();
  }

  // ─────────────────────────────────────────────
  // VERIFIKASI SELESAI — SETUJU
  // Admin setuju kasus selesai → status jadi 'selesai'
  // ─────────────────────────────────────────────

  Future<void> setujuiSelesai({
    required String laporanId,
    String? catatan,
  }) async {
    final adminId = _db.currentUserId!;
    final now = DateTime.now().toIso8601String();

    await _db.laporanTable.update({
      'status': 'selesai',
      'verifikasi_status': 'disetujui',
      'verifikasi_catatan': catatan,
      'verifikasi_at': now,
      'verifikasi_oleh': adminId,
      'updated_at': now,
    }).eq('id', laporanId);
  }

  // ─────────────────────────────────────────────
  // VERIFIKASI SELESAI — BUKTI KURANG
  // Admin minta user tambah bukti lagi
  // ─────────────────────────────────────────────

  Future<void> tolakBuktiKurang({
    required String laporanId,
    required String catatan,
  }) async {
    final adminId = _db.currentUserId!;
    final now = DateTime.now().toIso8601String();

    await _db.laporanTable.update({
      // Status kembali ke dikerjakan agar user bisa tambah progress lagi
      'status': 'dikerjakan',
      'verifikasi_status': 'bukti_kurang',
      'verifikasi_catatan': catatan,
      'verifikasi_at': now,
      'verifikasi_oleh': adminId,
      'updated_at': now,
    }).eq('id', laporanId);
  }

  // ─────────────────────────────────────────────
  // VERIFIKASI TERUSAN KE PEMERINTAH — SETUJU
  // Admin setuju teruskan → status jadi 'diteruskan'
  // ─────────────────────────────────────────────

  Future<void> setujuiTerusanKePemerintah({
    required String laporanId,
    String? catatan,
  }) async {
    final adminId = _db.currentUserId!;
    final now = DateTime.now().toIso8601String();

    await _db.laporanTable.update({
      'status': 'diteruskan',
      'verifikasi_status': 'diteruskan',
      'verifikasi_catatan': catatan,
      'verifikasi_at': now,
      'verifikasi_oleh': adminId,
      'updated_at': now,
    }).eq('id', laporanId);
  }

  // ─────────────────────────────────────────────
  // VERIFIKASI TERUSAN KE PEMERINTAH — TOLAK
  // Admin tolak → kasus kembali tersedia untuk umum
  // ─────────────────────────────────────────────

  Future<void> tolakTerusanKePemerintah({
    required String laporanId,
    required String alasan,
  }) async {
    final adminId = _db.currentUserId!;
    final now = DateTime.now().toIso8601String();

    await _db.laporanTable.update({
      // Reset: kembali tersedia untuk user lain
      'status': 'belum_dimulai',
      'is_locked': false,
      'petugas_id': null,
      'diteruskan_ke_pemerintah': false,
      'verifikasi_status': 'dibatalkan_admin',
      'verifikasi_catatan': alasan,
      'dibatalkan_alasan': alasan,
      'verifikasi_at': now,
      'verifikasi_oleh': adminId,
      'tanggal_ambil': null,
      'updated_at': now,
    }).eq('id', laporanId);
  }
}
