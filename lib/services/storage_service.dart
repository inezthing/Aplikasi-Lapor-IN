// lib/services/storage_service.dart
// Menangani semua operasi upload/download foto ke Supabase Storage.

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/helpers.dart';
import 'supabase_service.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final _db = SupabaseService.instance;

  // ─────────────────────────────────────────────
  // AVATAR
  // ─────────────────────────────────────────────

  /// Upload foto profil ke bucket 'avatars'.
  /// Mengembalikan public URL foto yang bisa langsung dipakai di Image.network().
  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    final path = Helpers.avatarPath(userId);

    // Upsert = upload atau replace kalau sudah ada
    await _db.avatarBucket.upload(
      path,
      imageFile,
      fileOptions: const FileOptions(
        upsert: true,
        contentType: 'image/jpeg',
      ),
    );

    return getAvatarPublicUrl(userId);
  }

  /// Dapatkan public URL foto profil.
  String getAvatarPublicUrl(String userId) {
    return _db.avatarBucket.getPublicUrl(Helpers.avatarPath(userId));
  }

  // ─────────────────────────────────────────────
  // FOTO LAPORAN
  // ─────────────────────────────────────────────

  /// Upload foto untuk laporan baru.
  /// Mengembalikan public URL.
  Future<String> uploadLaporanPhoto({
    required String laporanId,
    required File imageFile,
  }) async {
    final path = Helpers.laporanPhotoPath(laporanId);

    await _db.laporanPhotoBucket.upload(
      path,
      imageFile,
      fileOptions: const FileOptions(
        upsert: false,
        contentType: 'image/jpeg',
      ),
    );

    return _db.laporanPhotoBucket.getPublicUrl(path);
  }

  // ─────────────────────────────────────────────
  // FOTO PROGRESS
  // ─────────────────────────────────────────────

  /// Upload foto progress pengerjaan.
  /// Path disimpan di subfolder 'progress/{laporanId}/'.
  /// Mengembalikan public URL.
  Future<String> uploadProgressPhoto({
    required String laporanId,
    required File imageFile,
  }) async {
    final path = Helpers.progressPhotoPath(laporanId);

    await _db.laporanPhotoBucket.upload(
      path,
      imageFile,
      fileOptions: const FileOptions(
        upsert: false,
        contentType: 'image/jpeg',
      ),
    );

    return _db.laporanPhotoBucket.getPublicUrl(path);
  }

  // ─────────────────────────────────────────────
  // HAPUS FILE
  // ─────────────────────────────────────────────

  /// Hapus file dari bucket (untuk clean-up jika laporan dihapus).
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await _db.client.storage.from(bucket).remove([path]);
  }
}
