import 'package:flutter/material.dart';
import '../models/app_state.dart';

class LaporanPage extends StatefulWidget {
  final VoidCallback? onLaporanSent;

  const LaporanPage({this.onLaporanSent, Key? key}) : super(key: key);

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final _judulCtrl = TextEditingController();
  final _lokasiCtrl = TextEditingController();
  final _deskCtrl = TextEditingController();
  String? _selectedKategori;
  String? _selectedFotoPath;
  bool _loading = false;

  final List<String> _kategoriList = [
    'Infrastruktur',
    'Lingkungan',
    'Penerangan',
    'Drainase',
    'Fasilitas Umum',
    'Lainnya',
  ];

  // Dummy foto options
  final List<Map<String, String>> _fotoOptions = [
    {'label': 'Jalan Berlubang', 'url': 'https://images.unsplash.com/photo-1515162305285-0293e4767cc2?w=400'},
    {'label': 'Sampah', 'url': 'https://images.unsplash.com/photo-1604187351574-c75ca79f5807?w=400'},
    {'label': 'Lampu Mati', 'url': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400'},
    {'label': 'Air Bocor', 'url': 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=400'},
  ];

  @override
  void dispose() {
    _judulCtrl.dispose();
    _lokasiCtrl.dispose();
    _deskCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_judulCtrl.text.isEmpty ||
        _selectedKategori == null ||
        _lokasiCtrl.text.isEmpty ||
        _deskCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Harap isi semua kolom yang wajib'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final state = AppStateInherited.of(context);
    state.tambahLaporan(
      LaporanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        judul: _judulCtrl.text,
        kategori: _selectedKategori!,
        lokasi: _lokasiCtrl.text,
        deskripsi: _deskCtrl.text,
        fotoPath: _selectedFotoPath,
        tanggal: DateTime.now(),
      ),
    );

    setState(() => _loading = false);

    // Reset form
    _judulCtrl.clear();
    _lokasiCtrl.clear();
    _deskCtrl.clear();
    setState(() {
      _selectedKategori = null;
      _selectedFotoPath = null;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text('Laporan berhasil dikirim!'),
          ],
        ),
        backgroundColor: const Color(0xFF00C896),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    widget.onLaporanSent?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan'),
        leading: const SizedBox(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A6BFF), Color(0xFF4D8FFF)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.report_problem_rounded, color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Laporkan Keluhanmu!',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Isi form di bawah dengan lengkap dan jelas',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _sectionLabel('Judul Laporan *'),
            const SizedBox(height: 8),
            TextField(
              controller: _judulCtrl,
              decoration: const InputDecoration(
                hintText: 'Contoh: Jalan berlubang di depan SD',
                prefixIcon: Icon(Icons.title_rounded, color: Color(0xFF1A6BFF), size: 20),
              ),
            ),

            const SizedBox(height: 18),
            _sectionLabel('Kategori *'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E7FF)),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedKategori,
                hint: const Text('Pilih kategori'),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_rounded, color: Color(0xFF1A6BFF), size: 20),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                items: _kategoriList
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedKategori = v),
                borderRadius: BorderRadius.circular(12),
                dropdownColor: Colors.white,
              ),
            ),

            const SizedBox(height: 18),
            _sectionLabel('Lokasi *'),
            const SizedBox(height: 8),
            TextField(
              controller: _lokasiCtrl,
              decoration: const InputDecoration(
                hintText: 'Contoh: Jl. Mawar No. 5, Indralaya',
                prefixIcon:
                    Icon(Icons.location_on_outlined, color: Color(0xFF1A6BFF), size: 20),
              ),
            ),

            const SizedBox(height: 18),
            _sectionLabel('Deskripsi *'),
            const SizedBox(height: 8),
            TextField(
              controller: _deskCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Jelaskan kerusakan secara detail...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child:
                      Icon(Icons.description_outlined, color: Color(0xFF1A6BFF), size: 20),
                ),
              ),
            ),

            const SizedBox(height: 18),
            _sectionLabel('Bukti Foto'),
            const SizedBox(height: 8),
            Text(
              'Pilih foto (simulasi dari galeri)',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _fotoOptions.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF3FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF1A6BFF).withOpacity(0.3),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                color: Color(0xFF1A6BFF), size: 24),
                            SizedBox(height: 4),
                            Text('Tambah',
                                style: TextStyle(fontSize: 11, color: Color(0xFF1A6BFF))),
                          ],
                        ),
                      ),
                    );
                  }
                  final foto = _fotoOptions[index - 1];
                  final isSelected = _selectedFotoPath == foto['url'];
                  return GestureDetector(
                    onTap: () => setState(() =>
                        _selectedFotoPath = isSelected ? null : foto['url']),
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF1A6BFF)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              foto['url']!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_outlined,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1A6BFF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 12),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A6BFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Kirim Laporan',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A2E),
      ),
    );
  }
}
