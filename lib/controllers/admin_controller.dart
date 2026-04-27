// lib/controllers/admin_controller.dart
// Semua logika bisnis untuk peran Admin.
// Dipanggil oleh View admin, memanggil AdminService.

import 'package:flutter/foundation.dart';
import '../models/laporan_model.dart';
import '../services/admin_service.dart';
import '../services/supabase_service.dart';

class AdminController extends ChangeNotifier {
  final _adminService = AdminService.instance;
  final _db = SupabaseService.instance;

  // ─────────────────────────────────────────────
  // STATE
  // ─────────────────────────────────────────────

  List<LaporanModel> _kasusMenungguVerifikasi = [];
  List<LaporanModel> _kasusDiteruskan = [];
  List<LaporanModel> _semuaLaporan = [];
  bool _isLoading = false;
  bool _isAdmin = false;
  String? _errorMessage;

  List<LaporanModel> get kasusMenungguVerifikasi => _kasusMenungguVerifikasi;
  List<LaporanModel> get kasusDiteruskan => _kasusDiteruskan;
  List<LaporanModel> get semuaLaporan => _semuaLaporan;
  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;
  String? get errorMessage => _errorMessage;

  // Statistik untuk dashboard admin
  int get totalLaporan => _semuaLaporan.length;
  int get totalMenunggu => _kasusMenungguVerifikasi.length;
  int get totalDiteruskan => _kasusDiteruskan.length;
  int get totalSelesai =>
      _semuaLaporan.where((l) => l.status == 'selesai').length;
  int get totalAktif =>
      _semuaLaporan.where((l) => l.status == 'dikerjakan').length;

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void _setError(String? msg) { _errorMessage = msg; notifyListeners(); }
  void clearError() { _errorMessage = null; notifyListeners(); }

  // ─────────────────────────────────────────────
  // CEK DAN LOAD ROLE ADMIN
  // Dipanggil setelah login berhasil
  // ─────────────────────────────────────────────

  Future<bool> checkAndLoadAdminRole() async {
    _isAdmin = await _adminService.isCurrentUserAdmin();
    notifyListeners();
    return _isAdmin;
  }

  // ─────────────────────────────────────────────
  // LOAD SEMUA DATA DASHBOARD ADMIN
  // ─────────────────────────────────────────────

  Future<void> loadDashboard() async {
    _setLoading(true);
    _setError(null);
    try {
      await Future.wait([
        _loadKasusMenungguVerifikasi(),
        _loadKasusDiteruskan(),
        _loadSemuaLaporan(),
      ]);
    } on Exception catch (e) {
      _setError('Gagal memuat dashboard: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadKasusMenungguVerifikasi() async {
    _kasusMenungguVerifikasi =
        await _adminService.getKasusMenungguVerifikasiSelesai();
    notifyListeners();
  }

  Future<void> _loadKasusDiteruskan() async {
    _kasusDiteruskan =
        await _adminService.getKasusDiteruskanKePemerintah();
    notifyListeners();
  }

  Future<void> _loadSemuaLaporan() async {
    _semuaLaporan = await _adminService.getAllLaporan();
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // VERIFIKASI KASUS SELESAI — SETUJU
  // Admin menyetujui bahwa kasus benar-benar selesai
  // ─────────────────────────────────────────────

  Future<bool> verifikasiSetujuSelesai({
    required String laporanId,
    String? catatan,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _adminService.setujuiSelesai(
        laporanId: laporanId,
        catatan: catatan,
      );
      // Hapus dari list lokal supaya UI langsung update
      _kasusMenungguVerifikasi.removeWhere((l) => l.id == laporanId);
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _setError('Gagal memverifikasi: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // VERIFIKASI KASUS SELESAI — BUKTI KURANG
  // Admin meminta user menambah bukti progress lagi
  // ─────────────────────────────────────────────

  Future<bool> verifikasiBuktiKurang({
    required String laporanId,
    required String catatan,
  }) async {
    if (catatan.trim().isEmpty) {
      _setError('Catatan wajib diisi saat bukti kurang.');
      return false;
    }
    _setLoading(true);
    _setError(null);
    try {
      await _adminService.tolakBuktiKurang(
        laporanId: laporanId,
        catatan: catatan,
      );
      _kasusMenungguVerifikasi.removeWhere((l) => l.id == laporanId);
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _setError('Gagal: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // VERIFIKASI TERUSAN KE PEMERINTAH — SETUJU
  // ─────────────────────────────────────────────

  Future<bool> verifikasiSetujuTerusan({
    required String laporanId,
    String? catatan,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _adminService.setujuiTerusanKePemerintah(
        laporanId: laporanId,
        catatan: catatan,
      );
      _kasusDiteruskan.removeWhere((l) => l.id == laporanId);
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _setError('Gagal: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // VERIFIKASI TERUSAN KE PEMERINTAH — TOLAK
  // Kasus dikembalikan ke tersedia untuk umum
  // ─────────────────────────────────────────────

  Future<bool> verifikasiTolakTerusan({
    required String laporanId,
    required String alasan,
  }) async {
    if (alasan.trim().isEmpty) {
      _setError('Alasan penolakan wajib diisi.');
      return false;
    }
    _setLoading(true);
    _setError(null);
    try {
      await _adminService.tolakTerusanKePemerintah(
        laporanId: laporanId,
        alasan: alasan,
      );
      _kasusDiteruskan.removeWhere((l) => l.id == laporanId);
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _setError('Gagal: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
