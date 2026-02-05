import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart'; // Import Symbols
import 'beranda.dart'; // Pastikan path file beranda admin benar
import 'crud_alat.dart';

class MainNavigationAdmin extends StatefulWidget {
  @override
  _MainNavigationAdminState createState() => _MainNavigationAdminState();
}

class _MainNavigationAdminState extends State<MainNavigationAdmin> {
  int _currentIndex = 0;

  // Daftar halaman
  final List<Widget> _pages = [
    BerandaAdmin(), // Menggunakan file BerandaAdmin yang sudah kita buat tadi
    CrudAlatPage(
      role: 'alat',
    ),
    Center(child: Text("Aktivitas", style: GoogleFonts.poppins())),
    Center(child: Text("Pengaturan", style: GoogleFonts.poppins())),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        // Lebih baik pakai IndexedStack agar state halaman tidak hilang
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF2C3E50), // Biru gelap konsisten
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: _currentIndex,
        selectedLabelStyle:
            GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Symbols.home), // Ikon Home versi Material Symbols
            activeIcon: Icon(Symbols.home, fill: 1), // Efek terisi saat dipilih
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.inventory_2),
            activeIcon: Icon(Symbols.inventory_2, fill: 1),
            label: "Alat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.history),
            activeIcon: Icon(Symbols.history, fill: 1),
            label: "Aktivitas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.settings),
            activeIcon: Icon(Symbols.settings, fill: 1),
            label: "Pengaturan",
          ),
        ],
      ),
    );
  }
}
