import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotifikasiPetugasPage extends StatefulWidget {
  const NotifikasiPetugasPage({super.key});

  @override
  State<NotifikasiPetugasPage> createState() =>
      _NotifikasiPetugasPageState();
}

class _NotifikasiPetugasPageState
    extends State<NotifikasiPetugasPage> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchNotifikasi() async {
    final res = await supabase
        .from('peminjaman')
        .select('''
          id_peminjaman,
          tanggal_pinjam,
          status_persetujuan,
          profiles!peminjaman_id_peminjam_fkey (
            nama,
            foto
          ),
          alat!peminjaman_id_alat_fkey (
            nama_alat
          )
        ''')
        .eq('status_persetujuan', 'menunggu')
        .order('tanggal_pinjam', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  String formatTanggal(String tgl) {
    final d = DateTime.parse(tgl);
    return "${d.day}/${d.month}/${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Notifikasi Petugas",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchNotifikasi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "Tidak ada notifikasi",
                style: GoogleFonts.poppins(),
              ),
            );
          }

          final data = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, i) {
              final d = data[i];
              final user = d['profiles'];
              final alat = d['alat'];

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage:
                          user['foto'] != null &&
                                  user['foto'].toString().isNotEmpty
                              ? NetworkImage(user['foto'])
                              : null,
                      child: user['foto'] == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['nama'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Mengajukan: ${alat['nama_alat']}",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "Tanggal: ${formatTanggal(d['tanggal_pinjam'])}",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.notifications_active,
                      color: Colors.orange,
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
