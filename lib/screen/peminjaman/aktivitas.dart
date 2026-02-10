import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pengembalian_service.dart';
import 'pengembalian.dart';

class AktivitasScreen extends StatefulWidget {
  const AktivitasScreen({super.key});

  @override
  State<AktivitasScreen> createState() => _AktivitasScreenState();
}

class _AktivitasScreenState extends State<AktivitasScreen> {
  final supabase = Supabase.instance.client;
  final pengembalianService = PengembalianService();
  String _kondisiAlat = 'baik';

  void showSuccessPengembalian(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 70),
                const SizedBox(height: 16),
                Text(
                  "Pengembalian Alat\nBerhasil",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Alat telah dikembalikan.\nTerima kasih!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // tutup dialog
                    setState(() {}); // refresh list
                  },
                  child: const Text("Lihat Status"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void bukaFormPengembalian(int idPeminjaman) {
    final parentContext = context; // ⬅️ simpan context utama

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FieldPengembalian(
                kondisiAlat: _kondisiAlat,
                onChanged: (val) {
                  setState(() {
                    _kondisiAlat = val;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await pengembalianService.ajukanPengembalian(
                    idPeminjaman: idPeminjaman,
                    kondisiAlat: _kondisiAlat,
                  );

                  Navigator.pop(context); // ⬅️ tutup bottom sheet

                  // ⬇️ PAKAI CONTEXT UTAMA
                  Future.delayed(const Duration(milliseconds: 200), () {
                    showSuccessPengembalian(parentContext);
                  });
                },
                child: const Text("KIRIM PENGEMBALIAN"),
              ),
            ],
          ),
        );
      },
    );
  }

  // =============================
  // AMBIL DATA PEMINJAMAN USER
  // =============================
  Future<List<Map<String, dynamic>>> fetchAktivitas() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final res = await supabase
        .from('peminjaman')
        .select('''
          id_peminjaman,
          tanggal_pinjam,
          tanggal_jatuh_tempo,
          status_persetujuan,
          alat:id_alat(nama_alat, gambar)
        ''')
        .eq('id_peminjam', user.id)
        .order('tanggal_pinjam', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> tolakPeminjaman(int idPeminjaman, int idAlat) async {
    // 1. Update status peminjaman
    await supabase.from('peminjaman').update({
      'status_persetujuan': 'ditolak',
    }).eq('id_peminjaman', idPeminjaman);

    // 2. KEMBALIKAN STATUS ALAT
    await supabase.from('alat').update({
      'status_alat': 'tersedia',
    }).eq('id_alat', idAlat);
  }

  // =============================
  // FORMAT TANGGAL
  // =============================
  String formatTanggal(String? date) {
    if (date == null) return '-';
    final d = DateTime.parse(date);
    return "${d.day}/${d.month}/${d.year}";
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

                      final String statusDb =
                          data['status_persetujuan'] ?? 'menunggu';

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
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      alat?['gambar'] ?? '',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          alat?['nama_alat'] ??
                                              'Alat tidak diketahui',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: const Color(0xFF2F4157),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _statusBadge(statusDb),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // ===== TANGGAL =====
                              Text(
                                "Pinjam : ${formatTanggal(data['tanggal_pinjam'])}",
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              Text(
                                "Jatuh Tempo : ${formatTanggal(data['tanggal_jatuh_tempo'])}",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.redAccent,
                                ),
                              ),

                              // ===== TOMBOL PENGEMBALIAN =====
                              if (statusDb == 'disetujui')
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 36,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF2F4157),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () {
                                        bukaFormPengembalian(
                                          data['id_peminjaman'],
                                        );
                                      },
                                      child: Text(
                                        "Ajukan Pengembalian",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
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
  // BADGE STATUS (USER FRIENDLY)
  // =============================
  Widget _statusBadge(String status) {
    String label;
    Color color;

    if (status == 'disetujui') {
      label = 'Disetujui';
      color = Colors.green;
    } else if (status == 'ditolak') {
      label = 'Ditolak';
      color = Colors.red;
    } else {
      // menunggu / menunggu_pengembalian / null
      label = 'Diverifikasi';
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
