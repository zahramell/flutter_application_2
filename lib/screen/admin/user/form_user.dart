import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';

class FormUserPage extends StatefulWidget {
  final Map<String, dynamic>? data;
  const FormUserPage({super.key, this.data});

  @override
  State<FormUserPage> createState() => _FormUserPageState();
}

class _FormUserPageState extends State<FormUserPage> {
  final supabase = Supabase.instance.client;

  late TextEditingController namaC;
  late TextEditingController fotoC;
  String role = 'peminjam';

  bool get isEdit => widget.data != null;

  @override
  void initState() {
    super.initState();
    namaC = TextEditingController(text: widget.data?['nama'] ?? '');
    fotoC = TextEditingController(text: widget.data?['foto'] ?? '');
    role = widget.data?['role'] ?? 'peminjam';
  }

  Future<void> simpan() async {
    final payload = {
      'nama': namaC.text,
      'foto': fotoC.text,
      'role': role,
    };

    if (isEdit) {
      await supabase
          .from('profiles')
          .update(payload)
          .eq('id', widget.data!['id']);
    } else {
      await supabase.from('profiles').insert(payload);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit User" : "Tambah User",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage:
                  fotoC.text.isNotEmpty ? NetworkImage(fotoC.text) : null,
              child: fotoC.text.isEmpty
                  ? const Icon(Symbols.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: namaC,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                labelText: "Nama",
                labelStyle: GoogleFonts.poppins(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fotoC,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                labelText: "URL Foto (opsional)",
                labelStyle: GoogleFonts.poppins(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: role,
              decoration: InputDecoration(
                labelText: "Role",
                labelStyle: GoogleFonts.poppins(),
              ),
              items: const [
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'petugas', child: Text('Petugas')),
                DropdownMenuItem(value: 'peminjam', child: Text('Peminjam')),
              ],
              onChanged: (val) => setState(() => role = val!),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Batal", style: GoogleFonts.poppins()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: simpan,
                    child: Text("Simpan", style: GoogleFonts.poppins()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
