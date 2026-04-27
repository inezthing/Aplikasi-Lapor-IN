// lib/controllers/auth_controller.dart
// Logika bisnis autentikasi. Dipanggil oleh View.
// Memanggil AuthService & StorageService, tidak pernah query Supabase langsung.

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/validation_service.dart';

class AuthController extends ChangeNotifier {
  final _authService = AuthService.instance;
  final _storageService = StorageService.instance;
  final _validationService = ValidationService.instance;

  // ─────────────────────────────────────────────
  // STATE
  // ─────────────────────────────────────────────

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // SIGN UP
  // Mendaftarkan pengguna baru dengan validasi lengkap.
  // ─────────────────────────────────────────────

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required DateTime dateOfBirth,
    required String lokasi,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Cek duplikat email sebelum mendaftar
      final emailExists = await _validationService.isEmailAlreadyRegistered(email);
      if (emailExists) {
        _setError('Email ini sudah terdaftar. Silakan login atau gunakan email lain.');
        return false;
      }

      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        dateOfBirth: dateOfBirth,
        lokasi: lokasi,
      );

      // signUp berhasil — user perlu verifikasi email dulu
      return true;
    } on Exception catch (e) {
      _setError(_parseSupabaseError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // SIGN IN
  // Login dan cek role + verifikasi email.
  // ─────────────────────────────────────────────

  /// Return: 'admin' | 'verified' | 'unverified' | 'error'
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _authService.signIn(email: email, password: password);

      // Ambil profil (termasuk kolom role)
      final profile = await _authService.fetchCurrentUserProfile();

      if (profile?.role == 'admin') {
        // Admin: skip verifikasi email, langsung masuk
        _currentUser = profile;
        notifyListeners();
        return 'admin';       // ← LoginView routing ke AdminHomeView
      }

      // User biasa: wajib verifikasi email
      final isVerified = await _authService.checkEmailVerified();
      if (!isVerified) {
        await _authService.signOut();
        return 'unverified';
      }

      _currentUser = profile;
      notifyListeners();
      return 'verified';
    } on Exception catch (e) {
      _setError(_parseSupabaseError(e.toString()));
      return 'error';
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // SIGN OUT
  // Keluar dari aplikasi dan bersihkan state.
  // ─────────────────────────────────────────────

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // RESEND VERIFICATION EMAIL
  // Kirim ulang email verifikasi.
  // ─────────────────────────────────────────────

  Future<bool> resendVerificationEmail(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.resendVerificationEmail(email);
      return true;
    } on Exception catch (e) {
      _setError(_parseSupabaseError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // CHECK EMAIL VERIFIED
  // Cek status verifikasi dari Supabase (refresh session dulu).
  // ─────────────────────────────────────────────

  Future<bool> checkEmailVerified() async {
    try {
      final verified = await _authService.checkEmailVerified();
      if (verified) {
        await loadCurrentUserProfile();
      }
      return verified;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // LOAD PROFIL
  // Ambil data profil user yang sedang login.
  // ─────────────────────────────────────────────

  Future<void> loadCurrentUserProfile() async {
    final profile = await _authService.fetchCurrentUserProfile();
    _currentUser = profile;
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // UPDATE PROFIL
  // Update nama, lokasi, tanggal lahir.
  // ─────────────────────────────────────────────

  Future<bool> updateProfile({
    required String fullName,
    required String lokasi,
    required DateTime dateOfBirth,
  }) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    _setError(null);

    try {
      await _authService.updateProfile(
        userId: _currentUser!.id,
        updates: {
          'full_name': fullName.trim(),
          'lokasi': lokasi.trim(),
          'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
        },
      );

      // Perbarui state lokal
      _currentUser = _currentUser!.copyWith(
        fullName: fullName.trim(),
        lokasi: lokasi.trim(),
        dateOfBirth: dateOfBirth,
      );
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _setError(_parseSupabaseError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // UPDATE FOTO PROFIL
  // Upload dan simpan foto profil baru.
  // ─────────────────────────────────────────────

  Future<bool> updateProfilePicture(File imageFile) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    _setError(null);

    try {
      // 1. Upload ke Storage
      final avatarUrl = await _storageService.uploadProfilePicture(
        userId: _currentUser!.id,
        imageFile: imageFile,
      );

      // 2. Update URL di database
      await _authService.updateAvatarUrl(
        userId: _currentUser!.id,
        avatarUrl: avatarUrl,
      );

      // 3. Update state lokal
      _currentUser = _currentUser!.copyWith(avatarUrl: avatarUrl);
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _setError(_parseSupabaseError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // HELPER: parse pesan error Supabase ke bahasa Indonesia
  // ─────────────────────────────────────────────

  String _parseSupabaseError(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Email atau password salah. Periksa kembali.';
    }
    if (error.contains('Email not confirmed')) {
      return 'Email belum diverifikasi. Cek inbox/spam emailmu.';
    }
    if (error.contains('User already registered')) {
      return 'Email ini sudah terdaftar. Silakan login.';
    }
    if (error.contains('Password should be at least')) {
      return 'Password terlalu pendek (minimal 8 karakter).';
    }
    if (error.contains('rate limit')) {
      return 'Terlalu banyak percobaan. Tunggu beberapa menit.';
    }
    if (error.contains('network') || error.contains('connection')) {
      return 'Koneksi internet bermasalah. Periksa koneksimu.';
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }
}
