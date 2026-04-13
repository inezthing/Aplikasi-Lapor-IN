import 'package:flutter/material.dart';
import '../models/app_state.dart';

class DetailKasusPage extends StatelessWidget {
  final LaporanModel laporan;
  final AppState state;

  const DetailKasusPage({required this.laporan, required this.state, Key? key}) : super(key: key);

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: CustomScrollView(
        slivers: [
          // Hero image app bar
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF1A6BFF),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Color(0xFF1A1A2E), size: 20),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: laporan.fotoPath != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          laporan.fotoPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF1A6BFF),
                            child: const Icon(Icons.image_outlined,
                                color: Colors.white54, size: 60),
                          ),
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: const Color(0xFF1A6BFF),
                      child: const Icon(Icons.report_problem_rounded,
                          color: Colors.white54, size: 80),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status + kategori row
                  Row(
                    children: [
                      _statusBadge(laporan.status),
                      const SizedBox(width: 8),
                      _kategoriChip(laporan.kategori),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 13, color: Color(0xFF8A94A6)),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(laporan.tanggal),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8A94A6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Judul
                  Text(
                    laporan.judul,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Lokasi
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF3FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.location_on_rounded,
                            color: Color(0xFF1A6BFF), size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          laporan.lokasi,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4A5568),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFEEF3FF), thickness: 1.5),
                  const SizedBox(height: 20),

                  // Deskripsi
                  const Text(
                    'Deskripsi Kerusakan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE0E7FF)),
                    ),
                    child: Text(
                      laporan.deskripsi,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4A5568),
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Timeline status
                  const Text(
                    'Timeline Status',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTimeline(laporan.status),

                  const SizedBox(height: 24),

                  // Action button - Tanggapi
                  if (laporan.status == StatusLaporan.belumDimulai) ...[
                    const Divider(color: Color(0xFFEEF3FF), thickness: 1.5),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF3FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFF1A6BFF).withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ambil Tindakan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Klik tombol di bawah untuk menanggapi laporan ini. Status akan berubah menjadi "Dikerjakan".',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                state.ubahStatus(laporan.id, StatusLaporan.dikerjakan);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.check_circle_rounded,
                                            color: Colors.white),
                                        SizedBox(width: 10),
                                        Text('Status diubah ke Dikerjakan!'),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF1A6BFF),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Tanggapi Kasus Ini'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A6BFF),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (laporan.status == StatusLaporan.dikerjakan) ...[
                    const Divider(color: Color(0xFFEEF3FF), thickness: 1.5),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          state.ubahStatus(laporan.id, StatusLaporan.selesai);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Tandai Selesai'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C896),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(StatusLaporan status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
      ),
    );
  }

  Widget _kategoriChip(String kategori) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: Text(
        kategori,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF8A94A6),
        ),
      ),
    );
  }

  Widget _buildTimeline(StatusLaporan current) {
    final steps = [
      StatusLaporan.belumDimulai,
      StatusLaporan.dikerjakan,
      StatusLaporan.selesai,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: Column(
        children: steps.asMap().entries.map((e) {
          final idx = e.key;
          final step = e.value;
          final isDone = steps.indexOf(current) >= idx;
          final isLast = idx == steps.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? step.color : const Color(0xFFE0E7FF),
                    ),
                    child: Icon(
                      isDone ? Icons.check_rounded : Icons.circle,
                      color: Colors.white,
                      size: isDone ? 14 : 8,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 30,
                      color: isDone ? step.color.withOpacity(0.3) : const Color(0xFFE0E7FF),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  step.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
                    color: isDone ? const Color(0xFF1A1A2E) : const Color(0xFF8A94A6),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
