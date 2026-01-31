import 'package:supabase_flutter/supabase_flutter.dart';

class KategoriService {
  final _supabase = Supabase.instance.client;

  // Fungsi mengambil semua data kategori
  Future<List<Map<String, dynamic>>> getKategori() async {
    try {
      final response = await _supabase
          .from('kategori_alat')
          .select(); // Pastikan nama tabel di Supabase 'kategori_alat'
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error Kategori: $e");
      return [];
    }
  }
}
