import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersetujuanPage extends StatefulWidget {
  const PersetujuanPage({super.key});

  @override
  State<PersetujuanPage> createState() => _PersetujuanPageState();
}

class _PersetujuanPageState extends State<PersetujuanPage> {
  final supabase = Supabase.instance.client;
  int tab = 0; // 0 = Persetujuan, 1 = Pengembalian

  // =============================
  // FETCH DATA (SUDAH BENAR)
  // =============================
  Future<List<Map<String, dynamic>>> fetchData() async {
    if (tab == 0) {
      // ===== TAB PERSETUJUAN =====
      final res = await supabase
          .from('peminjaman')
          .select('''
            id_peminjaman,
            tanggal_pinjam,
            profiles!peminjaman_id_peminjam_fkey ( nama, foto ),
            alat!peminjaman_id_alat_fkey ( nama_alat )
          ''')
          .eq('status_persetujuan', 'menunggu')
          .order('tanggal_pinjam', ascending: false);

      return List<Map<String, dynamic>>.from(res);
    } else {
      // ===== TAB PENGEMBALIAN =====
      final res = await supabase.from('pengembalian').select('''
            id_pengembalian,
            tanggal_kembali_riil,
            kondisi_alat,
            denda,
            peminjaman:id_peminjaman (
              profiles!peminjaman_id_peminjam_fkey ( nama, foto ),
              alat!peminjaman_id_alat_fkey ( nama_alat )
            )
          ''').order('tanggal_kembali_riil', ascending: false);

      return List<Map<String, dynamic>>.from(res);
    }
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
                "Persetujuan (Petugas)",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // =============================
              // TAB
              // =============================
              Row(
                children: [
                  _tab("Persetujuan", 0),
                  const SizedBox(width: 8),
                  _tab("Pengembalian", 1),
                ],
              ),
              const SizedBox(height: 16),

              // =============================
              // LIST DATA
              // =============================
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          "Tidak ada data",
                          style: GoogleFonts.poppins(),
                        ),
                      );
                    }

                    final data = snapshot.data!;

                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, i) {
                        final d = data[i];

                        if (tab == 0) {
                          // ===== CARD PERSETUJUAN =====
                          return _cardPersetujuan(
                            nama: d['profiles']['nama'],
                            foto: d['profiles']['foto'],
                            alat: d['alat']['nama_alat'],
                            tanggal: d['tanggal_pinjam'],
                            id: d['id_peminjaman'],
                          );
                        } else {
                          // ===== CARD PENGEMBALIAN =====
                          final p = d['peminjaman'];
                          return _cardPengembalian(
                            nama: p['profiles']['nama'],
                            foto: p['profiles']['foto'],
                            alat: p['alat']['nama_alat'],
                            kondisi: d['kondisi_alat'],
                            denda: d['denda'],
                            tanggal: d['tanggal_kembali_riil'],
                          );
                        }
                      },
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

  // =============================
  // TAB WIDGET
  // =============================
  Widget _tab(String text, int i) {
    final active = tab == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tab = i),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2F4157) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: active ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =============================
  // CARD PERSETUJUAN
  // =============================
  Widget _cardPersetujuan({
    required String nama,
    required String alat,
    required String tanggal,
    required int id,
    String? foto,
  }) {
    return _baseCard(
      nama: nama,
      foto: foto,
      children: [
        Text("Alat: $alat", style: GoogleFonts.poppins(fontSize: 12)),
        Text("Tgl pinjam: $tanggal", style: GoogleFonts.poppins(fontSize: 12)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  await supabase
                      .from('peminjaman')
                      .update({'status_persetujuan': 'disetujui'}).eq(
                          'id_peminjaman', id);
                  setState(() {});
                },
                child: const Text("Setuju"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await supabase
                      .from('peminjaman')
                      .update({'status_persetujuan': 'ditolak'}).eq(
                          'id_peminjaman', id);
                  setState(() {});
                },
                child: const Text("Tolak"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =============================
  // CARD PENGEMBALIAN
  // =============================
  Widget _cardPengembalian({
    required String nama,
    required String alat,
    required String kondisi,
    required int denda,
    required String tanggal,
    String? foto,
  }) {
    return _baseCard(
      nama: nama,
      foto: foto,
      children: [
        Text("Alat: $alat", style: GoogleFonts.poppins(fontSize: 12)),
        Text("Tgl kembali: $tanggal", style: GoogleFonts.poppins(fontSize: 12)),
        Text("Kondisi: $kondisi", style: GoogleFonts.poppins(fontSize: 12)),
        Text(
          "Denda: Rp $denda",
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: denda > 0 ? Colors.red : Colors.green,
          ),
        ),
      ],
    );
  }

  // =============================
  // BASE CARD (AVATAR)
  // =============================
  Widget _baseCard({
    required String nama,
    required List<Widget> children,
    String? foto,
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
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    foto != null && foto.isNotEmpty ? NetworkImage(foto) : null,
                child: foto == null || foto.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  nama,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
