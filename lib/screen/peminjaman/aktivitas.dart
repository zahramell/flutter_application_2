import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class AktivitasScreen extends StatefulWidget {
  final String? role;
  const AktivitasScreen({super.key, this.role});

  @override
  State<AktivitasScreen> createState() => _AktivitasScreenState();
}

class _AktivitasScreenState extends State<AktivitasScreen> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchAktivitas() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await supabase
          .from('peminjaman')
          .select('''
          *,
          alat:id_alat (
            nama_alat,
            gambar
          )
        ''')
          .eq('id_peminjam', user.id)
          .order('tanggal_pinjam', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching: $e");
      return [];
    }
  }

  String formatTanggalManual(String dateString) {
    try {
      String dateOnly = dateString.split(' ')[0];
      List<String> parts = dateOnly.split('-');
      if (parts.length == 3) {
        return "${parts[2]}/${parts[1]}/${parts[0]}";
      }
      return dateOnly;
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BAGIAN HEADER: Memberikan jarak agar tidak mepet ke frame
            Padding(
              padding: const EdgeInsets.fromLTRB(35, 30, 25, 10),
              child: Text(
                "Sedang Dipinjam",
                style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2F4157)),
              ),
            ),

            const SizedBox(height: 10), // Jarak tambahan ke list

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
                    // Padding bawah 120 agar item terakhir tidak tertutup Navbar 99px
                    padding: const EdgeInsets.only(top: 10, bottom: 120),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data![index];
                      final alat = data['alat'] as Map<String, dynamic>?;

                      return Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          width: 329,
                          height: 142,
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
                          child: Row(
                            children: [
                              // Gambar Alat
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  alat?['gambar'] ?? '',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 100,
                                    height: 100,
                                    color: const Color(0xFFF5F5F5),
                                    child: const Icon(Icons.broken_image,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),

                              // Info Detail
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      alat?['nama_alat'] ??
                                          'Alat Tidak Dikenal',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: const Color(0xFF2F4157)),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildStatusBadge(
                                        data['status_persetujuan'] ??
                                            'Menunggu'),
                                    const Spacer(),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        formatTanggalManual(
                                            data['tanggal_pinjam'].toString()),
                                        style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: const Color(0xFF999999),
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              )
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

  Widget _buildStatusBadge(String status) {
    Color color;
    String cleanStatus = status.toLowerCase();

    if (cleanStatus == 'disetujui') {
      color = const Color(0xFF27AE60);
    } else if (cleanStatus == 'ditolak') {
      color = Colors.red;
    } else {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(
        status,
        style: GoogleFonts.poppins(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
