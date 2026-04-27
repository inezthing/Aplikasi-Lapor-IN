// lib/views/laporan/kasus_list_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/laporan_controller.dart';
import '../../controllers/kasus_controller.dart';
import '../../utils/constants.dart';
import '../../widgets/laporan_card.dart';
import '../kasus/detail_kasus_view.dart';

class KasusListView extends StatefulWidget {
  const KasusListView({Key? key}) : super(key: key);

  @override
  State<KasusListView> createState() => _KasusListViewState();
}

class _KasusListViewState extends State<KasusListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String? _filterStatus;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    await Future.wait([
      context.read<LaporanController>().getAvailableLaporan(),
      context.read<KasusController>().getMyActiveCases(),
    ]);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lapCtrl = context.watch<LaporanController>();
    final kasusCtrl = context.watch<KasusController>();

    final available = lapCtrl.availableLaporan.where((l) {
      final matchStatus =
          _filterStatus == null || l.status == _filterStatus;
      final matchSearch = _search.isEmpty ||
          l.judul.toLowerCase().contains(_search.toLowerCase()) ||
          l.lokasi.toLowerCase().contains(_search.toLowerCase()) ||
          l.kategori.toLowerCase().contains(_search.toLowerCase());
      return matchStatus && matchSearch;
    }).toList();

    final myKasus = kasusCtrl.myActiveCases.where((k) {
      return _search.isEmpty ||
          k.judul.toLowerCase().contains(_search.toLowerCase()) ||
          k.lokasi.toLowerCase().contains(_search.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerScrolled) => [
          SliverAppBar(
            backgroundColor: AppColors.primary,
            expandedHeight: 120,
            pinned: true,
            floating: false,
            leading: const SizedBox(),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Semua Kasus',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${available.length} tersedia · ${myKasus.length} saya tangani',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            title: innerScrolled
                ? const Text('Semua Kasus',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600))
                : null,
            bottom: TabBar(
              controller: _tabCtrl,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14),
              tabs: [
                Tab(text: 'Tersedia (${available.length})'),
                Tab(text: 'Kasus Saya (${myKasus.length})'),
              ],
            ),
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
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: 'Cari judul, lokasi, atau kategori...',
                      hintStyle: const TextStyle(
                          color: AppColors.textHint, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.textHint, size: 20),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  color: AppColors.textHint, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _search = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _chip(null, 'Semua'),
                        const SizedBox(width: 8),
                        _chip(AppStatus.belumDimulai, 'Belum Dimulai'),
                        const SizedBox(width: 8),
                        _chip(AppStatus.dikerjakan, 'Dikerjakan'),
                        const SizedBox(width: 8),
                        _chip(AppStatus.tertunda, 'Tertunda'),
                        const SizedBox(width: 8),
                        _chip(AppStatus.selesai, 'Selesai'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  // Tab Tersedia
                  _LaporanList(
                    items: available,
                    isLoading: lapCtrl.isLoading,
                    emptyMsg: 'Tidak ada laporan tersedia',
                    onRefresh: _loadAll,
                    onItemTap: (laporanId) async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DetailKasusView(laporanId: laporanId),
                        ),
                      );
                      // Refresh keduanya setelah balik dari detail
                      if (mounted) await _loadAll();
                    },
                  ),
                  // Tab Kasus Saya
                  _LaporanList(
                    items: myKasus,
                    isLoading: kasusCtrl.isLoading,
                    emptyMsg: 'Kamu belum mengambil kasus apapun',
                    onRefresh: _loadAll,
                    onItemTap: (laporanId) async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DetailKasusView(laporanId: laporanId),
                        ),
                      );
                      if (mounted) await _loadAll();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String? status, String label) {
    final isSelected = _filterStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textHint,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LIST WIDGET
// ─────────────────────────────────────────────
class _LaporanList extends StatelessWidget {
  final List items;
  final bool isLoading;
  final String emptyMsg;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String laporanId) onItemTap;

  const _LaporanList({
    required this.items,
    required this.isLoading,
    required this.emptyMsg,
    required this.onRefresh,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2));
    }
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open_rounded,
                size: 60, color: AppColors.border),
            const SizedBox(height: 14),
            Text(emptyMsg,
                style:
                    const TextStyle(color: AppColors.textHint, fontSize: 14)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final lap = items[i];
          return LaporanCard(
            laporan: lap,
            showPetugas: true,
            onTap: () => onItemTap(lap.id),
          );
        },
      ),
    );
  }
}
