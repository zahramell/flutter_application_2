// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailPeminjamanAdminPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const DetailPeminjamanAdminPage({super.key, required this.data});

  @override
  State<DetailPeminjamanAdminPage> createState() =>
      _DetailPeminjamanAdminPageState();
}

class _DetailPeminjamanAdminPageState extends State<DetailPeminjamanAdminPage> {
  final supabase = Supabase.instance.client;

  late TextEditingController jatuhTempoController;

  @override
  void initState() {
    super.initState();
    jatuhTempoController = TextEditingController(
      text: widget.data['tanggal_jatuh_tempo'] ?? '',
    );
  }

  // ================= UPDATE (HANYA TANGGAL + VALIDASI) =================
  Future<void> updatePeminjaman() async {
    // ===== VALIDASI =====
    if (jatuhTempoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Tanggal jatuh tempo wajib dipilih",
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // ===== UPDATE DATABASE =====
    await supabase.from('peminjaman').update({
      'tanggal_jatuh_tempo': jatuhTempoController.text,
    }).eq('id_peminjaman', widget.data['id_peminjaman']);

    // ===== FEEDBACK SUKSES =====
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Tanggal jatuh tempo berhasil diperbarui",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final profil = widget.data['profiles'];
    final alat = widget.data['alat'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Detail Peminjaman"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= PROFIL PEMINJAM =================
            _profilPeminjam(profil),

            const SizedBox(height: 16),

            // ================= DETAIL PEMINJAMAN =================
            _detailPeminjaman(alat),

            const SizedBox(height: 20),

            // ================= FORM EDIT =================
            Text(
              "Pengaturan Peminjaman",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            // ===== DATE PICKER =====
            TextFormField(
              controller: jatuhTempoController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Tanggal Jatuh Tempo",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_month),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (picked != null) {
                  setState(() {
                    jatuhTempoController.text =
                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  });
                }
              },
            ),

            const SizedBox(height: 24),

            // ================= BUTTON =================
            Row(
              children: [
                // ===== BATAL =====
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(
                            "Batalkan Perubahan",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold),
                          ),
                          content: Text(
                            "Perubahan yang kamu lakukan tidak akan disimpan. Yakin ingin kembali?",
                            style: GoogleFonts.poppins(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child:
                                  Text("Tidak", style: GoogleFonts.poppins()),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // tutup dialog
                                Navigator.pop(context); // kembali
                              },
                              child: Text("Ya, Batal",
                                  style: GoogleFonts.poppins()),
                            ),
                          ],
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2F4157)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Batal",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2F4157),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ===== SIMPAN =====
                Expanded(
                  child: ElevatedButton(
                    onPressed: updatePeminjaman,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4157),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Simpan Perubahan",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= PROFIL =================
  Widget _profilPeminjam(Map<String, dynamic> profil) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: profil['foto'] != null && profil['foto'] != ''
                ? NetworkImage(profil['foto'])
                : null,
            child: (profil['foto'] == null || profil['foto'] == '')
                ? const Icon(Icons.person, size: 30, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profil['nama'],
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Sebagai : ${profil['role']}",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= DETAIL =================
  Widget _detailPeminjaman(Map<String, dynamic> alat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Detail Peminjaman",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _rowDetail("Nama Alat", alat['nama_alat']),
          _rowDetail("Tanggal Pinjam", widget.data['tanggal_pinjam']),
          _rowDetail(
            "Jatuh Tempo",
            widget.data['tanggal_jatuh_tempo'] ?? "Belum ditentukan",
          ),
          _rowDetail(
            "Status",
            widget.data['status_persetujuan'],
          ),
        ],
      ),
    );
  }

  Widget _rowDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
