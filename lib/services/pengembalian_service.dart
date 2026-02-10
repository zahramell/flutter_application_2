import 'package:supabase_flutter/supabase_flutter.dart';

class PengembalianService {
  final _client = Supabase.instance.client;

  Future<void> ajukanPengembalian({
    required int idPeminjaman,
    required String kondisiAlat,
  }) async {
    // 1️⃣ ambil data peminjaman
    final peminjaman = await _client
        .from('peminjaman')
        .select('id_alat, tanggal_jatuh_tempo')
        .eq('id_peminjaman', idPeminjaman)
        .single();

    final DateTime jatuhTempo =
        DateTime.parse(peminjaman['tanggal_jatuh_tempo']);
    final DateTime hariIni = DateTime.now();

    // 2️⃣ hitung denda
    int denda = 0;
    if (hariIni.isAfter(jatuhTempo)) {
      final selisih = hariIni.difference(jatuhTempo).inDays;
      denda = selisih * 1000; // Rp1000 / hari
    }

    // 3️⃣ insert pengembalian
    await _client.from('pengembalian').insert({
      'id_peminjaman': idPeminjaman,
      'tanggal_kembali_riil': hariIni.toIso8601String(),
      'kondisi_alat': kondisiAlat,
      'denda': denda,
    });

    // 4️⃣ update peminjaman
    await _client
        .from('peminjaman')
        .update({'status_persetujuan': 'dikembalikan'}).eq(
            'id_peminjaman', idPeminjaman);

    // 5️⃣ update alat
    await _client.from('alat').update({'status_alat': 'tersedia'}).eq(
        'id_alat', peminjaman['id_alat']);
  }
}
