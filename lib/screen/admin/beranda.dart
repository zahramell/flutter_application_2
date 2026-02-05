import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';

class BerandaAdmin extends StatefulWidget {
  const BerandaAdmin({super.key});

  @override
  _BerandaAdminState createState() => _BerandaAdminState();
}

class _BerandaAdminState extends State<BerandaAdmin> {
  final SupabaseClient supabase = Supabase.instance.client;

  String namaAdmin = "Admin";
  String fotoAdmin = "";
  int jmlPengguna = 0;
  int jmlPeminjam = 0;
  int jmlPengembalian = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final profile = await supabase
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (profile != null) {
          setState(() {
            namaAdmin = profile['nama'] ?? 'Admin';
            fotoAdmin = profile['foto'] ?? '';
          });
        }
      }

      final resUser = await supabase.from('profiles').select();
      final resPinjam = await supabase
          .from('peminjaman')
          .select()
          .eq('status_persetujuan', 'Disetujui');
      final resKembali = await supabase.from('pengembalian').select();

      if (mounted) {
        setState(() {
          jmlPengguna = (resUser as List).length;
          jmlPeminjam = (resPinjam as List).length;
          jmlPengembalian = (resKembali as List).length;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF34495E)))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "Dashboard Admin",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // HEADER PROFIL (SAMAKAN PERSIS DENGAN PEMINJAM)
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors
                                .blueGrey[50], // Lingkaran luar/bantalan profil
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              backgroundImage: fotoAdmin.isNotEmpty
                                  ? NetworkImage(fotoAdmin)
                                  : null,
                              child: fotoAdmin.isEmpty
                                  ? const Icon(Symbols.person,
                                      color: Color(0xFF34495E), size: 28)
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              namaAdmin,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                            Text(
                              "Admin",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Symbols.notifications,
                            size: 28, color: Colors.black),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // KARTU MENU (DESAIN ASLI ANDA)
                    _buildMenuCard(
                        "Data pengguna", jmlPengguna.toString(), Symbols.group),
                    _buildMenuCard("Peminjam", jmlPeminjam.toString(),
                        Symbols.person_search),
                    _buildMenuCard("Pengembalian", jmlPengembalian.toString(),
                        Symbols.assignment_return),
                  ],
                ),
              ),
            ),
    );
  }

  // Widget kartu menu asli Anda (dengan parameter String count)
  Widget _buildMenuCard(String title, String count, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF34495E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(width: 15),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            count,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
