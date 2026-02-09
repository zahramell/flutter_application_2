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

  String _namaPetugas = "Memuat...";
  String _fotoUser = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // ================== PROFIL PETUGAS ==================
  Future<void> _fetchUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
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
      setState(() => _isLoading = false);
    }
  }

  // ================== DATA PEMINJAMAN MENUNGGU ==================
  Future<List<Map<String, dynamic>>> fetchPerluDisetujui() async {
    final res = await supabase
        .from('peminjaman')
        .select('''
          id_peminjaman,
          tanggal_pinjam,
          profiles:id_peminjam(nama),
          alat:id_alat(nama_alat)
        ''')
        .eq('status_persetujuan', 'menunggu')
        .order('tanggal_pinjam', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<int> countPerluDisetujui() async {
    final res = await supabase
        .from('peminjaman')
        .select('id_peminjaman')
        .eq('status_persetujuan', 'menunggu');

    return res.length;
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchUserData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------- HEADER ----------
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color(0xFFEFEFEF),
                            foregroundImage: _fotoUser.isNotEmpty
                                ? NetworkImage(_fotoUser)
                                : null,
                            child: _fotoUser.isEmpty
                                ? const Icon(Symbols.person,
                                    color: Color(0xFF34495E))
                                : null,
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _namaPetugas,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Petugas",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),

                      const SizedBox(height: 30),

                      // ---------- STATISTIK ----------
                      Row(
                        children: [
                          Expanded(
                            child: FutureBuilder<int>(
                              future: countPerluDisetujui(),
                              builder: (context, snapshot) {
                                return _menuBox(
                                  snapshot.data?.toString() ?? "0",
                                  "Perlu Disetujui",
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _menuBoxIcon(
                              Symbols.assignment_turned_in,
                              "Pengembalian",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 35),

                      // ---------- JUDUL ----------
                      Text(
                        "Perlu Disetujui",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ---------- LIST PEMINJAMAN ----------
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: fetchPerluDisetujui(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.data!.isEmpty) {
                            return Text(
                              "Tidak ada peminjaman",
                              style: GoogleFonts.poppins(),
                            );
                          }

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCDE0E9),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: snapshot.data!.map((data) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.person),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['profiles']['nama'],
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "Alat: ${data['alat']['nama_alat']}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ================== WIDGET BANTUAN ==================
  Widget _menuBox(String angka, String label) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF34495E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            angka,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _menuBoxIcon(IconData icon, String label) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF34495E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
