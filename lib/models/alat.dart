class Alat {
  final int? id;
  final String namaAlat;
  final int idKategori;
  final String statusAlat;
  final String gambar;

  Alat({
    this.id,
    required this.namaAlat,
    required this.idKategori,
    required this.statusAlat,
    required this.gambar,
  });

  factory Alat.fromJson(Map<String, dynamic> json) {
    return Alat(
      id: json['id_alat'],
      namaAlat: json['nama_alat'] ?? '',
      idKategori: json['id_kategori'] ?? 0,
      statusAlat: json['status_alat'] ?? '',
      gambar: json['gambar'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_alat': id,
      'nama_alat': namaAlat,
      'id_kategori': idKategori,
      'status_alat': statusAlat,
      'gambar': gambar,
    };
  }
}