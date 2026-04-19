import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/laporan_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'status_badge.dart';

class LaporanCard extends StatelessWidget {
  final LaporanModel laporan;
  final VoidCallback onTap;
  final bool showPetugas;

  const LaporanCard({
    required this.laporan,
    required this.onTap,
    this.showPetugas = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail foto
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppRadius.lg)),
              child: laporan.fotoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: laporan.fotoUrl!,
                      width: 90,
                      height: 110,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _imagePlaceholder(),
                      errorWidget: (_, __, ___) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),

            // Konten
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori + status
                    Row(
                      children: [
                        _kategoriBadge(laporan.kategori),
                        const Spacer(),
                        StatusBadge(status: laporan.status, small: true),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Judul
                    Text(
                      laporan.judul,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Deskripsi singkat
                    Text(
                      laporan.deskripsi,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                          height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Lokasi + tanggal
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.textHint),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            laporan.lokasi,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textHint),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          Helpers.formatDate(laporan.createdAt),
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textHint),
                        ),
                      ],
                    ),

                    // Info petugas (opsional)
                    if (showPetugas && laporan.petugasNama != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.engineering_outlined,
                              size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            laporan.petugasNama!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Arrow
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.chevron_right_rounded,
                  color: AppColors.textHint, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 90,
      height: 110,
      color: AppColors.primaryBg,
      child: const Icon(Icons.image_outlined, color: AppColors.primary, size: 28),
    );
  }

  Widget _kategoriBadge(String kategori) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        kategori,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
