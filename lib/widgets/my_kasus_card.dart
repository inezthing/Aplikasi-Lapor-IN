import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/laporan_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'status_badge.dart';

/// Card untuk menampilkan kasus yang sedang DITANGANI oleh user yang login.
/// Dipakai di widget personal HomePage.
class MyKasusCard extends StatelessWidget {
  final LaporanModel laporan;
  final VoidCallback onTap;

  const MyKasusCard({
    required this.laporan,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg)),
              child: laporan.fotoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: laporan.fotoUrl!,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _imgPlaceholder(),
                      errorWidget: (_, __, ___) => _imgPlaceholder(),
                    )
                  : _imgPlaceholder(),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status
                  StatusBadge(status: laporan.status, small: true),
                  const SizedBox(height: 6),

                  // Judul
                  Text(
                    laporan.judul,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Lokasi
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 11, color: AppColors.textHint),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          laporan.lokasi,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textHint),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Tanggal diambil
                  Text(
                    'Diambil ${Helpers.formatRelative(laporan.updatedAt ?? laporan.createdAt)}',
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      height: 110,
      color: AppColors.primaryBg,
      child: const Center(
        child: Icon(Icons.engineering_outlined,
            color: AppColors.primary, size: 32),
      ),
    );
  }
}
