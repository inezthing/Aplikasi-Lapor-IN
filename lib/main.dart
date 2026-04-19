// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/supabase_service.dart';
import 'controllers/auth_controller.dart';
import 'controllers/laporan_controller.dart';
import 'controllers/kasus_controller.dart';
import 'utils/constants.dart';
import 'views/auth/login_view.dart';
import 'views/home/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Format tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

  // Status bar transparan
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Supabase.initialize(
    url: 'https://vzbqopaeaijfpcrlenfc.supabase.co',     
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ6YnFvcGFlYWlqZnBjcmxlbmZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY2MDMyODYsImV4cCI6MjA5MjE3OTI4Nn0.05SuESHLN26Zh5_IfYpmQ_RUz6MvzmnaFkJ-Rq-cLI0',
  );

  // Inisialisasi Supabase
  await SupabaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => LaporanController()),
        ChangeNotifierProvider(create: (_) => KasusController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppText.appName,
        theme: _buildTheme(),
        home: const _SplashRouter(),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Poppins',

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: AppColors.textPrimary,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle:
            const TextStyle(color: AppColors.textHint, fontSize: 14),
        labelStyle:
            const TextStyle(color: AppColors.textHint, fontSize: 14),
        errorStyle:
            const TextStyle(color: AppColors.error, fontSize: 12),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SPLASH ROUTER
// Menentukan halaman awal berdasarkan status sesi.
// ─────────────────────────────────────────────

class _SplashRouter extends StatefulWidget {
  const _SplashRouter({Key? key}) : super(key: key);

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;

    if (!mounted) return;

    if (session != null) {
      // Ada sesi aktif — load profil lalu masuk
      final authCtrl = context.read<AuthController>();
      await authCtrl.loadCurrentUserProfile();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeView()),
      );
    } else {
      // Tidak ada sesi — ke login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Splash screen sederhana
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.report_problem_rounded,
              color: Colors.white,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              AppText.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Memuat...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
