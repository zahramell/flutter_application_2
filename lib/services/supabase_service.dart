import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/alat.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  Future<List<Alat>> getAlat() async {
    try {
      final response = await _client.from('alat').select();
      final data = response as List<dynamic>;
      return data.map((item) => Alat.fromJson(item)).toList();
    } catch (e) {
      print("Error fetching data: $e");
      return [];
    }
  }

  // --- TAMBAHKAN KODE INI ---
  Future<List<Map<String, dynamic>>> getKategori() async {
    try {
      final response = await _client.from('kategori').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching kategori: $e");
      return [];
    }
  }
  // --------------------------

  Future<void> tambahAlat(String nama, int idKategori, String status, String urlGambar) async {
    await _client.from('alat').insert({
      'nama_alat': nama,
      'id_kategori': idKategori,
      'status_alat': status,
      'gambar': urlGambar,
    });
  }
}