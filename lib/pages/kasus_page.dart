import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../widgets/laporan_card.dart';
import 'detail_kasus_page.dart';

class KasusPage extends StatefulWidget {
  const KasusPage({Key? key}) : super(key: key);

  @override
  State<KasusPage> createState() => _KasusPageState();
}

class _KasusPageState extends State<KasusPage> {
  StatusLaporan? _filterStatus;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final state = AppStateInherited.of(context);
    final filtered = state.laporanList.where((l) {
      final matchStatus = _filterStatus == null || l.status == _filterStatus;
      final matchSearch = _search.isEmpty ||
          l.judul.toLowerCase().contains(_search.toLowerCase()) ||
          l.lokasi.toLowerCase().contains(_search.toLowerCase());
      return matchStatus && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: const Color(0xFF1A6BFF),
            expandedHeight: 130,
            floating: false,
            pinned: true,
            leading: const SizedBox(),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A3FCC), Color(0xFF1A6BFF)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kasus Aktif',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${state.laporanList.length} laporan terdaftar',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            title: innerBoxIsScrolled
                ? const Text(
                    'Kasus Aktif',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  )
                : null,
          ),
        ],
        body: Column(
          children: [
            // Search + filter
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: 'Cari laporan...',
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Color(0xFF8A94A6), size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip(null, 'Semua'),
                        const SizedBox(width: 8),
                        _filterChip(StatusLaporan.belumDimulai, 'Belum Dimulai'),
                        const SizedBox(width: 8),
                        _filterChip(StatusLaporan.dikerjakan, 'Dikerjakan'),
                        const SizedBox(width: 8),
                        _filterChip(StatusLaporan.tertunda, 'Tertunda'),
                        const SizedBox(width: 8),
                        _filterChip(StatusLaporan.selesai, 'Selesai'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: filtered.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return LaporanCard(
                          laporan: filtered[index],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailKasusPage(
                                laporan: filtered[index],
                                state: state,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(StatusLaporan? status, String label) {
    final isSelected = _filterStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A6BFF) : const Color(0xFFF5F7FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A6BFF) : const Color(0xFFE0E7FF),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF8A94A6),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Tidak ada laporan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada laporan yang sesuai filter',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
