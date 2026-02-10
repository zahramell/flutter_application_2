import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_2/screen/login.dart';

class PengaturanAdminPage extends StatefulWidget {
  const PengaturanAdminPage({super.key});

  @override
  State<PengaturanAdminPage> createState() => _PengaturanAdminPageState();
}

class _PengaturanAdminPageState extends State<PengaturanAdminPage> {
  final supabase = Supabase.instance.client;

  String nama = '-';
  String role = 'admin';
  String email = '-';
  String? fotoUrl;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfilAdmin();
  }

  Future<void> _loadProfilAdmin() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => loading = false);
        return;
      }

      final data = await supabase
          .from('profiles')
          .select('nama, role, foto')
          .eq('id', user.id)
          .maybeSingle();

      final fotoPath = data?['foto'];

      setState(() {
        nama = data?['nama'] ?? 'Admin';
        role = data?['role'] ?? 'admin';
        email = user.email ?? '-';

        // 🔗 URL FOTO DARI SUPABASE STORAGE
        fotoUrl = fotoPath != null
            ? supabase.storage.from('foto-profil').getPublicUrl(fotoPath)
            : null;

        loading = false;
      });
    } catch (e) {
      debugPrint('Error load profil admin: $e');
      setState(() => loading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    await supabase.auth.signOut();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _konfirmasiLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Logout',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun admin?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _logout(context);
            },
            child:
                Text('Logout', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Pengaturan Admin',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// FOTO PROFIL DARI SUPABASE
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue.shade700,
                        backgroundImage:
                            fotoUrl != null ? NetworkImage(fotoUrl!) : null,
                        child: fotoUrl == null
                            ? const Icon(
                                Symbols.admin_panel_settings,
                                size: 40,
                                color: Colors.white,
                              )
                            : null,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        nama,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),

                      Text(
                        role.toUpperCase(),
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.blueGrey),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        email,
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey),
                      ),

                      const SizedBox(height: 25),
                      const Divider(),

                      /// LOGOUT
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _konfirmasiLogout(context),
                          child: Text(
                            'LOGOUT',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
