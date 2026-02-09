import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'alat/crud_alat.dart';
import 'user/tampilan.dart';
import 'peminjaman_admin/peminjaman_list.dart';
import 'pengembalian_admin/pengembalian.dart';
import 'kategori/tampila.dart';

class BerandaAdmin extends StatefulWidget {
  const BerandaAdmin({super.key});

  @override
  State<BerandaAdmin> createState() => _BerandaAdminState();
}

class _BerandaAdminState extends State<BerandaAdmin> {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? nama;
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    getProfil();
  }

  // ================= AMBIL PROFIL ADMIN =================
  Future<void> getProfil() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response =
          await _supabase.from('profiles').select().eq('id', user.id).single();

      setState(() {
        nama = response['nama'];
        avatarUrl = response['foto'];
      });
    } catch (e) {
      print('ERROR GET PROFIL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HEADER =================
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
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                    child: avatarUrl == null
                        ? const Icon(Symbols.person, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama ?? 'Admin',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Administrator',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ================= BARIS 1 =================
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TampilanKategori(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ================= BARIS 2 =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
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

  // ================= MENU CARD =================
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
