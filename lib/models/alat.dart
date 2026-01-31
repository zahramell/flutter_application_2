class Alat {
  final int? id;
  final String namaAlat;
  final int idKategori; // <--- TAMBAHKAN INI (Sesuai kolom id_kategori di DB)
  final String statusAlat;
  final String gambar;

  Alat({
    this.id,
    required this.namaAlat,
    required this.idKategori, // <--- TAMBAHKAN DI CONSTRUCTOR
    required this.statusAlat,
    required this.gambar,
  });

  factory Alat.fromJson(Map<String, dynamic> json) {
    return Alat(
      id: json['id_alat'],
      namaAlat: json['nama_alat'] ?? '',
      // Ambil id_kategori dari baris data di database
      idKategori: json['id_kategori'] ?? 0,
      statusAlat: json['status_alat'] ?? '',
      gambar: json['gambar'] ?? '',
    );
  }
}
