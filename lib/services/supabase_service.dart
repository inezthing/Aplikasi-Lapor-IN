// lib/services/supabase_service.dart
// Singleton yang menyediakan akses ke Supabase client.
// Semua service lain menggunakan kelas ini untuk mendapat client.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  /// Supabase client — akses ke auth, database, storage
  SupabaseClient get client => Supabase.instance.client;

  /// Auth client shortcut
  GoTrueClient get auth => client.auth;

  /// User yang sedang login, null jika belum login
  User? get currentUser => auth.currentUser;

  /// ID user yang sedang login
  String? get currentUserId => currentUser?.id;

  /// Apakah ada user yang sedang login
  bool get isLoggedIn => currentUser != null;

  /// Stream perubahan sesi (login/logout)
  Stream<AuthState> get authStateStream => auth.onAuthStateChange;

  // ─────────────────────────────────────────────
  // DATABASE QUERY BUILDERS
  // Shortcut untuk mengakses tabel dengan nama yang benar
  // ─────────────────────────────────────────────

  /// Query builder untuk tabel 'profiles'
  SupabaseQueryBuilder get profilesTable => client.from('profiles');

  /// Query builder untuk tabel 'laporan'
  SupabaseQueryBuilder get laporanTable => client.from('laporan');

  /// Query builder untuk tabel 'progress_updates'
  SupabaseQueryBuilder get progressTable => client.from('progress_updates');

  // ─────────────────────────────────────────────
  // STORAGE BUCKET CLIENTS
  // ─────────────────────────────────────────────

  /// Bucket untuk avatar pengguna
  StorageFileApi get avatarBucket =>
      client.storage.from(SupabaseConfig.avatarBucket);

  /// Bucket untuk foto laporan dan progress
  StorageFileApi get laporanPhotoBucket =>
      client.storage.from(SupabaseConfig.laporanPhotoBucket);

  // ─────────────────────────────────────────────
  // INISIALISASI — dipanggil di main.dart
  // ─────────────────────────────────────────────

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }
}
