import 'package:supabase_flutter/supabase_flutter.dart';

class AlatService {
  final _supabase = Supabase.instance.client;

  // Fungsi untuk mengambil data alat
  Future<List<Map<String, dynamic>>> getAlat() async {
    final response = await _supabase.from('alat').select();
    return List<Map<String, dynamic>>.from(response);
  }

  // Fungsi untuk menambah data alat (5 parameter)
  Future<void> tambahAlat(String nama, String merk, String spek, int stok, int idKat) async {
    await _supabase.from('alat').insert({
      'nama_alat': nama,
      'merk': merk,
      'spesifikasi': spek,
      'stok': stok,
      'id_kategori': idKat,
    });
  }
}