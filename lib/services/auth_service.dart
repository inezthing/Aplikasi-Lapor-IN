// lib/services/auth_service.dart
// Berkomunikasi langsung dengan Supabase Auth & tabel profiles.
// Dipanggil oleh AuthController, TIDAK oleh View.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _db = SupabaseService.instance;

  // ─────────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────────

  /// Mendaftarkan user baru ke Supabase Auth.
  /// Trigger di database akan otomatis membuat baris di tabel profiles.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required DateTime dateOfBirth,
    required String lokasi,
  }) async {
    final response = await _db.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName.trim(),
        'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
        'lokasi': lokasi.trim(),
      },
    );
    return response;
  }

  // ─────────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────────

  /// Login dengan email dan password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _db.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ─────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────

  Future<void> signOut() async {
    await _db.auth.signOut();
  }

  // ─────────────────────────────────────────────
  // VERIFIKASI EMAIL
  // ─────────────────────────────────────────────

  /// Kirim ulang email verifikasi ke alamat yang diberikan.
  Future<void> resendVerificationEmail(String email) async {
    await _db.auth.resend(
      type: OtpType.signup,
      email: email.trim(),
    );
  }

  /// Cek apakah email user sudah dikonfirmasi.
  /// Refresh session dulu agar data terbaru.
  Future<bool> checkEmailVerified() async {
    await _db.auth.refreshSession();
    final user = _db.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  // ─────────────────────────────────────────────
  // PROFIL
  // ─────────────────────────────────────────────

  /// Ambil data profil user yang sedang login dari tabel profiles.
  Future<UserModel?> fetchCurrentUserProfile() async {
    final userId = _db.currentUserId;
    if (userId == null) return null;

    final data = await _db.profilesTable
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  /// Update kolom-kolom profil pengguna.
  Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    await _db.profilesTable.update(updates).eq('id', userId);
  }

  /// Update URL avatar di profil.
  Future<void> updateAvatarUrl({
    required String userId,
    required String avatarUrl,
  }) async {
    await _db.profilesTable.update({
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }
}
