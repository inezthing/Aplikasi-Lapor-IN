// lib/controllers/laporan_controller.dart
// Logika untuk membuat laporan baru dan mengambil daftar laporan.

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/laporan_model.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class LaporanController extends ChangeNotifier {
  final _db = SupabaseService.instance;
  final _storageService = StorageService.instance;

  // ─────────────────────────────────────────────
  // STATE
  // ─────────────────────────────────────────────

  List<LaporanModel> _availableLaporan = []; // semua laporan belum diambil
  List<LaporanModel> _mySubmittedLaporan = []; // laporan yang dibuat user ini
  bool _isLoading = false;
  String? _errorMessage;

  List<LaporanModel> get availableLaporan => _availableLaporan;
  List<LaporanModel> get mySubmittedLaporan => _mySubmittedLaporan;
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
  // CREATE LAPORAN
  // Membuat laporan baru: upload foto jika ada, lalu insert ke DB.
  // ─────────────────────────────────────────────

  Future<bool> createLaporan({
    required String judul,
    required String kategori,
    required String lokasi,
    required String deskripsi,
    File? fotoFile,
  }) async {
    _setLoading(true);
    _setError(null);

    final userId = _db.currentUserId;
    if (userId == null) {
      _setError('Sesi login tidak ditemukan. Silakan login ulang.');
      _setLoading(false);
      return false;
    }

    try {
      // 1. Insert laporan ke DB dulu untuk dapat ID
      final insertData = {
        'pelapor_id': userId,
        'judul': judul.trim(),
        'kategori': kategori,
        'lokasi': lokasi.trim(),
        'deskripsi': deskripsi.trim(),
        'status': AppStatus.belumDimulai,
        'is_locked': false,
      };

      final inserted = await _db.laporanTable
          .insert(insertData)
          .select()
          .single();

      final laporanId = inserted['id'] as String;

      // 2. Upload foto jika ada
      if (fotoFile != null) {
        final fotoUrl = await _storageService.uploadLaporanPhoto(
          laporanId: laporanId,
          imageFile: fotoFile,
        );
        // Update kolom foto_url
        await _db.laporanTable
            .update({'foto_url': fotoUrl})
            .eq('id', laporanId);
      }

      // 3. Refresh list
      await getMySubmittedLaporan();
      return true;
    } on Exception catch (e) {
      _setError('Gagal mengirim laporan: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // GET AVAILABLE LAPORAN
  // Ambil semua laporan yang belum diambil petugas (is_locked = false).
  // Untuk halaman Kasus (semua user bisa lihat).
  // ─────────────────────────────────────────────

  Future<void> getAvailableLaporan() async {
    _setLoading(true);
    _setError(null);

    try {
      final data = await _db.laporanTable
          .select('''
            *,
            pelapor:profiles!pelapor_id(full_name, avatar_url)
          ''')
          .eq('is_locked', false)
          .order('created_at', ascending: false);

      _availableLaporan = (data as List)
          .map((json) => LaporanModel.fromJson(json))
          .toList();
      notifyListeners();
    } on Exception catch (e) {
      _setError('Gagal memuat laporan: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // GET MY SUBMITTED LAPORAN
  // Ambil laporan yang dibuat oleh user yang sedang login.
  // Untuk widget personal di HomePage.
  // ─────────────────────────────────────────────

  Future<void> getMySubmittedLaporan() async {
    final userId = _db.currentUserId;
    if (userId == null) return;

    try {
      final data = await _db.laporanTable
          .select('*')
          .eq('pelapor_id', userId)
          .order('created_at', ascending: false);

      _mySubmittedLaporan = (data as List)
          .map((json) => LaporanModel.fromJson(json))
          .toList();
      notifyListeners();
    } on Exception catch (_) {
      // Silent fail untuk widget — tidak ganggu UX utama
    }
  }

  // ─────────────────────────────────────────────
  // GET LAPORAN BY ID
  // Ambil detail satu laporan, termasuk info pelapor dan petugas.
  // ─────────────────────────────────────────────

  Future<LaporanModel?> getLaporanById(String laporanId) async {
    try {
      final data = await _db.laporanTable
          .select('''
            *,
            pelapor:profiles!pelapor_id(full_name, avatar_url),
            petugas:profiles!petugas_id(full_name, avatar_url)
          ''')
          .eq('id', laporanId)
          .maybeSingle();

      if (data == null) return null;
      return LaporanModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // WATCH ALL LAPORAN (Realtime Stream)
  // Stream yang otomatis update saat ada perubahan di database.
  // Untuk halaman utama kasus agar tetap sinkron.
  // ─────────────────────────────────────────────

  Stream<List<LaporanModel>> watchAvailableLaporan() {
    return _db.laporanTable
        .stream(primaryKey: ['id'])
        .eq('is_locked', false)
        .order('created_at')
        .map((data) => data.map((json) => LaporanModel.fromJson(json)).toList());
  }
}
