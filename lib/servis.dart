import 'package:supabase_flutter/supabase_flutter.dart';
import 'model.dart';

class DatabaseService {
  final supabase = Supabase.instance.client;

  // Mengambil daftar alat
  Future<List<AlatModel>> fetchAlat() async {
    final response = await supabase.from('alat').select();
    return (response as List).map((e) => AlatModel.fromJson(e)).toList();
  }

  // Mengambil profil user yang sedang login
  Future<UserModel> getMyProfile() async {
    final user = supabase.auth.currentUser;
    final data = await supabase.from('profiles').select().eq('id', user!.id).single();
    return UserModel.fromJson(data);
  }
}