import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailPengembalianPage extends StatelessWidget {
  final Map<String, dynamic> data;
  const DetailPengembalianPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final profil = data['peminjaman']['profiles'];
    final alat = data['peminjaman']['alat'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Pengembalian"),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profil['nama'],
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Role: ${profil['role']}",
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _box(
              child: Column(
                children: [
                  _row("Alat", alat['nama_alat']),
                  _row("Pinjam", data['peminjaman']['tanggal_pinjam']),
                  _row("Kembali", data['tanggal_kembali_riil']),
                  _row("Kondisi", data['kondisi_alat']),
                  _row("Denda", "Rp ${data['denda'] ?? 0}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
