import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BerandaPetugas extends StatefulWidget {
  const BerandaPetugas({super.key});

  @override
  State<BerandaPetugas> createState() => _BerandaPetugasState();
}

class _BerandaPetugasState extends State<BerandaPetugas> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Variabel untuk menampung data dari database
  String _namaPetugas = "Memuat...";
  String _fotoUser = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // FUNGSI MENGAMBIL DATA DARI SUPABASE
  Future<void> _fetchUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        // Mengambil data dari tabel 'profiles' berdasarkan ID user yang login
        final data = await supabase
            .from('profiles')
            .select('nama, foto')
            .eq('id', user.id)
            .single();

        setState(() {
          _namaPetugas = data['nama'] ?? "Tanpa Nama";
          _fotoUser = data['foto'] ?? "";
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator()) // Loading saat ambil data
            : RefreshIndicator(
                onRefresh:
                    _fetchUserData, // Tarik layar ke bawah untuk refresh data
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER PROFIL ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color(0xFFEFEFEF),
                            // Menggunakan foregroundImage agar foto memenuhi lingkaran
                            foregroundImage: _fotoUser.isNotEmpty
                                ? NetworkImage(_fotoUser)
                                : null,
                            child: _fotoUser.isEmpty
                                ? const Icon(Symbols.person,
                                    color: Color(0xFF34495E), size: 30)
                                : null,
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _namaPetugas,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2C3E50),
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                "Petugas",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF999999),
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // --- KOTAK MENU STATISTIK ---
                      Row(
                        children: [
                          Expanded(
                              child: _buildMenuBox("3", "Konfirmasi", null)),
                          const SizedBox(width: 20),
                          Expanded(
                              child: _buildMenuBox(
                                  null, "Kembali", Symbols.account_circle)),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // --- JUDUL DAFTAR ---
                      Text(
                        "Perlu Disetujui",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // --- KARTU DAFTAR PERSETUJUAN ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCDE0E9),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            _buildListItem("1.", "Seliya",
                                "Logitech MK270 Wireless\nCombo _ HSN"),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child:
                                  Divider(color: Colors.black45, thickness: 1),
                            ),
                            _buildListItem("2.", "Ahmad",
                                "Logitech MK270 Wireless\nCombo _ HSN"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildMenuBox(String? angka, String label, IconData? icon) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF34495E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (angka != null)
            Text(angka,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold))
          else
            Icon(icon, color: Colors.white, size: 30),
          Text(label,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildListItem(String no, String nama, String barang) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(no,
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nama,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              Text(barang,
                  style:
                      GoogleFonts.poppins(fontSize: 12, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
}
