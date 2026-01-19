import 'package:supabase_flutter/supabase_flutter.dart';
import 'model.dart';

class DatabaseService {
  final supabase = Supabase.instance.client;

  // Mengambil daftar alat
  Future<List<AlatModel>> fetchAlat() async {
    try {
      final response = await supabase.from('alat').select();
      
      // Cast ke List<dynamic> untuk keamanan tipe data
      final List<dynamic> data = response as List<dynamic>;
      
      return data.map((e) => AlatModel.fromJson(e)).toList();
    } catch (e) {
      // Menangani error seperti tabel tidak ditemukan atau koneksi gagal
      throw Exception('Gagal mengambil data alat: $e');
    }
  }

  // Mengambil profil user yang sedang login
  Future<UserModel?> getMyProfile() async {
    try {
      final user = supabase.auth.currentUser;
      
      // Proteksi jika user ternyata null (belum login)
      if (user == null) return null;

      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
          
      return UserModel.fromJson(data);
    } catch (e) {
      throw Exception('Gagal mengambil profil: $e');
    }
  }
}