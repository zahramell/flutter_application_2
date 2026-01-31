import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:google_fonts/google_fonts.dart';
import 'beranda.dart';
import 'aktivitas.dart';
import 'notifikasi.dart';
import 'profil.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const BerandaScreen(role: 'peminjam'),
    const AktivitasScreen(),
    const NotifikasiScreen(),
    const ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        width: 440, // Sesuai permintaan
        height: 99, // Sesuai permintaan
        decoration: const BoxDecoration(
          color: Color(0xFF2F4157),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Konten Ikon dan Teks diletakkan di bagian atas Container
            Positioned(
              top:
                  15, // MENGATUR JARAK DARI ATAS (Sesuaikan agar pas dengan Figma)
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Symbols.home_rounded, "Home", 0),
                  _buildNavItem(Symbols.activity_zone_rounded, "Aktivitas", 1),
                  _buildNavItem(Symbols.notifications_rounded, "Notifikasi", 2),
                  _buildNavItem(Symbols.person_rounded, "Profil", 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              color:
                  isActive ? const Color(0xFFC7D9E5) : const Color(0xFF999999),
              fill: isActive ? 1 : 0,
            ),
            const SizedBox(height: 6), // Jarak antara ikon dan teks
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? const Color(0xFFC7D9E5)
                    : const Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
