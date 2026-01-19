import 'package:flutter/material.dart';
import 'alat_servis.dart'; // Menghubungkan ke service alat

class InputAlatPage extends StatefulWidget {
  const InputAlatPage({super.key});
  @override
  State<InputAlatPage> createState() => _InputAlatPageState();
}

class _InputAlatPageState extends State<InputAlatPage> {
  final _formKey = GlobalKey<FormState>();
  final alatService = AlatService();

  final _nama = TextEditingController();
  final _merk = TextEditingController();
  final _spek = TextEditingController();
  final _stok = TextEditingController();

  void _simpan() async {
    if (_formKey.currentState!.validate()) {
      try {
        await alatService.tambahAlat(_nama.text, _merk.text, _spek.text,
            int.parse(_stok.text), 1 // ID Kategori default (misal Mouse)
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Data Berhasil Disimpan!")));
          Navigator.pop(context); // Kembali ke beranda
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Gagal Simpan: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Alat Baru")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                  controller: _nama,
                  decoration: const InputDecoration(labelText: "Nama Mouse"),
                  validator: (v) => v!.isEmpty ? "Wajib isi" : null),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _merk,
                  decoration: const InputDecoration(labelText: "Merk"),
                  validator: (v) => v!.isEmpty ? "Wajib isi" : null),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _spek,
                  decoration: const InputDecoration(labelText: "Spesifikasi")),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _stok,
                  decoration: const InputDecoration(labelText: "Jumlah Stok"),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? "Wajib isi" : null),
              const SizedBox(height: 30),
              ElevatedButton(
                  onPressed: _simpan, child: const Text("SIMPAN DATA")),
            ],
          ),
        ),
      ),
    );
  }
}
