import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'detail_pengembalian.dart';

class PengembalianAdminPage extends StatefulWidget {
  const PengembalianAdminPage({super.key});

  @override
  State<PengembalianAdminPage> createState() => _PengembalianAdminPageState();
}

class _PengembalianAdminPageState extends State<PengembalianAdminPage> {
  final supabase = Supabase.instance.client;

  // ================= FETCH DATA =================
  Future<List<Map<String, dynamic>>> fetchPengembalian() async {
    final res = await supabase.from('pengembalian').select('''
      id_pengembalian,
      tanggal_kembali_riil,
      kondisi_alat,
      denda,
      peminjaman (
        tanggal_pinjam,
        profiles!peminjaman_id_peminjam_fkey (
          nama,
          role,
          foto
        ),
        alat (
          nama_alat
        )
      )
    ''').order('id_pengembalian', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  // ================= HAPUS =================
  Future<void> hapusPengembalian(int id) async {
    await supabase.from('pengembalian').delete().eq('id_pengembalian', id);

    setState(() {});
  }

  // ================= ICON BULAT =================
  Widget _iconCircle({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text("Data Pengembalian (Admin)"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPengembalian(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada data pengembalian"));
          }

          final data = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final g = data[index];
              final profil = g['peminjaman']['profiles'];

              return Center(
                child: SizedBox(
                  width: 329,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== HEADER PROFIL + ACTION =====
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: profil['foto'] != null &&
                                      profil['foto'].toString().isNotEmpty
                                  ? NetworkImage(profil['foto'])
                                  : null,
                              child: (profil['foto'] == null ||
                                      profil['foto'] == '')
                                  ? const Icon(Icons.person,
                                      color: Colors.white)
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
                            Row(
                              children: [
                                _iconCircle(
                                  icon: Icons.visibility,
                                  color: const Color(0xFF2F4157),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DetailPengembalianPage(data: g),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                _iconCircle(
                                  icon: Symbols.delete,
                                  color: Colors.red,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("Hapus Data"),
                                        content: const Text(
                                            "Yakin ingin menghapus data pengembalian ini?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Batal"),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await hapusPengembalian(
                                                  g['id_pengembalian']);
                                            },
                                            child: const Text("Hapus"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ===== DETAIL =====
                        Text(
                          g['peminjaman']['alat']['nama_alat'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Pinjam : ${g['peminjaman']['tanggal_pinjam']}",
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          "Kembali : ${g['tanggal_kembali_riil']}",
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          "Kondisi : ${g['kondisi_alat']}",
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          "Denda : Rp ${g['denda'] ?? 0}",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
