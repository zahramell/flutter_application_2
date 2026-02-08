import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';

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
  late String status;

  @override
  void initState() {
    super.initState();
    jatuhTempoController = TextEditingController(
      text: widget.data['tanggal_jatuh_tempo'] ?? '',
    );
    status = widget.data['status_persetujuan'];
  }

  // ================= UPDATE =================
  Future<void> updatePeminjaman() async {
    await supabase.from('peminjaman').update({
      'tanggal_jatuh_tempo': jatuhTempoController.text,
      'status_persetujuan': status,
    }).eq('id_peminjaman', widget.data['id_peminjaman']);

    Navigator.pop(context, true);
  }

  // ================= DELETE =================
  Future<void> hapusPeminjaman() async {
    await supabase
        .from('peminjaman')
        .delete()
        .eq('id_peminjaman', widget.data['id_peminjaman']);

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
            _profilDenganAksi(profil),

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

            TextField(
              controller: jatuhTempoController,
              decoration: const InputDecoration(
                labelText: "Tanggal Jatuh Tempo",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(
                labelText: "Status Peminjaman",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Di Verifikasi',
                  child: Text('Di Verifikasi'),
                ),
                DropdownMenuItem(
                  value: 'Disetujui',
                  child: Text('Disetujui'),
                ),
                DropdownMenuItem(
                  value: 'Ditolak',
                  child: Text('Ditolak'),
                ),
              ],
              onChanged: (val) => setState(() => status = val!),
            ),

            const SizedBox(height: 24),

            // ================= BUTTON SIMPAN =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: updatePeminjaman,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F4157),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Simpan Perubahan"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= WIDGET PROFIL + AKSI =================
  Widget _profilDenganAksi(Map<String, dynamic> profil) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profil['nama'],
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Sebagai : ${profil['role']}",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              InkWell(
                onTap: updatePeminjaman,
                child: _iconAction(
                  icon: Symbols.edit,
                  color: const Color(0xFF2F4157),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: hapusPeminjaman,
                child: _iconAction(
                  icon: Symbols.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= DETAIL PEMINJAMAN =================
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
          _rowDetail("Jatuh Tempo",
              widget.data['tanggal_jatuh_tempo'] ?? "Belum ditentukan"),
          _rowDetail("Status", widget.data['status_persetujuan']),
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

  Widget _iconAction({required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }
}
