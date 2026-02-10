import 'package:supabase_flutter/supabase_flutter.dart';

class LogAktivitasService {
  final _supabase = Supabase.instance.client;

  Future<void> tambahLog(String aktivitas) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('log_aktivitas').insert({
      'id_pengguna': user.id,
      'aktivitas': aktivitas,
      'waktu': DateTime.now().toIso8601String(),
    });
  }
}
