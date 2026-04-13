import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../widgets/laporan_card.dart';
import 'detail_kasus_page.dart';

class HomePage extends StatelessWidget {
  final Function(int) onNavigate;

  const HomePage({required this.onNavigate, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = AppStateInherited.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, state)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Laporan Terkini',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E))),
                  GestureDetector(
                    onTap: () => onNavigate(2),
                    child: const Text('Lihat Semua',
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1A6BFF),
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final laporan = state.highlightedLaporan;
                  if (index >= laporan.length) return null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LaporanCard(
                      laporan: laporan[index],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DetailKasusPage(
                              laporan: laporan[index], state: state),
                        ),
                      ),
                    ),
                  );
                },
                childCount: state.highlightedLaporan.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState state) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A3FCC), Color(0xFF1A6BFF)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Halo, ${state.userName}! 👋',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Row(children: [
                          const Icon(Icons.location_on_outlined,
                              color: Colors.white70, size: 12),
                          const SizedBox(width: 3),
                          Text(state.userLocation,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ]),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: const Icon(Icons.notifications_none_rounded,
                        color: Colors.white, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Laporkan Keluhanmu!',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Bantu perbaiki fasilitas umum dengan melaporkannya.',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                            height: 1.4)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => onNavigate(1),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Buat Laporan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1A6BFF),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _statItem('Total', '${state.laporanList.length}'),
                  const SizedBox(width: 12),
                  _statItem('Dikerjakan',
                      '${state.laporanList.where((l) => l.status == StatusLaporan.dikerjakan).length}'),
                  const SizedBox(width: 12),
                  _statItem('Selesai',
                      '${state.laporanList.where((l) => l.status == StatusLaporan.selesai).length}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.75), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
