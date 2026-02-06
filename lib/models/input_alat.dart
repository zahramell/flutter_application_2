// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class InputAlatPage extends StatefulWidget {
  const InputAlatPage({super.key});

  @override
  State<InputAlatPage> createState() => _InputAlatPageState();
}

class _InputAlatPageState extends State<InputAlatPage> {
  final _namaController = TextEditingController();
  final _statusController = TextEditingController(text: 'Tersedia');
  final _supabaseService = SupabaseService();
  bool _isLoading = false;

  Future<void> _simpanAlat() async {
    if (_namaController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      // PERBAIKAN: Tambahkan satu argumen lagi di paling akhir (contoh: '')
      // agar pas menjadi 4 argumen sesuai yang diminta SupabaseService
      await _supabaseService.tambahAlat(
          _namaController.text,
          1,
          _statusController.text,
          '' // <--- Ini argumen ke-4 (URL Gambar) yang tadi hilang
          );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Input Alat"), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: "Nama Alat")),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _simpanAlat, child: const Text("Simpan")),
          ],
        ),
      ),
    );
  }
}
