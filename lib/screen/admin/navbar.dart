import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'beranda.dart';
import 'crud_alat.dart';

class MainNavigationAdmin extends StatefulWidget {
  const MainNavigationAdmin({super.key});

  @override
  State<MainNavigationAdmin> createState() => _MainNavigationAdminState();
}

class _MainNavigationAdminState extends State<MainNavigationAdmin> {
  int _currentIndex = 0;

  // Daftar halaman
  final List<Widget> _pages = [
    const BerandaAdmin(),
    const CrudAlatPage(role: 'admin'), // Role disesuaikan jadi admin
    Center(child: Text("Aktivitas", style: GoogleFonts.poppins())),
    Center(child: Text("Pengaturan", style: GoogleFonts.poppins())),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // MENGGUNAKAN CUSTOM CONTAINER AGAR UKURANNYA PRESISI (Tinggi 99)
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 99,
        decoration: const BoxDecoration(
          color: Color(0xFF2C3E50), // Warna Navy Gelap
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
                top: 15, // Jarak ikon dari sisi atas container navbar
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Symbols.home_rounded, "Home", 0),
                    _buildNavItem(Symbols.inventory_2_rounded, "Alat", 1),
                    _buildNavItem(Symbols.history_rounded, "Aktivitas", 2),
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

  // Helper Widget untuk Item Navigasi (Meniru gaya MainScreen kamu)
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
