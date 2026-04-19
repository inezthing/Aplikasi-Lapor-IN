// lib/controllers/kasus_controller.dart
// Logika bisnis untuk petugas: ambil kasus, tambah progress, selesaikan.

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

  // ─────────────────────────────────────────────
  // STATE
  // ─────────────────────────────────────────────

  List<LaporanModel> _myActiveCases = [];
  List<ProgressModel> _currentProgressList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<LaporanModel> get myActiveCases => _myActiveCases;
  List<ProgressModel> get currentProgressList => _currentProgressList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // AMBIL KASUS
  // Petugas mengambil kasus — mengunci agar tidak bisa diambil user lain.
  // Operasi atomic: cek is_locked dulu, lalu update.
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
      // 1. Cek apakah sudah dikunci user lain
      final isLocked = await _validationService.isLaporanLocked(laporanId);
      if (isLocked) {
        _setError('Kasus ini sudah diambil oleh petugas lain.');
        return false;
      }

      // 2. Update: kunci kasus dan assign ke petugas ini
      await _db.laporanTable.update({
        'petugas_id': userId,
        'is_locked': true,
        'status': AppStatus.dikerjakan,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', laporanId);

      // 3. Refresh daftar kasus aktif milik user ini
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
  // GET MY ACTIVE CASES
  // Ambil semua kasus yang sedang ditangani user yang login.
  // Untuk widget "Kasus Saya" di HomePage.
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
          .neq('status', AppStatus.selesai)
          .order('updated_at', ascending: false);

      _myActiveCases = (data as List)
          .map((json) => LaporanModel.fromJson(json))
          .toList();
      notifyListeners();
    } on Exception catch (_) {
      // Silent fail
    }
  }

  // ─────────────────────────────────────────────
  // ADD PROGRESS UPDATE
  // Tambah update progress dengan foto WAJIB.
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
      // 1. Upload foto ke Storage
      final fotoUrl = await _storageService.uploadProgressPhoto(
        laporanId: laporanId,
        imageFile: fotoFile,
      );

      final now = DateTime.now();

      // 2. Insert progress ke database
      await _db.progressTable.insert({
        'laporan_id': laporanId,
        'petugas_id': userId,
        'deskripsi': deskripsi.trim(),
        'foto_url': fotoUrl,
        'waktu': now.toIso8601String(),
        'bulan': now.month,   
        'tahun': now.year, 
      });

      // 3. Update timestamp laporan agar terlihat ada aktivitas baru
      await _db.laporanTable.update({
        'updated_at': now.toIso8601String(),
      }).eq('id', laporanId);

      // 4. Refresh list progress untuk laporan ini
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
  // GET PROGRESS BY LAPORAN
  // Ambil semua progress dari sebuah laporan, urut dari terbaru.
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

  // ─────────────────────────────────────────────
  // GET PROGRESS GROUPED BY MONTH
  // Ambil progress dikelompokkan per bulan untuk tampilan timeline.
  // Return: Map dengan key "Maret 2026" berisi list progress bulan itu.
  // ─────────────────────────────────────────────

  Future<Map<String, List<ProgressModel>>> getProgressGroupedByMonth(
      String laporanId) async {
    await getProgressByLaporan(laporanId);

    final grouped = <String, List<ProgressModel>>{};
    for (final progress in _currentProgressList) {
      final key = '${progress.tahun}-${progress.bulan.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(progress);
    }

    // Urutkan key dari terbaru ke terlama
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return {for (final k in sortedKeys) k: grouped[k]!};
  }

  // ─────────────────────────────────────────────
  // CAN MARK AS COMPLETE
  // Cek apakah kasus boleh diselesaikan (sudah ada 1+ progress).
  // ─────────────────────────────────────────────

  Future<bool> canMarkAsComplete(String laporanId) async {
    final count = await _validationService.countProgressUpdates(laporanId);
    return count >= 1;
  }

  // ─────────────────────────────────────────────
  // SELESAIKAN KASUS
  // Tandai kasus sebagai selesai. Syarat: minimal 1 progress.
  // ─────────────────────────────────────────────

  Future<bool> selesaikanKasus(String laporanId) async {
    _setLoading(true);
    _setError(null);

    try {
      // 1. Cek syarat minimal 1 progress
      final canComplete = await canMarkAsComplete(laporanId);
      if (!canComplete) {
        _setError(
            'Kasus belum bisa diselesaikan. Tambahkan minimal 1 update progress terlebih dahulu.');
        return false;
      }

      // 2. Update status ke selesai
      await _db.laporanTable.update({
        'status': AppStatus.selesai,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', laporanId);

      // 3. Hapus dari daftar kasus aktif lokal
      _myActiveCases.removeWhere((k) => k.id == laporanId);
      notifyListeners();

      return true;
    } on Exception catch (e) {
      _setError('Gagal menyelesaikan kasus: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // UBAH STATUS MANUAL
  // Untuk perubahan status: dikerjakan ↔ tertunda.
  // ─────────────────────────────────────────────

  Future<bool> ubahStatus(String laporanId, String newStatus) async {
    // Status 'selesai' hanya boleh lewat selesaikanKasus()
    if (newStatus == AppStatus.selesai) {
      return selesaikanKasus(laporanId);
    }

    _setLoading(true);
    _setError(null);
    try {
      await _db.laporanTable.update({
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', laporanId);

      // Update state lokal
      final idx = _myActiveCases.indexWhere((k) => k.id == laporanId);
      if (idx != -1) {
        _myActiveCases[idx] = _myActiveCases[idx].copyWith(status: newStatus);
        notifyListeners();
      }
      return true;
    } on Exception catch (e) {
      _setError('Gagal mengubah status: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // CLEAR PROGRESS (bersihkan state saat pindah halaman)
  // ─────────────────────────────────────────────

  void clearCurrentProgress() {
    _currentProgressList = [];
    notifyListeners();
  }
}
