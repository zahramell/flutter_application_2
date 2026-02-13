import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengajuanPengembalianPage extends StatefulWidget {
  final Map data;

  const PengajuanPengembalianPage({
    super.key,
    required this.data,
  });

  @override
  State<PengajuanPengembalianPage> createState() =>
      _PengajuanPengembalianPageState();
}

class _PengajuanPengembalianPageState extends State<PengajuanPengembalianPage> {
  final supabase = Supabase.instance.client;

  late DateTime tanggalKembali;
  String kondisiDipilih = "Baik";

  int dendaTerlambat = 0;
  int dendaKerusakan = 0;

  int get totalDenda => dendaTerlambat + dendaKerusakan;

  @override
  void initState() {
    super.initState();
    tanggalKembali = DateTime.now();
    hitungDendaTerlambat();
  }

  void hitungDendaTerlambat() {
    final jatuhTempo = DateTime.parse(widget.data['tanggal_jatuh_tempo']);

    final selisih = tanggalKembali.difference(jatuhTempo).inDays;

    setState(() {
      dendaTerlambat = selisih > 0 ? selisih * 5000 : 0;
    });
  }

  void hitungDendaKerusakan(String kondisi) {
    setState(() {
      if (kondisi == "Rusak Ringan") {
        dendaKerusakan = 5000;
      } else if (kondisi == "Rusak Berat") {
        dendaKerusakan = 10000;
      } else {
        dendaKerusakan = 0;
      }
    });
  }

  Future<void> ajukanPengembalian() async {
    final idPeminjaman = widget.data['id_peminjaman'];

    await supabase.from('pengembalian').insert({
      'id_peminjaman': idPeminjaman,
      'tanggal_kembali_riil': tanggalKembali.toIso8601String(),
      'kondisi_alat': kondisiDipilih,
      'denda': totalDenda,
    });

    await supabase
        .from('peminjaman')
        .update({'status_persetujuan': 'menunggu_pengembalian'}).eq(
            'id_peminjaman', idPeminjaman);

    if (mounted) Navigator.pop(context, true);
  }

  String formatTanggal(DateTime t) {
    return "${t.day}/${t.month}/${t.year}";
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.data['profiles'];
    final alat = widget.data['alat'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pengembalian Alat"),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ================= DATA PEMINJAM =================
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['nama'],
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text("Alat: ${alat['nama_alat']}"),
                  Text("Tgl Pinjam: ${widget.data['tanggal_pinjam']}"),
                  Text("Jatuh Tempo: ${widget.data['tanggal_jatuh_tempo']}"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= TANGGAL =================
            _card(
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatTanggal(tanggalKembali),
                    style: GoogleFonts.poppins(),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tanggalKembali,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        setState(() {
                          tanggalKembali = picked;
                        });
                        hitungDendaTerlambat();
                      }
                    },
                    child: const Text("Pilih"),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= KONDISI =================
            _card(
              Column(
                children: [
                  _radio("Baik"),
                  _radio("Rusak Ringan"),
                  _radio("Rusak Berat"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= DENDA =================
            _card(
              Column(
                children: [
                  _rowDenda("Denda Terlambat", dendaTerlambat),
                  _rowDenda("Denda Kerusakan", dendaKerusakan),
                  const Divider(),
                  _rowDenda("Total Denda", totalDenda),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// ================= BUTTON =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ajukanPengembalian,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F4157),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Ajukan Pengembalian"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _radio(String label) {
    return RadioListTile<String>(
      value: label,
      groupValue: kondisiDipilih,
      onChanged: (v) {
        kondisiDipilih = v!;
        hitungDendaKerusakan(v);
      },
      title: Text(label, style: GoogleFonts.poppins()),
    );
  }

  Widget _rowDenda(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins()),
          Text("Rp $value", style: GoogleFonts.poppins()),
        ],
      ),
    );
  }

  /// ================= CARD WITH SHADOW =================
  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }
}
