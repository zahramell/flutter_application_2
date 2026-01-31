import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Halaman (Sesuai gaya desain Aktivitas)
            const Padding(
              padding: EdgeInsets.only(left: 25, top: 20),
              child: Text(
                "Notifikasi",
                style: TextStyle(
                  fontSize: 18, 
                  color: Colors.grey, 
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // Daftar Notifikasi
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                itemCount: 3, // Contoh jumlah notifikasi
                itemBuilder: (context, index) {
                  return _buildNotifCard(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifCard(int index) {
    // Simulasi konten notifikasi sesuai alur peminjaman
    List<String> titles = [
      "Peminjaman Disetujui",
      "Peminjaman Ditolak",
      "Pengingat Pengembalian"
    ];
    List<String> messages = [
      "Permintaan pinjam Kamera Canon EOS telah disetujui oleh admin.",
      "Maaf, permintaan pinjam Laptop ASUS ditolak karena sedang diservis.",
      "Jangan lupa mengembalikan Tripod besok pagi sebelum jam 09:00."
    ];
    List<IconData> icons = [
      Symbols.check_circle,
      Symbols.cancel,
      Symbols.schedule
    ];
    List<Color> colors = [
      const Color(0xFF27AE60), // Hijau
      const Color(0xFFFF4757), // Merah
      const Color(0xFFFF9F43), // Oranye
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      width: 329, // Ukuran lebar konsisten dengan Beranda & Aktivitas
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Notif Tipis (Material Symbols)
          Icon(
            icons[index], 
            color: colors[index], 
            weight: 300, 
            size: 28
          ),
          const SizedBox(width: 15),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[index],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF2F4157),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  messages[index],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Baru saja", // Waktu notifikasi
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}