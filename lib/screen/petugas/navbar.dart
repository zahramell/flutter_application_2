import 'package:flutter/material.dart';
import 'package:flutter_application_2/screen/petugas/beranda.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'beranda_petugas.dart'; // Buat file ini untuk isi dashboard petugas

class MainNavigationPetugas extends StatefulWidget {
  const MainNavigationPetugas({super.key});

  @override
  State<MainNavigationPetugas> createState() => _MainNavigationPetugasState();
}

class _MainNavigationPetugasState extends State<MainNavigationPetugas> {
  int _currentIndex = 0;

  // Daftar halaman untuk setiap menu navbar
  final List<Widget> _pages = [
    const BerandaPetugas(), // Index 0 (Home)
    const Center(child: Text("Halaman Operasional")), // Index 1
    const Center(child: Text("Halaman Laporan")), // Index 2
    const Center(child: Text("Halaman Pengaturan")), // Index 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan IndexedStack agar halaman tidak refresh saat pindah tab
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor:
            const Color(0xFF2F4157), // Warna Biru Tua sesuai desain
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: _currentIndex,
        // Gaya teks menggunakan Poppins
        selectedLabelStyle:
            GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons
                .refresh_rounded), // Icon menyerupai "Operasional" di gambar
            label: 'Operasional',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons
                .assignment_outlined), // Icon menyerupai "Laporan" di gambar
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'pengaturan',
          ),
        ],
      ),
    );
  }
}
