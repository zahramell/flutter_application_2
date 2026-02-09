import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class AktivitasScreen extends StatefulWidget {
  const AktivitasScreen({super.key});

  @override
  State<AktivitasScreen> createState() => _AktivitasScreenState();
}

class _AktivitasScreenState extends State<AktivitasScreen> {
  final supabase = Supabase.instance.client;

  // =============================
  // AMBIL DATA PEMINJAMAN USER
  // =============================
  Future<List<Map<String, dynamic>>> fetchAktivitas() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final res = await supabase
        .from('peminjaman')
        .select('*, alat:id_alat(nama_alat, gambar)')
        .eq('id_peminjam', user.id)
        .order('tanggal_pinjam', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  // =============================
  // AJUKAN PENGEMBALIAN
  // =============================
  Future<void> ajukanPengembalian(int idPeminjaman) async {
    await supabase.from('pengembalian').insert({
      'id_peminjaman': idPeminjaman,
      'tanggal_kembali': DateTime.now().toIso8601String(),
      'status_pengembalian': 'menunggu',
    });

    await supabase
        .from('peminjaman')
        .update({'status_persetujuan': 'menunggu_pengembalian'})
        .eq('id_peminjaman', idPeminjaman);

    setState(() {});
  }

  // =============================
  // UI
  // =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== JUDUL =====
            Padding(
              padding: const EdgeInsets.fromLTRB(35, 30, 25, 10),
              child: Text(
                "Sedang Dipinjam",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2F4157),
                ),
              ),
            ),

            // ===== LIST =====
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchAktivitas(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "Belum ada aktivitas pinjaman.",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data![index];
                      final alat = data['alat'];

                      return Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          width: 329,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ===== INFO ALAT =====
                              Row(
                                children: [
                                  Image.network(
                                    alat['gambar'] ?? '',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          alat['nama_alat'],
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color:
                                                const Color(0xFF2F4157),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _status(
                                          data['status_persetujuan'],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // ===== TOMBOL PENGEMBALIAN =====
                              if (data['status_persetujuan'] == 'disetujui')
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 10),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 36,
                                    child: ElevatedButton(
                                      style:
                                          ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF2F4157),
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () async {
                                        await ajukanPengembalian(
                                          data['id_peminjaman'],
                                        );
                                      },
                                      child: Text(
                                        "Ajukan Pengembalian",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================
  // BADGE STATUS
  // =============================
  Widget _status(String status) {
    Color color = status == 'disetujui'
        ? Colors.green
        : status == 'ditolak'
            ? Colors.red
            : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
