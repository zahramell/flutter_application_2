import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

class BerandaPetugas extends StatefulWidget {
  const BerandaPetugas({super.key});

  @override
  State<BerandaPetugas> createState() => _BerandaPetugasState();
}

class _BerandaPetugasState extends State<BerandaPetugas> {
  // Variabel data (nanti bisa dihubungkan ke Supabase)
  final String namaPetugas = "Zahramel";
  final String fotoUser = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // Padding horizontal 25 agar sejajar dari atas sampai bawah
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER PROFIL (Sudah Sejajar & Tanpa Biru-biru) ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFEFEFEF),
                    backgroundImage:
                        fotoUser.isNotEmpty ? NetworkImage(fotoUser) : null,
                    child: fotoUser.isEmpty
                        ? const Icon(Symbols.person,
                            color: Color(0xFF34495E), size: 30)
                        : null,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        namaPetugas,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                          height: 1.2,
                        ),
                      ),
                      Text(
                        "Petugas",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF999999),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // --- KOTAK MENU STATISTIK (Konfirmasi & Kembali) ---
              Row(
                children: [
                  // Menu Konfirmasi
                  Expanded(
                    child: _buildMenuBox("3", "Konfirmasi", null),
                  ),
                  const SizedBox(width: 20),
                  // Menu Kembali
                  Expanded(
                    child:
                        _buildMenuBox(null, "Kembali", Symbols.account_circle),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // --- JUDUL DAFTAR ---
              Text(
                "Perlu Disetujui",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 15),

              // --- KARTU DAFTAR PERSETUJUAN (Warna Biru Muda) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(
                      0xFFCDE0E9), // Biru muda sesuai desain petugas
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    _buildListItem(
                        "1.", "Seliya", "Logitech MK270 Wireless\nCombo _ HSN"),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Colors.black45, thickness: 1),
                    ),
                    _buildListItem(
                        "2.", "Ahmad", "Logitech MK270 Wireless\nCombo _ HSN"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pendukung untuk Kotak Statistik Navy
  Widget _buildMenuBox(String? angka, String label, IconData? icon) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF34495E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (angka != null)
            Text(angka,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold))
          else
            Icon(icon, color: Colors.white, size: 30),
          Text(label,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  // Widget pendukung untuk Baris Daftar
  Widget _buildListItem(String no, String nama, String barang) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(no,
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nama,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              Text(barang,
                  style:
                      GoogleFonts.poppins(fontSize: 12, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
}
