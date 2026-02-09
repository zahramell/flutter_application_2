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
  final supabase = Supabase.instance.client;

  String _namaPetugas = "Memuat...";
  String _fotoUser = "";
  bool _loading = true;

  String formatTanggal(dynamic value) {
    if (value == null) return '-';
    final d = DateTime.parse(value.toString());
    return "${d.day}/${d.month}/${d.year}";
  }

  @override
  void initState() {
    super.initState();
    _loadPetugas();
  }

  // ================= PROFIL =================
  Future<void> _loadPetugas() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('profiles')
        .select('nama, foto')
        .eq('id', user.id)
        .single();

    setState(() {
      _namaPetugas = data['nama'];
      _fotoUser = data['foto'] ?? "";
      _loading = false;
    });
  }

  // ================= DATA =================
  Future<List<Map<String, dynamic>>> fetchPerluDisetujui() async {
    final res = await supabase.from('peminjaman').select('''
      id_peminjaman,
      tanggal_pinjam,
      tanggal_jatuh_tempo,
      profiles:id_peminjam(nama),
      alat:id_alat(id_alat,nama_alat)
    ''').eq('status_persetujuan', 'menunggu');

    return List<Map<String, dynamic>>.from(res);
  }

  Future<int> countMenunggu() async {
    final res = await supabase
        .from('peminjaman')
        .select('id_peminjaman')
        .eq('status_persetujuan', 'menunggu');
    return res.length;
  }

  // ================= AKSI =================
  Future<void> setujui(int idPeminjaman, int idAlat) async {
    await supabase.from('peminjaman').update(
        {'status_persetujuan': 'disetujui'}).eq('id_peminjaman', idPeminjaman);

    await supabase
        .from('alat')
        .update({'status_alat': 'Dipinjam'}).eq('id_alat', idAlat);

    setState(() {});
  }

  Future<void> tolak(int idPeminjaman) async {
    await supabase.from('peminjaman').update(
        {'status_persetujuan': 'ditolak'}).eq('id_peminjaman', idPeminjaman);

    setState(() {});
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== HEADER =====
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD7E7F0),
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(30)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: _fotoUser.isNotEmpty
                                ? NetworkImage(_fotoUser)
                                : null,
                            child: _fotoUser.isEmpty
                                ? const Icon(Symbols.person)
                                : null,
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_namaPetugas,
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text("Petugas",
                                  style: GoogleFonts.poppins(fontSize: 12)),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ===== TOTAL =====
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F4157),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Mouse",
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          Text("20",
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ===== MENU =====
                    Row(
                      children: [
                        Expanded(
                          child: FutureBuilder<int>(
                            future: countMenunggu(),
                            builder: (c, s) {
                              return _menuBox(s.data?.toString() ?? "0",
                                  "Perlu\nDisetujui");
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _menuBox("–", "Sedang\nDipinjam"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    Text("Perlu Disetujui",
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold)),

                    const SizedBox(height: 15),

                    // ===== LIST =====
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchPerluDisetujui(),
                      builder: (c, s) {
                        if (!s.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (s.data!.isEmpty) {
                          return Text("Tidak ada data",
                              style: GoogleFonts.poppins());
                        }

                        return Column(
                          children: s.data!.map((d) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 6)
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor:
                                            const Color(0xFFEFEFEF),
                                        backgroundImage:
                                            d['profiles']['foto'] != null &&
                                                    d['profiles']['foto']
                                                        .toString()
                                                        .isNotEmpty
                                                ? NetworkImage(
                                                    d['profiles']['foto'])
                                                : null,
                                        child: d['profiles']['foto'] == null
                                            ? const Icon(Icons.person,
                                                color: Colors.grey)
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            d['profiles']['nama'] ?? '-',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            "Peminjam",
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "Alat: ${d['alat']?['nama_alat'] ?? '-'}\n"
                                    "Tgl Pinjam: ${formatTanggal(d['tanggal_pinjam'])}\n"
                                    "Jatuh Tempo: ${formatTanggal(d['tanggal_jatuh_tempo'])}",
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green),
                                          onPressed: () => setujui(
                                              d['id_peminjaman'],
                                              d['alat']['id_alat']),
                                          child: const Text("Setujui"),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red),
                                          onPressed: () =>
                                              tolak(d['id_peminjaman']),
                                          child: const Text("Tolak"),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _menuBox(String angka, String label) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF2F4157),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(angka,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
