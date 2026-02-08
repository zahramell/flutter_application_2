import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengembalianAdminPage extends StatefulWidget {
  const PengembalianAdminPage({super.key});

  @override
  State<PengembalianAdminPage> createState() => _PengembalianAdminPageState();
}

class _PengembalianAdminPageState extends State<PengembalianAdminPage> {
  final supabase = Supabase.instance.client;

  Future<List> fetchPengembalian() async {
    return await supabase.from('pengembalian').select('''
      id_pengembalian,
      tanggal_kembali_riil,
      kondisi_alat,
      denda,
      peminjaman (
        tanggal_pinjam,
        profiles!peminjaman_id_peminjam_fkey (
          id,
          nama,
          role
        ),
        alat (
          nama_alat
        )
      )
    ''');
  }

  Future<void> hapusPengembalian(int id) async {
    await supabase.from('pengembalian').delete().eq('id_pengembalian', id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Pengembalian (Admin)"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: fetchPengembalian(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data as List;

          if (data.isEmpty) {
            return const Center(child: Text("Belum ada data pengembalian"));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final g = data[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    g['peminjaman']['alat']['nama_alat'],
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Peminjam : ${g['peminjaman']['profiles']['nama']}\n"
                    "Role : ${g['peminjaman']['profiles']['role']}\n"
                    "Pinjam : ${g['peminjaman']['tanggal_pinjam']}\n"
                    "Kembali : ${g['tanggal_kembali_riil']}\n"
                    "Kondisi : ${g['kondisi_alat']}\n"
                    "Denda : Rp ${g['denda']}",
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text("Edit")),
                      const PopupMenuItem(value: 'hapus', child: Text("Hapus")),
                    ],
                    onSelected: (value) {
                      if (value == 'hapus') {
                        hapusPengembalian(g['id_pengembalian']);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
