import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header Judul
            const Padding(
              padding: EdgeInsets.only(left: 25, top: 20, bottom: 30),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Profil",
                  style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ),
            ),

            // Foto Profil & Nama (Sesuai gaya mockup Aktivitas)
            Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFE5D1B8),
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=shellya'),
                ),
                const SizedBox(height: 15),
                Text(
                  user?.email?.split('@')[0].toUpperCase() ?? "SHELIYA",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2F4157)),
                ),
                const Text("Mahasiswa / Peminjam", style: TextStyle(color: Colors.grey)),
              ],
            ),

            const SizedBox(height: 40),

            // Menu Pengaturan (Menggunakan Material Symbols Icons Tipis)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                children: [
                  _buildMenuItem(Symbols.person, "Informasi Akun"),
                  _buildMenuItem(Symbols.history, "Riwayat Peminjaman"),
                  _buildMenuItem(Symbols.lock, "Ubah Kata Sandi"),
                  _buildMenuItem(Symbols.help_outline, "Pusat Bantuan"),
                  const SizedBox(height: 20),
                  
                  // Tombol Logout Terhubung Supabase
                  GestureDetector(
                    onTap: () async {
                      await supabase.auth.signOut();
                      // Tambahkan navigasi balik ke halaman Login di sini
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5E5), // Merah muda halus
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Row(
                        children: [
                          Icon(Symbols.logout, color: Colors.red, weight: 300),
                          SizedBox(width: 15),
                          Text(
                            "Keluar",
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2F4157), weight: 300),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF2F4157)),
          ),
          const Spacer(),
          const Icon(Symbols.chevron_right, color: Colors.grey, weight: 300),
        ],
      ),
    );
  }
}