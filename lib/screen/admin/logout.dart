import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application_2/screen/login.dart';

class PengaturanAdminPage extends StatelessWidget {
  const PengaturanAdminPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

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
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _logout(context);
            },
            child: Text('Logout', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: const Icon(Symbols.logout, color: Colors.red),
            title: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => _konfirmasiLogout(context),
          ),
        ],
      ),
    );
  }
}
