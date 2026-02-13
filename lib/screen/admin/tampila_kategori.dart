// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TampilanKategori extends StatefulWidget {
  const TampilanKategori({super.key});

  @override
  State<TampilanKategori> createState() => _TampilanKategoriState();
}

class _TampilanKategoriState extends State<TampilanKategori> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _namaController = TextEditingController();

  List<Map<String, dynamic>> kategoriList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getKategori();
  }

  // ================= READ =================
  Future<void> getKategori() async {
    try {
      final response =
          await _supabase.from('kategori_alat').select().order('id_kategori');

      setState(() {
        kategoriList = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error get kategori: $e');
      setState(() => isLoading = false);
    }
  }

  // ================= CREATE =================
  Future<void> tambahKategori() async {
    if (_namaController.text.isEmpty) return;

    await _supabase.from('kategori_alat').insert({
      'nama_kategori': _namaController.text,
    });

    _namaController.clear();
    getKategori();
  }

  // ================= UPDATE =================
  Future<void> editKategori(int id) async {
    if (_namaController.text.isEmpty) return;

    await _supabase
        .from('kategori_alat')
        .update({'nama_kategori': _namaController.text}).eq('id_kategori', id);

    _namaController.clear();
    getKategori();
  }

  // ================= DELETE =================
  Future<void> hapusKategori(int id) async {
    await _supabase.from('kategori_alat').delete().eq('id_kategori', id);
    getKategori();
  }

  // ================= DIALOG TAMBAH =================
  void dialogTambah() {
    _namaController.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Tambah Kategori',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: _namaController,
          style: GoogleFonts.poppins(),
          decoration: InputDecoration(
            labelText: 'Nama Kategori',
            labelStyle: GoogleFonts.poppins(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              await tambahKategori();
              Navigator.pop(context);
            },
            child: Text('Simpan', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  // ================= DIALOG EDIT =================
  void dialogEdit(Map<String, dynamic> data) {
    _namaController.text = data['nama_kategori'];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Edit Kategori',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: _namaController,
          style: GoogleFonts.poppins(),
          decoration: InputDecoration(
            labelText: 'Nama Kategori',
            labelStyle: GoogleFonts.poppins(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              await editKategori(data['id_kategori']);
              Navigator.pop(context);
            },
            child: Text('Update', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  // ================= DIALOG HAPUS =================
  void dialogHapus(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Hapus Kategori',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah yakin ingin menghapus kategori ini?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await hapusKategori(id);
              Navigator.pop(context);
            },
            child: Text('Hapus', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text(
          'Data Kategori',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: dialogTambah,
        child: const Icon(Symbols.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : kategoriList.isEmpty
              ? Center(
                  child: Text(
                    'Data kategori kosong',
                    style: GoogleFonts.poppins(),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: kategoriList.length,
                  itemBuilder: (context, index) {
                    final data = kategoriList[index];
                    return Center(
                      child: SizedBox(
                        width: 329, // ✅ WIDTH CARD 329
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: const Icon(Symbols.category),
                            title: Text(
                              data['nama_kategori'],
                              style: GoogleFonts.poppins(),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Symbols.edit,
                                    color: Colors.orange,
                                  ),
                                  onPressed: () => dialogEdit(data),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Symbols.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      dialogHapus(data['id_kategori']),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
