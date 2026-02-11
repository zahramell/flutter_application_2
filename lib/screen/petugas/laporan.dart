import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchLaporan() async {
    final res = await supabase.from('peminjaman').select('''
      id_peminjaman,
      tanggal_pinjam,
      status_persetujuan,
      profiles!peminjaman_id_peminjam_fkey ( nama ),
      alat!peminjaman_id_alat_fkey ( nama_alat ),
      pengembalian ( denda, tanggal_kembali_riil )
    ''').order('tanggal_pinjam', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  String formatTanggal(String? date) {
    if (date == null) return "-";
    final d = DateTime.parse(date);
    return "${d.day}/${d.month}/${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Laporan Transaksi",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchLaporan(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          "Belum ada data laporan",
                          style: GoogleFonts.poppins(),
                        ),
                      );
                    }

                    final data = snapshot.data!;

                    int totalTransaksi = data.length;
                    int totalDenda = 0;

                    for (var item in data) {
                      final pengembalian =
                          (item['pengembalian'] as List).isNotEmpty
                              ? item['pengembalian'][0]
                              : null;

                      if (pengembalian != null) {
                        totalDenda +=
                            (pengembalian['denda'] ?? 0) as int;
                      }
                    }

                    return Column(
                      children: [

                        // ===== REKAP =====
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin:
                              const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Transaksi : $totalTransaksi",
                                style: GoogleFonts.poppins(
                                    fontWeight:
                                        FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Total Denda : Rp $totalDenda",
                                style: GoogleFonts.poppins(
                                  color: totalDenda > 0
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== LIST =====
                        Expanded(
                          child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder:
                                (context, index) {
                              final d = data[index];
                              final pengembalian =
                                  (d['pengembalian']
                                              as List)
                                          .isNotEmpty
                                      ? d['pengembalian']
                                          [0]
                                      : null;

                              final String status =
                                  d['status_persetujuan'];

                              final int denda =
                                  pengembalian != null
                                      ? (pengembalian[
                                              'denda'] ??
                                          0)
                                      : 0;

                              return _card(
                                nama: d['profiles']
                                    ['nama'],
                                alat: d['alat']
                                    ['nama_alat'],
                                tanggal: formatTanggal(
                                    d['tanggal_pinjam']),
                                status: status,
                                denda: denda,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({
    required String nama,
    required String alat,
    required String tanggal,
    required String status,
    required int denda,
  }) {
    Color warnaStatus;

    switch (status) {
      case 'disetujui':
        warnaStatus = Colors.blue;
        break;
      case 'ditolak':
        warnaStatus = Colors.red;
        break;
      case 'selesai':
        warnaStatus = Colors.green;
        break;
      default:
        warnaStatus = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            nama,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text("Alat : $alat",
              style:
                  GoogleFonts.poppins(fontSize: 12)),
          Text("Tanggal : $tanggal",
              style:
                  GoogleFonts.poppins(fontSize: 12)),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets
                    .symmetric(
                        horizontal: 12,
                        vertical: 4),
                decoration: BoxDecoration(
                  color:
                      warnaStatus.withOpacity(0.15),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: warnaStatus,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
              Text(
                "Denda: Rp $denda",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: denda > 0
                      ? Colors.red
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
