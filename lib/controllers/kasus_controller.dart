// lib/controllers/kasus_controller.dart
// Update: tambah batalkanKasus() dan teruskankePemerintah()

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/laporan_model.dart';
import '../models/progress_model.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';
import '../services/validation_service.dart';
import '../utils/constants.dart';

class KasusController extends ChangeNotifier {
  final _db = SupabaseService.instance;
  final _storageService = StorageService.instance;
  final _validationService = ValidationService.instance;

  List<LaporanModel> _myActiveCases = [];
  List<ProgressModel> _currentProgressList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<LaporanModel> get myActiveCases => _myActiveCases;
  List<ProgressModel> get currentProgressList => _currentProgressList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void _setError(String? msg) { _errorMessage = msg; notifyListeners(); }
  void clearError() { _errorMessage = null; notifyListeners(); }

  // ─────────────────────────────────────────────
  // AMBIL KASUS
  // ─────────────────────────────────────────────
  Future<bool> ambilKasus(String laporanId) async {
    _setLoading(true);
    _setError(null);
    final userId = _db.currentUserId;
    if (userId == null) {
      _setError('Sesi login tidak ditemukan.');
      _setLoading(false);
      return false;
    }
    try {
      final isLocked = await _validationService.isLaporanLocked(laporanId);
      if (isLocked) {
        _setError('Kasus ini sudah diambil oleh petugas lain.');
        return false;
      }
      final now = DateTime.now().toIso8601String();
      await _db.laporanTable.update({
        'petugas_id': userId,
        'is_locked': true,
        'status': AppStatus.dikerjakan,
        'tanggal_ambil': now,
        'updated_at': now,
      }).eq('id', laporanId);
      await getMyActiveCases();
      return true;
    } on Exception catch (e) {
      _setError('Gagal mengambil kasus: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // BATALKAN KASUS
  // User membatalkan penanganan — kasus dikembalikan ke tersedia
  // ─────────────────────────────────────────────
  Future<bool> batalkanKasus({
    required String laporanId,
    required String alasan,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final now = DateTime.now().toIso8601String();
      await _db.laporanTable.update({
        'petugas_id': null,
        'is_locked': false,
        'status': AppStatus.belumDimulai,
        'tanggal_ambil': null,
        'dibatalkan_alasan': alasan,
        'verifikasi_status': null,
        'updated_at': now,
      }).eq('id', laporanId);

      _myActiveCases.removeWhere((k) => k.id == laporanId);
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _setError('Gagal membatalkan kasus: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // TERUSKAN KE PEMERINTAH
  // User memilih untuk tidak menangani sendiri, diteruskan ke pemerintah
  // ─────────────────────────────────────────────
  Future<bool> teruskankePemerintah(String laporanId) async {
    _setLoading(true);
    _setError(null);

    // Syarat: sudah ada minimal 1 progress sebagai bukti
    final canForward = await canMarkAsComplete(laporanId);
    if (!canForward) {
      _setError(
          'Tambahkan minimal 1 progress/bukti sebelum meneruskan ke pemerintah.');
      _setLoading(false);
      return false;
    }

    try {
      final now = DateTime.now().toIso8601String();
      await _db.laporanTable.update({
        'diteruskan_ke_pemerintah': true,
        'verifikasi_status': 'menunggu_verifikasi',
        'updated_at': now,
      }).eq('id', laporanId);

      // Update state lokal
      final idx = _myActiveCases.indexWhere((k) => k.id == laporanId);
      if (idx != -1) {
        _myActiveCases[idx] = _myActiveCases[idx].copyWith(
          diteruskanKePemerintah: true,
          verifikasiStatus: 'menunggu_verifikasi',
        );
        notifyListeners();
      }
      return true;
    } on Exception catch (e) {
      _setError('Gagal meneruskan ke pemerintah: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // GET MY ACTIVE CASES
  // ─────────────────────────────────────────────
  Future<void> getMyActiveCases() async {
    final userId = _db.currentUserId;
    if (userId == null) return;
    try {
      final data = await _db.laporanTable
          .select('''
            *,
            pelapor:profiles!pelapor_id(full_name, avatar_url)
          ''')
          .eq('petugas_id', userId)
          .not('status', 'eq', AppStatus.selesai)
          .not('status', 'eq', 'diteruskan')
          .order('updated_at', ascending: false);

      _myActiveCases = (data as List)
          .map((json) => LaporanModel.fromJson(json))
          .toList();
      notifyListeners();
    } on Exception catch (_) {}
  }

  // ─────────────────────────────────────────────
  // ADD PROGRESS UPDATE
  // ─────────────────────────────────────────────
  Future<bool> addProgressUpdate({
    required String laporanId,
    required String deskripsi,
    required File fotoFile,
  }) async {
    _setLoading(true);
    _setError(null);
    final userId = _db.currentUserId;
    if (userId == null) {
      _setError('Sesi login tidak ditemukan.');
      _setLoading(false);
      return false;
    }
    try {
      final fotoUrl = await _storageService.uploadProgressPhoto(
        laporanId: laporanId,
        imageFile: fotoFile,
      );
      final now = DateTime.now();
      await _db.progressTable.insert({
        'laporan_id': laporanId,
        'petugas_id': userId,
        'deskripsi': deskripsi.trim(),
        'foto_url': fotoUrl,
        'waktu': now.toIso8601String(),
        'bulan': now.month,
        'tahun': now.year,
      });
      await _db.laporanTable.update({
        'updated_at': now.toIso8601String(),
        // FIX: reset verifikasi_status jika sebelumnya 'bukti_kurang'
        // supaya tombol "Selesaikan" bisa ditekan lagi
        // Gunakan null — bukan nilai enum yang tidak valid
        'verifikasi_status': null,
      }).eq('id', laporanId);
      await getProgressByLaporan(laporanId);
      return true;
    } on Exception catch (e) {
      _setError('Gagal menambah progress: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // SELESAIKAN KASUS (ajukan ke admin)
  // FIX: status tetap 'dikerjakan' — kolom status punya DB CHECK constraint.
  // Yang diubah hanya verifikasi_status → 'menunggu_verifikasi'.
  // Admin kemudian yang akan set status → 'selesai'.
  // ─────────────────────────────────────────────
  Future<bool> selesaikanKasus(String laporanId) async {
    _setLoading(true);
    _setError(null);
    try {
      final canComplete = await canMarkAsComplete(laporanId);
      if (!canComplete) {
        _setError(
            'Tambahkan minimal 1 progress sebelum menyelesaikan kasus.');
        return false;
      }
      final now = DateTime.now().toIso8601String();
      // FIX: 'status' TIDAK diubah ke 'menunggu_verifikasi' karena
      // melanggar CHECK constraint di PostgreSQL.
      // Status valid: belum_dimulai | dikerjakan | tertunda | selesai | diteruskan
      await _db.laporanTable.update({
        'verifikasi_status': 'menunggu_verifikasi',
        'updated_at': now,
      }).eq('id', laporanId);

      // Perbarui state lokal — kasus masih aktif sampai admin setujui
      final idx = _myActiveCases.indexWhere((k) => k.id == laporanId);
      if (idx != -1) {
        _myActiveCases[idx] = _myActiveCases[idx].copyWith(
          verifikasiStatus: 'menunggu_verifikasi',
        );
        notifyListeners();
      }
      return true;
    } on Exception catch (e) {
      _setError('Gagal: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // GET PROGRESS
  // ─────────────────────────────────────────────
  Future<void> getProgressByLaporan(String laporanId) async {
    try {
      final data = await _db.progressTable
          .select('''
            *,
            petugas:profiles!petugas_id(full_name, avatar_url)
          ''')
          .eq('laporan_id', laporanId)
          .order('waktu', ascending: false);
      _currentProgressList = (data as List)
          .map((json) => ProgressModel.fromJson(json))
          .toList();
      notifyListeners();
    } on Exception catch (_) {
      _currentProgressList = [];
      notifyListeners();
    }
  }

  Future<Map<String, List<ProgressModel>>> getProgressGroupedByMonth(
      String laporanId) async {
    await getProgressByLaporan(laporanId);
    final grouped = <String, List<ProgressModel>>{};
    for (final p in _currentProgressList) {
      final key = '${p.tahun}-${p.bulan.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(p);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in sortedKeys) k: grouped[k]!};
  }

  Future<bool> canMarkAsComplete(String laporanId) async {
    final count = await _validationService.countProgressUpdates(laporanId);
    return count >= 1;
  }

  Future<bool> ubahStatus(String laporanId, String newStatus) async {
    if (newStatus == AppStatus.selesai) return selesaikanKasus(laporanId);
    _setLoading(true);
    _setError(null);
    try {
      await _db.laporanTable.update({
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', laporanId);
      final idx = _myActiveCases.indexWhere((k) => k.id == laporanId);
      if (idx != -1) {
        _myActiveCases[idx] =
            _myActiveCases[idx].copyWith(status: newStatus);
        notifyListeners();
      }
      return true;
    } on Exception catch (e) {
      _setError('Gagal: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearCurrentProgress() {
    _currentProgressList = [];
    notifyListeners();
  }
}
