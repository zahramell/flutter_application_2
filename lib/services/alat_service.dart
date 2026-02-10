class AlatService {
  final _supabase = Supabase.instance.client;

  Future<List<Alat>> getAllAlat() async {
    final res = await _supabase.from('alat').select('*, kategori_alat(nama_kategori)');
    return res.map((e) => Alat.fromJson(e)).toList();
  }

  Future<void> createAlat(Map<String, dynamic> data) async {
    await _supabase.from('alat').insert(data);
  }

  Future<void> updateAlat(int id, Map<String, dynamic> data) async {
    await _supabase.from('alat').update(data).eq('id_alat', id);
  }

  Future<String?> uploadImage(XFile file) async {
    // logic upload ke bucket 'alat' seperti yang sudah dibahas sebelumnya
  }
}