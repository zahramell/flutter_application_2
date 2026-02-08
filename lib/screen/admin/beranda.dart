import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'crud_alat/crud_alat.dart';
import 'user/tampilan.dart';
import 'peminjaman_admin/peminjaman.dart';
import 'pengembalian_admin/pengembalian.dart';

class BerandaAdmin extends StatelessWidget {
  const BerandaAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HEADER (SUDAH ADA) =================
            Container(
              width: double.infinity,
              height: 160,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFD5E6F2),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 28),
                  const SizedBox(width: 15),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Admin",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Administrator",
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ================= BARIS 1 : MENU MANAJEMEN =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _menuCard(
                    icon: Symbols.group,
                    label: "User",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserAdminPage(),
                        ),
                      );
                    },
                  ),
                  _menuCard(
                    icon: Symbols.inventory_2,
                    label: "Alat",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CrudAlatPage(role: 'admin'),
                        ),
                      );
                    },
                  ),
                  _menuCard(
                    icon: Symbols.category,
                    label: "Kategori",
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ================= BARIS 2 : MENU TRANSAKSI (INI YANG BARU) =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _menuCard(
                    icon: Symbols.assignment,
                    label: "Peminjaman",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PeminjamanAdminPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  _menuCard(
                    icon: Symbols.assignment_return,
                    label: "Pengembalian",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PengembalianAdminPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ================= KOTAK MENU (TETAP SAMA) =================
  Widget _menuCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 95,
        height: 95,
        decoration: BoxDecoration(
          color: const Color(0xFF2F4157),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
