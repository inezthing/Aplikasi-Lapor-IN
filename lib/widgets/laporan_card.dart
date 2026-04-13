import 'package:flutter/material.dart';
import '../models/app_state.dart';

class LaporanCard extends StatelessWidget {
  final LaporanModel laporan;
  final VoidCallback onTap;

  const LaporanCard({required this.laporan, required this.onTap, Key? key})
      : super(key: key);

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEF3FF)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A6BFF).withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Foto thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: laporan.fotoPath != null
                  ? Image.network(
                      laporan.fotoPath!,
                      width: 90,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori + status
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF3FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            laporan.kategori,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF1A6BFF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _StatusDot(status: laporan.status),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Judul
                    Text(
                      laporan.judul,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Deskripsi
                    Text(
                      laporan.deskripsi,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Lokasi + tanggal
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: Color(0xFF8A94A6)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            laporan.lokasi,
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF8A94A6)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatDate(laporan.tanggal),
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF8A94A6)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Arrow
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF8A94A6), size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 90,
      height: 100,
      color: const Color(0xFFEEF3FF),
      child: const Icon(Icons.image_outlined, color: Color(0xFF1A6BFF), size: 28),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final StatusLaporan status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
      ),
    );
  }
}
