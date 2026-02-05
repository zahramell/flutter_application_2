import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../models/kategori.dart';
import '../../models/alat.dart';

class CrudAlatPage extends StatefulWidget {
  final String role;
  const CrudAlatPage({super.key, required this.role});

  @override
  State<CrudAlatPage> createState() => _AdminBerandaScreenState();
}

class _AdminBerandaScreenState extends State<CrudAlatPage> {
  final supabase = Supabase.instance.client;
  final supabaseService = SupabaseService();
  final kategoriService = KategoriService();

  int? _selectedCategoryId;
  String _searchQuery = "";

  // Fungsi Hapus Alat
  Future<void> _deleteAlat(int id) async {
    await supabase.from('alat').delete().match({'id': id});
    setState(() {}); // Refresh UI setelah hapus
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Tombol Tambah tetap di sini sesuai permintaan
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2F4157),
        onPressed: () {
          // Navigasi ke halaman Tambah Alat
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 1. SEARCH BAR (Ukuran lebar 321)
            Center(
              child: Container(
                width: 321,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "Pencarian",
                    hintStyle: GoogleFonts.poppins(color: const Color(0xFF999999), fontSize: 14),
                    prefixIcon: const Icon(Symbols.search, color: Color(0xFF999999), size: 20),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // 2. FILTER KATEGORI (Horizontal Scroll)
            FutureBuilder<List<Map<String, dynamic>>>(
              future: kategoriService.getKategori(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox(height: 45);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: snapshot.data!.map((cat) {
                      bool isActive = _selectedCategoryId == cat['id_kategori'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategoryId = isActive ? null : cat['id_kategori']),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 102,
                          height: 31,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFFC7D9E5) : const Color(0xFFEFEFEF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            cat['nama_kategori'],
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF2F4157),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            // 3. DAFTAR ALAT (Card Admin 329 x 142)
            Expanded(
              child: FutureBuilder<List<Alat>>(
                future: supabaseService.getAlat(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final filteredList = snapshot.data?.where((alat) {
                    final matchCategory = _selectedCategoryId == null || alat.idKategori == _selectedCategoryId;
                    final matchSearch = alat.namaAlat.toLowerCase().contains(_searchQuery);
                    return matchCategory && matchSearch;
                  }).toList() ?? [];

                  return ListView.builder(
                    itemCount: filteredList.length,
                    padding: const EdgeInsets.only(bottom: 100),
                    itemBuilder: (context, i) {
                      final alat = filteredList[i];
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          width: 329, // Ukuran Sesuai Permintaan
                          height: 142, // Ukuran Sesuai Permintaan
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  // Gambar Alat
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      alat.gambar,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => 
                                          const Icon(Icons.image_not_supported, size: 50),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  // Info Alat
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          alat.namaAlat,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: const Color(0xFF2F4157),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Badge Status
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: alat.statusAlat == 'Tersedia' 
                                                ? const Color(0xFF27AE60) 
                                                : Colors.orange,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            alat.statusAlat,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Tombol Edit & Hapus di Pojok Kanan Bawah
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Row(
                                  children: [
                                    _actionButton(Symbols.edit_square, () {
                                      // Logika Edit
                                    }),
                                    const SizedBox(width: 8),
                                    _actionButton(Symbols.delete, () {
                                      _deleteAlat(alat.id!);
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk tombol aksi bulat navy
  Widget _actionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Color(0xFF2F4157),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}