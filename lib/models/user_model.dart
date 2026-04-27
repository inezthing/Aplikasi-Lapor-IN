// lib/models/user_model.dart
// Model murni — hanya struktur data + fromJson/toJson. Tanpa logika bisnis.

class UserModel {
  final String id;
  final String? fullName;
  final String? email;
  final DateTime? dateOfBirth;
  final String? lokasi;
  final String? avatarUrl;
  final bool isVerified;
  // FIX: tambahkan field role untuk mendukung pengecekan admin
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    this.fullName,
    this.email,
    this.dateOfBirth,
    this.lokasi,
    this.avatarUrl,
    this.isVerified = false,
    this.role = 'user',
    this.createdAt,
    this.updatedAt,
  });

  bool get isAdmin => role == 'admin';

  /// Buat UserModel dari Map JSON yang datang dari Supabase
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      lokasi: json['lokasi'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      role: json['role'] as String? ?? 'user',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Konversi ke Map JSON untuk dikirim ke Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'lokasi': lokasi,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
      'role': role,
    };
  }

  /// Buat salinan dengan nilai yang diubah (immutable pattern)
  UserModel copyWith({
    String? fullName,
    String? email,
    DateTime? dateOfBirth,
    String? lokasi,
    String? avatarUrl,
    bool? isVerified,
    String? role,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      lokasi: lokasi ?? this.lokasi,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      role: role ?? this.role,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, fullName: $fullName, email: $email, role: $role)';
}
