import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/supabase_service.dart';
import '../../models/kategori.dart';
import '../../models/alat.dart';

class BerandaScreen extends StatefulWidget {
  final String role;
  const BerandaScreen({super.key, required this.role});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final supabaseService = SupabaseService();
  final kategoriService = KategoriService();

  List<Alat> _keranjangAlat = [];
  DateTime? _selectedTanggalPinjam;
  DateTime? _selectedTanggalKembali;
  int? _selectedCategoryId;
  String _searchQuery = "";

  void _toggleKeranjang(Alat alat) {
    if (alat.statusAlat != 'Tersedia') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Alat tidak tersedia", style: GoogleFonts.poppins()),
        ),
      );
      return;
    }

    setState(() {
      final bool sudahAda = _keranjangAlat.any((item) => item.id == alat.id);
      if (sudahAda) {
        _keranjangAlat.removeWhere((item) => item.id == alat.id);
      } else {
        _keranjangAlat.add(alat);
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFD1E1E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 16),
                Text(
                  "Pesan Dikirim",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  "Permintaan peminjam telah di kirim ke petugas. Silahkan menunggu konfirmasi",
                  textAlign: TextAlign.center,
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 180,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _keranjangAlat.clear();
                        _selectedTanggalPinjam = null;
                        _selectedTanggalKembali = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF34495E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("Lihat Status",
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRingkasanPesanan() {
    if (_keranjangAlat.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Pilih alat terlebih dahulu",
                style: GoogleFonts.poppins())),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(25),
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)))),
                ),
                const SizedBox(height: 20),
                Text("Ringkasan Pinjaman",
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2F4157))),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Symbols.calendar_month,
                      color: Color(0xFF2F4157)),
                  title: Text(
                    _selectedTanggalPinjam == null
                        ? "Pilih Tanggal Pinjam"
                        : "Tanggal: ${_selectedTanggalPinjam!.day}/${_selectedTanggalPinjam!.month} - ${_selectedTanggalKembali!.day}/${_selectedTanggalKembali!.month}",
                    style: GoogleFonts.poppins(),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedTanggalPinjam = picked;
                        _selectedTanggalKembali =
                            picked.add(const Duration(days: 3));
                      });
                      setModalState(() {});
                    }
                  },
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: _keranjangAlat.length,
                    itemBuilder: (context, index) {
                      final item = _keranjangAlat[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item.gambar,
                              width: 50, height: 50, fit: BoxFit.cover),
                        ),
                        title: Text(item.namaAlat,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text("Durasi: 3 Hari",
                            style: GoogleFonts.poppins()),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () {
                            setState(() => _keranjangAlat.removeAt(index));
                            if (_keranjangAlat.isEmpty) {
                              Navigator.pop(context);
                            } else {
                              setModalState(() {});
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4157),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: _selectedTanggalPinjam == null
                        ? null
                        : () {
                            Navigator.pop(context);
                            _showSuccessDialog();
                          },
                    child: Text("KONFIRMASI PINJAMAN",
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: SizedBox(
          width: 60,
          height: 60,
          child: FloatingActionButton(
            onPressed: _showRingkasanPesanan,
            backgroundColor: const Color(0xFF2F4157),
            shape: const CircleBorder(),
            elevation: 6,
            child: Badge(
              label: Text(_keranjangAlat.length.toString(),
                  style: GoogleFonts.poppins(fontSize: 10)),
              isLabelVisible: _keranjangAlat.isNotEmpty,
              child: const Icon(Icons.shopping_cart_outlined,
                  color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER USER
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFC7D9E5),
                    backgroundImage:
                        NetworkImage('https://i.pravatar.cc/150?u=shellya'),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Sheliya",
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      Text(
                          widget.role == 'peminjam'
                              ? "Peminjam"
                              : widget.role.toUpperCase(),
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: const Color(0xFF999999))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // SEARCH BAR
              Center(
                child: Container(
                  width: 321,
                  height: 40, // Sedikit lebih tinggi untuk kenyamanan input
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    style: GoogleFonts.poppins(fontSize: 14),
                    onChanged: (value) =>
                        setState(() => _searchQuery = value.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: "Pencarian",
                      hintStyle:
                          GoogleFonts.poppins(color: const Color(0xFF999999)),
                      prefixIcon:
                          const Icon(Symbols.search, color: Color(0xFF999999)),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // LIST KATEGORI
              FutureBuilder<List<Map<String, dynamic>>>(
                future: kategoriService.getKategori(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox(height: 45);
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: snapshot.data!.map((cat) {
                        bool isActive =
                            _selectedCategoryId == cat['id_kategori'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategoryId =
                              isActive ? null : cat['id_kategori']),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 102,
                            height: 31,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFC7D9E5)
                                  : const Color(0xFFEFEFEF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(cat['nama_kategori'],
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF2F4157),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 25),

              // LIST ALAT
              FutureBuilder<List<Alat>>(
                future: supabaseService.getAlat(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final filteredList = snapshot.data?.where((alat) {
                        final matchCategory = _selectedCategoryId == null ||
                            alat.idKategori == _selectedCategoryId;
                        final matchSearch =
                            alat.namaAlat.toLowerCase().contains(_searchQuery);
                        return matchCategory && matchSearch;
                      }).toList() ??
                      [];

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    padding: const EdgeInsets.only(bottom: 100),
                    itemBuilder: (context, i) {
                      final alat = filteredList[i];
                      bool isSelected =
                          _keranjangAlat.any((item) => item.id == alat.id);
                      return Center(
                        child: GestureDetector(
                          onTap: () => _toggleKeranjang(alat),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: 329,
                            height: 142,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? Border.all(
                                      color: const Color(0xFF2F4157), width: 2)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(alat.gambar,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(alat.namaAlat,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: const Color(0xFF2F4157))),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: alat.statusAlat == 'Tersedia'
                                              ? const Color(0xFF27AE60)
                                              : Colors.orange,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(alat.statusAlat,
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle,
                                      color: Color(0xFF2F4157)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
