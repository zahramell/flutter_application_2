import 'package:flutter/material.dart';
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

      final rawFoto = data?['foto']?.toString().trim();
      String? resolvedFoto;
      if (rawFoto != null && rawFoto.isNotEmpty) {
        if (rawFoto.startsWith('http://') || rawFoto.startsWith('https://')) {
          resolvedFoto = rawFoto;
        } else {
          resolvedFoto =
              supabase.storage.from('foto-profil').getPublicUrl(rawFoto);
        }
      }

      setState(() {
        nama = data?['nama'] ?? 'Admin';
        role = data?['role'] ?? 'admin';
        email = user.email ?? '-';
        fotoUrl = resolvedFoto;

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
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun admin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _logout(context);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
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
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
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
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// FOTO PROFIL
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),

                      Text(
                        role.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 25),
                      const Divider(),

                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _konfirmasiLogout(context),
                          child: const Text(
                            'LOGOUT',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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
