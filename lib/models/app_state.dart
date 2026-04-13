import 'package:flutter/material.dart';

enum StatusLaporan { belumDimulai, dikerjakan, tertunda, selesai }

extension StatusLaporanExt on StatusLaporan {
  String get label {
    switch (this) {
      case StatusLaporan.belumDimulai:
        return 'Belum Dimulai';
      case StatusLaporan.dikerjakan:
        return 'Dikerjakan';
      case StatusLaporan.tertunda:
        return 'Tertunda';
      case StatusLaporan.selesai:
        return 'Selesai';
    }
  }

  Color get color {
    switch (this) {
      case StatusLaporan.belumDimulai:
        return const Color(0xFFFF6B35);
      case StatusLaporan.dikerjakan:
        return const Color(0xFF1A6BFF);
      case StatusLaporan.tertunda:
        return const Color(0xFFFFB800);
      case StatusLaporan.selesai:
        return const Color(0xFF00C896);
    }
  }

  Color get bgColor {
    switch (this) {
      case StatusLaporan.belumDimulai:
        return const Color(0xFFFFF0EC);
      case StatusLaporan.dikerjakan:
        return const Color(0xFFEEF3FF);
      case StatusLaporan.tertunda:
        return const Color(0xFFFFF8E7);
      case StatusLaporan.selesai:
        return const Color(0xFFE8FFF8);
    }
  }
}

class LaporanModel {
  final String id;
  final String judul;
  final String kategori;
  final String lokasi;
  final String deskripsi;
  final String? fotoPath;
  final DateTime tanggal;
  StatusLaporan status;

  LaporanModel({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.lokasi,
    required this.deskripsi,
    this.fotoPath,
    required this.tanggal,
    this.status = StatusLaporan.belumDimulai,
  });
}

class AppState extends ChangeNotifier {
  // User info
  String userName = 'Kak Daniel';
  String userEmail = 'daniel@example.com';
  String userLocation = 'Palembang, Indonesia';
  String userBirthDate = '12 Januari 1988';
  int userAge = 37;

  // Laporan list
  List<LaporanModel> _laporanList = [
    LaporanModel(
      id: '1',
      judul: 'Jalan Berlubang',
      kategori: 'Infrastruktur',
      lokasi: 'Tegur Wangi, Indralaya',
      deskripsi:
          'Terdapat lubang besar di tengah jalan yang membahayakan pengendara, terutama saat malam hari. Lubang sudah ada sejak 2 minggu lalu dan belum ada penanganan.',
      fotoPath: 'https://images.unsplash.com/photo-1515162305285-0293e4767cc2?w=400',
      tanggal: DateTime(2026, 3, 16),
      status: StatusLaporan.belumDimulai,
    ),
    LaporanModel(
      id: '2',
      judul: 'Sampah Menumpuk',
      kategori: 'Lingkungan',
      lokasi: 'Jl. Mawar No. 5, Indralaya',
      deskripsi:
          'Sampah sudah menumpuk selama lebih dari seminggu dan tidak kunjung diangkut. Bau menyengat dan mengundang lalat.',
      fotoPath: 'https://images.unsplash.com/photo-1604187351574-c75ca79f5807?w=400',
      tanggal: DateTime(2026, 2, 17),
      status: StatusLaporan.dikerjakan,
    ),
    LaporanModel(
      id: '3',
      judul: 'Lampu Jalan Mati',
      kategori: 'Penerangan',
      lokasi: 'Jl. Sudirman Km. 3',
      deskripsi:
          'Lampu jalan di sepanjang 200 meter jalan ini sudah mati selama 3 hari. Rawan kecelakaan.',
      fotoPath: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      tanggal: DateTime(2026, 2, 17),
      status: StatusLaporan.tertunda,
    ),
  ];

  List<LaporanModel> get laporanList => _laporanList;

  List<LaporanModel> get highlightedLaporan =>
      _laporanList.where((l) => l.status != StatusLaporan.selesai).take(3).toList();

  void tambahLaporan(LaporanModel laporan) {
    _laporanList.insert(0, laporan);
    notifyListeners();
  }

  void ubahStatus(String id, StatusLaporan status) {
    final idx = _laporanList.indexWhere((l) => l.id == id);
    if (idx != -1) {
      _laporanList[idx].status = status;
      notifyListeners();
    }
  }
}

// Simple InheritedWidget provider
class AppStateProvider extends StatefulWidget {
  final Widget child;
  const AppStateProvider({required this.child, Key? key}) : super(key: key);

  @override
  State<AppStateProvider> createState() => _AppStateProviderState();
}

class _AppStateProviderState extends State<AppStateProvider> {
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AppStateInherited(
      appState: _appState,
      child: AnimatedBuilder(
        animation: _appState,
        builder: (_, __) => widget.child,
      ),
    );
  }
}

class AppStateInherited extends InheritedWidget {
  final AppState appState;

  const AppStateInherited({
    required this.appState,
    required super.child,
    super.key,
  });

  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStateInherited>()!.appState;
  }

  @override
  bool updateShouldNotify(AppStateInherited oldWidget) => true;
}
