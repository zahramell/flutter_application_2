// ignore_for_file: use_build_context_synchronously

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
  late TextEditingController emailC;
  late TextEditingController fotoC;

  String role = 'petugas';
  bool saving = false;
  bool get isEdit => widget.data != null;

  @override
  void initState() {
    super.initState();
    namaC = TextEditingController(text: widget.data?['nama'] ?? '');
    emailC = TextEditingController(text: widget.data?['email'] ?? '');
    fotoC = TextEditingController(text: widget.data?['foto'] ?? '');
    role = (widget.data?['role'] ?? 'petugas').toLowerCase();
  }

  @override
  void dispose() {
    namaC.dispose();
    emailC.dispose();
    fotoC.dispose();
    super.dispose();
  }

  // =============================
  // SIMPAN DATA
  // =============================
  Future<void> simpan() async {
    if (namaC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama wajib diisi"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      setState(() => saving = true);

      final payload = {
        'nama': namaC.text.trim(),
        'email': emailC.text.trim(),
        'foto': fotoC.text.trim(),
        'role': role,
      };

      if (isEdit) {
        await supabase
            .from('profiles')
            .update(payload)
            .eq('id', widget.data!['id']);
      } else {
        await supabase.from('profiles').insert({
          'id': DateTime.now().millisecondsSinceEpoch
              .toString(), // ID manual supaya tidak null
          ...payload,
        });
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint("ERROR SIMPAN USER: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal menyimpan user"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  // =============================
  // STYLE INPUT
  // =============================
  InputDecoration inputStyle() => InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2F4157)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2F4157), width: 1.5),
        ),
      );

  Widget label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(text, style: GoogleFonts.poppins(fontSize: 12)),
        ),
      );

  // =============================
  // UI
  // =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: Text(
          isEdit ? "Edit User" : "Tambah User",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: 320,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ===== FOTO =====
                GestureDetector(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE7D6),
                      borderRadius: BorderRadius.circular(16),
                      image: fotoC.text.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(fotoC.text),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: fotoC.text.isEmpty
                        ? const Icon(Symbols.person, size: 48)
                        : null,
                  ),
                ),

                const SizedBox(height: 28),

                // ===== NAMA =====
                label("Nama"),
                TextField(
                  controller: namaC,
                  decoration: inputStyle(),
                ),

                const SizedBox(height: 16),

                // ===== FOTO URL =====
                label("URL Foto"),
                TextField(
                  controller: fotoC,
                  decoration: inputStyle(),
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 16),

                // ===== EMAIL =====
                label("Email"),
                TextField(
                  controller: emailC,
                  decoration: inputStyle(),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                // ===== ROLE =====
                label("Role"),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: inputStyle(),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'petugas', child: Text('Petugas')),
                    DropdownMenuItem(value: 'peminjam', child: Text('Peminjam')),
                  ],
                  onChanged: (v) => setState(() => role = v!),
                ),

                const SizedBox(height: 28),

                // ===== BUTTON =====
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          elevation: 0,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Batal",
                          style: GoogleFonts.poppins(
                              color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF2F4157),
                          elevation: 0,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: saving ? null : simpan,
                        child: saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Simpan",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
