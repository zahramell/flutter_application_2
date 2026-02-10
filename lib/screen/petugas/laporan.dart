import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final supabase = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> _futureLaporan;

  @override
  void initState() {
    super.initState();
    _futureLaporan = fetchLaporan();
  }

  // ================= AMBIL LAPORAN =================
  Future<List<Map<String, dynamic>>> fetchLaporan() async {
    final res = await supabase.from('peminjaman').select('''
      tanggal_pinjam,
      tanggal_jatuh_tempo,
      status_persetujuan,
      profiles(nama),
      alat(nama_alat),
      pengembalian(
        tanggal_kembali_riil,
        denda
      )
    ''').order('tanggal_pinjam', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  // ================= PRINT PDF =================
  Future<void> printLaporan(List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "LAPORAN PEMINJAMAN & PENGEMBALIAN",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Table.fromTextArray(
                headers: [
                  'No',
                  'Peminjam',
                  'Alat',
                  'Pinjam',
                  'Kembali',
                  'Status',
                  'Denda'
                ],
                data: List.generate(data.length, (i) {
                  final d = data[i];
                  final kembali = d['pengembalian'];

                  return [
                    (i + 1).toString(),
                    d['profiles']['nama'],
                    d['alat']['nama_alat'],
                    d['tanggal_pinjam'] ?? '-',
                    kembali != null
                        ? kembali['tanggal_kembali_riil'] ?? '-'
                        : '-',
                    d['status_persetujuan'],
                    kembali != null ? 'Rp ${kembali['denda'] ?? 0}' : '-',
                  ];
                }),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureLaporan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada data laporan"));
          }

          final data = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final d = data[i];
                    final kembali = d['pengembalian'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Text("${i + 1}"),
                        title: Text(
                          d['profiles']['nama'],
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${d['alat']['nama_alat']}\n"
                          "Pinjam: ${d['tanggal_pinjam']}\n"
                          "Kembali: ${kembali != null ? kembali['tanggal_kembali_riil'] ?? '-' : '-'}\n"
                          "Status: ${d['status_persetujuan']}",
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        trailing: Text(
                          kembali != null ? "Rp ${kembali['denda'] ?? 0}" : "-",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ===== BUTTON PRINT =====
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => printLaporan(data),
                    icon: const Icon(Icons.print),
                    label: const Text("CETAK LAPORAN"),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
