// lib/models/laporan_model.dart

class LaporanModel {
  final String id;
  final String pelaporId;
  final String? petugasId;
  final String judul;
  final String kategori;
  final String lokasi;
  final String deskripsi;
  final String? fotoUrl;
  final String status;
  final bool isLocked;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Data join dari tabel profiles (opsional, diisi saat query dengan join)
  final String? pelaporNama;
  final String? pelaporAvatarUrl;
  final String? petugasNama;
  final String? petugasAvatarUrl;

  const LaporanModel({
    required this.id,
    required this.pelaporId,
    this.petugasId,
    required this.judul,
    required this.kategori,
    required this.lokasi,
    required this.deskripsi,
    this.fotoUrl,
    required this.status,
    required this.isLocked,
    required this.createdAt,
    this.updatedAt,
    this.pelaporNama,
    this.pelaporAvatarUrl,
    this.petugasNama,
    this.petugasAvatarUrl,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    // Handle nested join dari Supabase (.select('*, pelapor:profiles!pelapor_id(...), petugas:profiles!petugas_id(...)'))
    final pelaporData = json['pelapor'] as Map<String, dynamic>?;
    final petugasData = json['petugas'] as Map<String, dynamic>?;

    return LaporanModel(
      id: json['id'] as String,
      pelaporId: json['pelapor_id'] as String,
      petugasId: json['petugas_id'] as String?,
      judul: json['judul'] as String,
      kategori: json['kategori'] as String,
      lokasi: json['lokasi'] as String,
      deskripsi: json['deskripsi'] as String,
      fotoUrl: json['foto_url'] as String?,
      status: json['status'] as String? ?? 'belum_dimulai',
      isLocked: json['is_locked'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      pelaporNama: pelaporData?['full_name'] as String?,
      pelaporAvatarUrl: pelaporData?['avatar_url'] as String?,
      petugasNama: petugasData?['full_name'] as String?,
      petugasAvatarUrl: petugasData?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pelapor_id': pelaporId,
      'judul': judul,
      'kategori': kategori,
      'lokasi': lokasi,
      'deskripsi': deskripsi,
      'foto_url': fotoUrl,
      'status': status,
      'is_locked': isLocked,
    };
  }

  LaporanModel copyWith({
    String? petugasId,
    String? status,
    bool? isLocked,
    String? fotoUrl,
    String? petugasNama,
    String? petugasAvatarUrl,
  }) {
    return LaporanModel(
      id: id,
      pelaporId: pelaporId,
      petugasId: petugasId ?? this.petugasId,
      judul: judul,
      kategori: kategori,
      lokasi: lokasi,
      deskripsi: deskripsi,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      status: status ?? this.status,
      isLocked: isLocked ?? this.isLocked,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      pelaporNama: pelaporNama,
      pelaporAvatarUrl: pelaporAvatarUrl,
      petugasNama: petugasNama ?? this.petugasNama,
      petugasAvatarUrl: petugasAvatarUrl ?? this.petugasAvatarUrl,
    );
  }

  /// Apakah laporan ini milik user dengan userId tertentu (sebagai pelapor)
  bool isSubmittedBy(String userId) => pelaporId == userId;

  /// Apakah laporan ini sedang ditangani oleh user dengan userId tertentu
  bool isHandledBy(String userId) => petugasId == userId;

  @override
  String toString() => 'LaporanModel(id: $id, judul: $judul, status: $status)';
}
