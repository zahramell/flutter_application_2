import 'package:flutter/material.dart';
import 'package:flutter_application_2/screen/petugas/beranda.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'operasional.dart';
import 'laporan.dart';
import 'logout.dart';

class MainNavigationPetugas extends StatefulWidget {
  const MainNavigationPetugas({super.key});

  @override
  State<MainNavigationPetugas> createState() => _MainNavigationPetugasState();
}

class _MainNavigationPetugasState extends State<MainNavigationPetugas> {
  int _currentIndex = 0;

  // Daftar halaman untuk setiap menu navbar
  final List<Widget> _pages = [
    const BerandaPetugas(),
    const PersetujuanPage(),
    const LaporanPage(),
    const PengaturanPetugasPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 99,
        decoration: const BoxDecoration(
          color: Color(0xFF2F4157), // Biru Tua Petugas
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Stack(
            children: [
              Positioned(
                top: 15,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Symbols.home_rounded, "Home", 0),
                    _buildNavItem(Symbols.refresh_rounded, "Operasional", 1),
                    _buildNavItem(Symbols.description_rounded, "Laporan", 2),
                    _buildNavItem(Symbols.settings_rounded, "Pengaturan", 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget Navigasi agar UI Konsisten
  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isActive ? Colors.white : Colors.white54,
              fill: isActive ? 1 : 0,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? Colors.white : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
