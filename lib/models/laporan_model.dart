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
  final DateTime? tanggalAmbil;

  // ── Fitur batalkan / teruskan ──
  final String? dibatalkanAlasan;
  final bool diteruskanKePemerintah;

  // ── Verifikasi admin ──
  // null = belum diajukan verifikasi
  // 'menunggu_verifikasi' = user sudah pencet selesaikan, nunggu admin
  // 'bukti_kurang' = admin minta tambah bukti
  // 'disetujui' = admin setuju selesai
  // 'diteruskan' = admin setuju teruskan ke pemerintah
  // 'dibatalkan_admin' = admin tolak terusan ke pemerintah
  final String? verifikasiStatus;
  final String? verifikasiCatatan;
  final DateTime? verifikasiAt;
  final String? verifikasiOleh;

  // Join dari profiles
  final String? pelaporNama;
  final String? pelaporAvatarUrl;
  final String? petugasNama;
  final String? petugasAvatarUrl;
  final String? adminNama;

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
    this.tanggalAmbil,
    this.dibatalkanAlasan,
    this.diteruskanKePemerintah = false,
    this.verifikasiStatus,
    this.verifikasiCatatan,
    this.verifikasiAt,
    this.verifikasiOleh,
    this.pelaporNama,
    this.pelaporAvatarUrl,
    this.petugasNama,
    this.petugasAvatarUrl,
    this.adminNama,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    final pelaporData = json['pelapor'] as Map<String, dynamic>?;
    final petugasData = json['petugas'] as Map<String, dynamic>?;
    final adminData = json['admin'] as Map<String, dynamic>?;

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
      tanggalAmbil: json['tanggal_ambil'] != null
          ? DateTime.tryParse(json['tanggal_ambil'] as String)
          : null,
      dibatalkanAlasan: json['dibatalkan_alasan'] as String?,
      diteruskanKePemerintah:
          json['diteruskan_ke_pemerintah'] as bool? ?? false,
      verifikasiStatus: json['verifikasi_status'] as String?,
      verifikasiCatatan: json['verifikasi_catatan'] as String?,
      verifikasiAt: json['verifikasi_at'] != null
          ? DateTime.tryParse(json['verifikasi_at'] as String)
          : null,
      verifikasiOleh: json['verifikasi_oleh'] as String?,
      pelaporNama: pelaporData?['full_name'] as String?,
      pelaporAvatarUrl: pelaporData?['avatar_url'] as String?,
      petugasNama: petugasData?['full_name'] as String?,
      petugasAvatarUrl: petugasData?['avatar_url'] as String?,
      adminNama: adminData?['full_name'] as String?,
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
    DateTime? tanggalAmbil,
    String? dibatalkanAlasan,
    bool? diteruskanKePemerintah,
    String? verifikasiStatus,
    String? verifikasiCatatan,
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
      tanggalAmbil: tanggalAmbil ?? this.tanggalAmbil,
      dibatalkanAlasan: dibatalkanAlasan ?? this.dibatalkanAlasan,
      diteruskanKePemerintah:
          diteruskanKePemerintah ?? this.diteruskanKePemerintah,
      verifikasiStatus: verifikasiStatus ?? this.verifikasiStatus,
      verifikasiCatatan: verifikasiCatatan ?? this.verifikasiCatatan,
      verifikasiAt: this.verifikasiAt,
      verifikasiOleh: this.verifikasiOleh,
      pelaporNama: pelaporNama,
      pelaporAvatarUrl: pelaporAvatarUrl,
      petugasNama: petugasNama ?? this.petugasNama,
      petugasAvatarUrl: petugasAvatarUrl ?? this.petugasAvatarUrl,
      adminNama: adminNama,
    );
  }

  bool isSubmittedBy(String userId) => pelaporId == userId;
  bool isHandledBy(String userId) => petugasId == userId;

  /// Apakah kasus sudah kedaluwarsa (30 hari tanpa progress setelah diambil)
  bool get isExpired {
    if (tanggalAmbil == null) return false;
    if (status == 'selesai' || status == 'belum_dimulai') return false;
    return DateTime.now().difference(tanggalAmbil!).inDays >= 30;
  }

  /// Apakah kasus sedang menunggu verifikasi admin
  bool get isMenungguVerifikasi =>
      verifikasiStatus == 'menunggu_verifikasi';

  /// Apakah kasus sedang menunggu persetujuan terusan ke pemerintah
  bool get isMenungguTerusan =>
      diteruskanKePemerintah && verifikasiStatus == 'menunggu_verifikasi';

  @override
  String toString() =>
      'LaporanModel(id: $id, judul: $judul, status: $status, verifikasi: $verifikasiStatus)';
}
