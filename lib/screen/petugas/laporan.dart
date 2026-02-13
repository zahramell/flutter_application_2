import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // WAJIB untuk kIsWeb
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final supabase = Supabase.instance.client;

  // ================= FETCH DATA =================
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

  // ================= CETAK PDF =================
  Future<void> cetakPdf(List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();
    int totalDenda = 0;

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            "LAPORAN TRANSAKSI PEMINJAMAN ALAT",
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ["Nama", "Alat", "Tanggal", "Status", "Denda"],
            data: data.map((item) {
              final pengembalianRaw = item['pengembalian'];
              Map<String, dynamic>? pengembalian;

              if (pengembalianRaw is List && pengembalianRaw.isNotEmpty) {
                pengembalian = pengembalianRaw[0];
              } else if (pengembalianRaw is Map<String, dynamic>) {
                pengembalian = pengembalianRaw;
              }

              final int denda =
                  pengembalian != null ? (pengembalian['denda'] ?? 0) : 0;

              totalDenda += denda;

              return [
                item['profiles']['nama'] ?? '-',
                item['alat']['nama_alat'] ?? '-',
                formatTanggal(item['tanggal_pinjam']),
                item['status_persetujuan'] ?? '-',
                "Rp $denda",
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Text("Total Transaksi : ${data.length}"),
          pw.Text("Total Denda : Rp $totalDenda"),
        ],
      ),
    );

    final bytes = await pdf.save();

    if (kIsWeb) {
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
      );
    } else {
      await Printing.sharePdf(
        bytes: bytes,
        filename: "laporan_transaksi.pdf",
      );
    }
  }

  // ================= UI =================
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          "Belum ada data laporan",
                          style: GoogleFonts.poppins(),
                        ),
                      );
                    }

                    final data = snapshot.data!;
                    int totalDenda = 0;

                    for (var item in data) {
                      final pengembalianRaw = item['pengembalian'];
                      Map<String, dynamic>? pengembalian;

                      if (pengembalianRaw is List &&
                          pengembalianRaw.isNotEmpty) {
                        pengembalian = pengembalianRaw[0];
                      } else if (pengembalianRaw is Map<String, dynamic>) {
                        pengembalian = pengembalianRaw;
                      }

                      if (pengembalian != null) {
                        totalDenda += (pengembalian['denda'] ?? 0) as int;
                      }
                    }

                    return Column(
                      children: [
                        // ===== BUTTON CETAK =====
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () => cetakPdf(data),
                            icon: const Icon(Icons.print),
                            label: const Text("Cetak PDF"),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ===== REKAP =====
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Transaksi : ${data.length}",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600),
                              ),
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
                            itemBuilder: (context, index) {
                              final d = data[index];

                              final pengembalianRaw = d['pengembalian'];

                              Map<String, dynamic>? pengembalian;

                              if (pengembalianRaw is List &&
                                  pengembalianRaw.isNotEmpty) {
                                pengembalian = pengembalianRaw[0];
                              }

                              final int denda = pengembalian != null
                                  ? (pengembalian['denda'] ?? 0)
                                  : 0;

                              return _card(
                                nama: d['profiles']['nama'],
                                alat: d['alat']['nama_alat'],
                                tanggal: formatTanggal(d['tanggal_pinjam']),
                                status: d['status_persetujuan'],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(nama, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          Text("Alat : $alat", style: GoogleFonts.poppins(fontSize: 12)),
          Text("Tanggal : $tanggal", style: GoogleFonts.poppins(fontSize: 12)),
          const SizedBox(height: 8),
          Text("Status : ${status.toUpperCase()}",
              style: GoogleFonts.poppins(fontSize: 12)),
          Text(
            "Denda : Rp $denda",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: denda > 0 ? Colors.red : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
