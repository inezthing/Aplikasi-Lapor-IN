// lib/widgets/progress_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/progress_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ProgressCard extends StatelessWidget {
  final ProgressModel progress;

  const ProgressCard({required this.progress, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto progress
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg)),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: progress.fotoUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 180,
                    color: AppColors.primaryBg,
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 180,
                    color: AppColors.primaryBg,
                    child: const Icon(Icons.broken_image_outlined,
                        color: AppColors.primary),
                  ),
                ),
                // Timestamp overlay di pojok kanan bawah
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      Helpers.formatDateTime(progress.waktu),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama petugas
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primaryBg,
                      child: Text(
                        Helpers.getInitials(progress.petugasNama),
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          progress.petugasNama ?? 'Petugas',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          Helpers.formatRelative(progress.waktu),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Deskripsi progress
                Text(
                  progress.deskripsi,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
