// lib/models/progress_model.dart

class ProgressModel {
  final String id;
  final String laporanId;
  final String petugasId;
  final String deskripsi;
  final String fotoUrl;
  final DateTime waktu;
  final int bulan;
  final int tahun;

  // Join dari profiles
  final String? petugasNama;
  final String? petugasAvatarUrl;

  const ProgressModel({
    required this.id,
    required this.laporanId,
    required this.petugasId,
    required this.deskripsi,
    required this.fotoUrl,
    required this.waktu,
    required this.bulan,
    required this.tahun,
    this.petugasNama,
    this.petugasAvatarUrl,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    final petugasData = json['petugas'] as Map<String, dynamic>?;
    final waktu = DateTime.parse(json['waktu'] as String);

    return ProgressModel(
      id: json['id'] as String,
      laporanId: json['laporan_id'] as String,
      petugasId: json['petugas_id'] as String,
      deskripsi: json['deskripsi'] as String,
      fotoUrl: json['foto_url'] as String,
      waktu: waktu,
      bulan: json['bulan'] as int? ?? waktu.month,
      tahun: json['tahun'] as int? ?? waktu.year,
      petugasNama: petugasData?['full_name'] as String?,
      petugasAvatarUrl: petugasData?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'laporan_id': laporanId,
      'petugas_id': petugasId,
      'deskripsi': deskripsi,
      'foto_url': fotoUrl,
      'waktu': waktu.toIso8601String(),
    };
  }

  @override
  String toString() => 'ProgressModel(id: $id, laporanId: $laporanId, waktu: $waktu)';
}
