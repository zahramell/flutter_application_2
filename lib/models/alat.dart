class Alat {
  final int? id;
  final String namaAlat;
  final int idKategori;
  final String statusAlat;
  final String gambar;
  final int stok; // Tambahan stok

  Alat({
    this.id,
    required this.namaAlat,
    required this.idKategori,
    required this.statusAlat,
    required this.gambar,
    required this.stok,
  });

  factory Alat.fromJson(Map<String, dynamic> json) {
    return Alat(
      id: json['id_alat'],
      namaAlat: json['nama_alat'] ?? '',
      idKategori: json['id_kategori'] ?? 0,
      statusAlat: json['status_alat'] ?? '',
      gambar: json['gambar'] ?? '',
      stok: json['stok'] ?? 0, // Ambil dari kolom stok
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_alat': id,
      'nama_alat': namaAlat,
      'id_kategori': idKategori,
      'status_alat': statusAlat,
      'gambar': gambar,
      'stok': stok,
    };
  }
}