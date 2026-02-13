import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailPengembalianPage extends StatefulWidget {
  final Map data;

  const DetailPengembalianPage({
    super.key,
    required this.data,
  });

  @override
  State<DetailPengembalianPage> createState() => _DetailPengembalianPageState();
}

class _DetailPengembalianPageState extends State<DetailPengembalianPage> {
  final supabase = Supabase.instance.client;

  late Map<String, dynamic> dataAktif;

  // ✅ SIMPAN DENDA ASLI DARI PEMINJAM (TIDAK BERUBAH)
  late int dendaAwal;

  // ✅ DENDA TAMBAHAN DARI DOUBLE CHECK PETUGAS
  int dendaKerusakan = 0;

  String kondisiDipilih = "Baik";
  bool loading = false;

  // ✅ TOTAL FIX (TIDAK AKAN DOBEL LAGI)
  int get totalDenda => dendaAwal + dendaKerusakan;

  @override
  void initState() {
    super.initState();

    dataAktif = Map<String, dynamic>.from(widget.data);

    // Ambil denda asli hanya sekali
    dendaAwal = dataAktif['denda'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final peminjaman = dataAktif['peminjaman'];
    final user = peminjaman['profiles'];
    final alat = peminjaman['alat'];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Konfirmasi Pengembalian",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= INFO PEMINJAM =================
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['nama'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Alat: ${alat['nama_alat']}",
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  Text(
                    "Tgl Kembali: ${dataAktif['tanggal_kembali_riil']}",
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Denda Awal: Rp $dendaAwal",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: dendaAwal > 0 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= KONDISI =================
            _section(
              title: "Kondisi Alat Saat Dicek",
              child: Column(
                children: [
                  _radio("Baik"),
                  _radio("Rusak Ringan"),
                  _radio("Rusak Berat"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= TOTAL DENDA =================
            _section(
              title: "Total Denda",
              child: _rowHarga("Total Denda", totalDenda),
            ),

            const SizedBox(height: 24),

            // ================= BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F4157),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: loading ? null : _selesaikanPengembalian,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Selesaikan Pengembalian",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= RADIO (SUDAH FIX) =================
  Widget _radio(String label) {
    return RadioListTile<String>(
      value: label,
      groupValue: kondisiDipilih,
      onChanged: (v) {
        setState(() {
          kondisiDipilih = v!;

          if (v == "Rusak Ringan") {
            dendaKerusakan = 5000;
          } else if (v == "Rusak Berat") {
            dendaKerusakan = 10000;
          } else {
            dendaKerusakan = 0;
          }
        });
      },
      title: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 13),
      ),
    );
  }

  // ================= SIMPAN KE DATABASE =================
  Future<void> _selesaikanPengembalian() async {
    setState(() => loading = true);

    final idPengembalian = dataAktif['id_pengembalian'];
    final idPeminjaman = dataAktif['id_peminjaman'];
    final idAlat = dataAktif['peminjaman']['alat']['id_alat'];

    try {
      // UPDATE kondisi + total denda
      await supabase.from('pengembalian').update({
        'kondisi_alat': kondisiDipilih,
        'denda': totalDenda,
      }).eq('id_pengembalian', idPengembalian);

      await supabase.from('peminjaman').update({
        'status_persetujuan': 'selesai',
      }).eq('id_peminjaman', idPeminjaman);

      await supabase.from('alat').update({
        'status_alat': 'Tersedia',
      }).eq('id_alat', idAlat);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("ERROR pengembalian: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ================= WIDGET BANTUAN =================
  Widget _section({
    required String title,
    required Widget child,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _rowHarga(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12)),
        Text(
          "Rp $value",
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: value > 0 ? Colors.red : Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }
}
