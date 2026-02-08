import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'form_user.dart';

class UserAdminPage extends StatefulWidget {
  const UserAdminPage({super.key});

  @override
  State<UserAdminPage> createState() => _UserAdminPageState();
}

class _UserAdminPageState extends State<UserAdminPage> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final res =
        await supabase.from('profiles').select().order('nama', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> hapusUser(String id) async {
    await supabase.from('profiles').delete().eq('id', id);
    setState(() {});
  }

  void dialogHapus(Map user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Hapus User", style: GoogleFonts.poppins()),
        content: Text(
          "Apakah anda yakin ingin menghapus pengguna ini?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await hapusUser(user['id']);
            },
            child: Text("Hapus", style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2F4157),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormUserPage()),
          );
          setState(() {});
        },
        child: const Icon(Symbols.add, color: Colors.white),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // ===== HEADER =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Symbols.arrow_back, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  "Data Pengguna",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ===== LIST USER =====
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "Belum ada data user",
                      style: GoogleFonts.poppins(),
                    ),
                  );
                }

                final users = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final u = users[index];

                    return Center(
                      child: Container(
                        width: 329,
                        height: 142,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // ===== PROFIL =====
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.grey.shade300,
                                  backgroundImage:
                                      u['foto'] != null && u['foto'] != ''
                                          ? NetworkImage(u['foto'])
                                          : null,
                                  child: (u['foto'] == null || u['foto'] == '')
                                      ? const Icon(
                                          Symbols.person,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      u['nama'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Sebagai : ${u['role']}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // ===== ICON AKSI =====
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Row(
                                children: [
                                  _iconAction(
                                    icon: Symbols.edit,
                                    color: const Color(0xFF2F4157),
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              FormUserPage(data: u),
                                        ),
                                      );
                                      setState(() {});
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  _iconAction(
                                    icon: Symbols.delete,
                                    color: Colors.red,
                                    onTap: () => dialogHapus(u),
                                  ),
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
    );
  }

  Widget _iconAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}
