import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'detail_peminjaman.dart';

class PeminjamanAdminPage extends StatefulWidget {
  const PeminjamanAdminPage({super.key});

  @override
  State<PeminjamanAdminPage> createState() => _PeminjamanAdminPageState();
}

class _PeminjamanAdminPageState extends State<PeminjamanAdminPage> {
  final supabase = Supabase.instance.client;

  // ================= FETCH DATA =================
  Future<List<Map<String, dynamic>>> fetchPeminjaman() async {
    final res = await supabase.from('peminjaman').select('''
      id_peminjaman,
      tanggal_pinjam,
      tanggal_jatuh_tempo,
      status_persetujuan,

      profiles!peminjaman_id_peminjam_fkey (
        nama,
        role,
        foto
      ),

      alat!peminjaman_id_alat_fkey (
        nama_alat
      )
    ''').order('id_peminjaman', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  // ================= ICON ACTION =================
  Widget _iconAction({required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Peminjaman (Admin)"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPeminjaman(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada data peminjaman"));
          }

          final data = snapshot.data!;

          return ListView.builder(
            itemCount: data.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final p = data[index];
              final profil = p['profiles'];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F3F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== HEADER PROFIL + ICON =====
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage:
                              profil['foto'] != null && profil['foto'] != ''
                                  ? NetworkImage(profil['foto'])
                                  : null,
                          backgroundColor: Colors.grey.shade300,
                          child: profil['foto'] == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profil['nama'],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                profil['role'],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== ICON EDIT & HAPUS =====
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailPeminjamanAdminPage(data: p),
                                  ),
                                ).then((value) {
                                  if (value == true) setState(() {});
                                });
                              },
                              child: _iconAction(
                                icon: Symbols.edit,
                                color: const Color(0xFF2F4157),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () async {
                                await supabase
                                    .from('peminjaman')
                                    .delete()
                                    .eq('id_peminjaman', p['id_peminjaman']);
                                setState(() {});
                              },
                              child: _iconAction(
                                icon: Symbols.delete,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ===== DATA PEMINJAMAN =====
                    Text(
                      p['alat']['nama_alat'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("Pinjam : ${p['tanggal_pinjam']}"),
                    Text("Jatuh Tempo : ${p['tanggal_jatuh_tempo'] ?? '-'}"),
                    Text("Status : ${p['status_persetujuan']}"),
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
