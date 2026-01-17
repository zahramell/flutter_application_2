// Model untuk Profil User
class UserModel {
  final String id;
  final String namaLengkap;
  final String role;

  UserModel({required this.id, required this.namaLengkap, required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      namaLengkap: json['nama_lengkap'] ?? '',
      role: json['role'] ?? 'Peminjam',
    );
  }
}

// Model untuk Data Alat
class AlatModel {
  final int idAlat;
  final String namaAlat;
  final String statusAlat;

  AlatModel(
      {required this.idAlat, required this.namaAlat, required this.statusAlat});

  factory AlatModel.fromJson(Map<String, dynamic> json) {
    return AlatModel(
      idAlat: json['id_alat'],
      namaAlat: json['nama_alat'],
      statusAlat: json['status_alat'],
    );
  }
}
