// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class TambahAlatPage extends StatefulWidget {
  final Map<String, dynamic>? alat;
  const TambahAlatPage({super.key, this.alat});

  @override
  State<TambahAlatPage> createState() => _TambahAlatPageState();
}

class _TambahAlatPageState extends State<TambahAlatPage> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;

  List<Map<String, dynamic>> _categories = [];
  XFile? _imageFile;
  String? _selectedKategoriId;
  String? _selectedStatus;
  bool _isLoading = false;

  bool get isEdit => widget.alat != null;

  @override
  void initState() {
    super.initState();
    _fetchCategories();

    _namaController =
        TextEditingController(text: widget.alat?['nama_alat'] ?? '');
    _selectedKategoriId = widget.alat?['id_kategori']?.toString();
    _selectedStatus =
        widget.alat?['status_alat'] ?? (isEdit ? null : 'Tersedia');
  }

  Future<void> _fetchCategories() async {
    final data = await _supabase.from('kategori_alat').select();
    setState(() {
      _categories = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _imageFile = pickedFile);
  }

  Future<void> _prosesSimpan() async {
    if (!_formKey.currentState!.validate() || _selectedKategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pastikan semua data terisi!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl = isEdit ? widget.alat!['gambar'] : null;

      if (_imageFile != null) {
        final fileName = 'alat_${DateTime.now().millisecondsSinceEpoch}.png';
        if (kIsWeb) {
          final bytes = await _imageFile!.readAsBytes();
          await _supabase.storage
              .from('kategori')
              .uploadBinary(fileName, bytes);
        } else {
          await _supabase.storage
              .from('kategori')
              .upload(fileName, File(_imageFile!.path));
        }
        imageUrl = _supabase.storage.from('kategori').getPublicUrl(fileName);
      }

      final dataAlat = {
        'nama_alat': _namaController.text.trim(),
        'id_kategori': int.parse(_selectedKategoriId!),
        'status_alat': _selectedStatus,
        'gambar': imageUrl ?? '',
      };

      if (isEdit) {
        await _supabase
            .from('alat')
            .update(dataAlat)
            .eq('id_alat', widget.alat!['id_alat']);
      } else {
        await _supabase.from('alat').insert(dataAlat);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? "Data berhasil diperbarui!"
                  : "Data berhasil ditambahkan!",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 35),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? "Edit Alat" : "Tambahkan Alat",
          style: GoogleFonts.poppins(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2F4157)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildImagePickerBox(),
                    const SizedBox(height: 40),
                    _buildLabel("Nama Alat"),
                    _buildInputField(_namaController, "Masukkan Nama Alat"),
                    const SizedBox(height: 15),
                    _buildLabel("Kategori"),
                    _buildDropdownKategori(),
                    const SizedBox(height: 15),
                    _buildLabel("Status"),
                    _buildDropdownStatus(),
                    const SizedBox(height: 40),
                    _buildActionButtons(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  // ================= UI COMPONENTS (TETAP) =================

  Widget _buildImagePickerBox() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: (isEdit && _imageFile == null)
                ? Colors.white
                : const Color(0xFF2F4157),
            borderRadius: BorderRadius.circular(15),
            boxShadow: (isEdit && _imageFile == null)
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5))
                  ]
                : [],
          ),
          child: _imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: kIsWeb
                      ? Image.network(_imageFile!.path, fit: BoxFit.contain)
                      : Image.file(File(_imageFile!.path), fit: BoxFit.contain),
                )
              : (isEdit && widget.alat!['gambar'] != '')
                  ? Padding(
                      padding: const EdgeInsets.all(15),
                      child: Image.network(widget.alat!['gambar'],
                          fit: BoxFit.contain),
                    )
                  : const Icon(Icons.add_photo_alternate_rounded,
                      color: Colors.white, size: 50),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(text,
          style:
              GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 13),
      validator: (value) => value!.isEmpty ? "Bidang ini wajib diisi" : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2F4157)),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDropdownKategori() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF2F4157)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedKategoriId,
          isExpanded: true,
          hint: Text("Pilih Kategori",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2F4157)),
          items: _categories
              .map((cat) => DropdownMenuItem(
                    value: cat['id_kategori'].toString(),
                    child: Text(cat['nama_kategori'],
                        style: GoogleFonts.poppins(fontSize: 13)),
                  ))
              .toList(),
          onChanged: (val) => setState(() => _selectedKategoriId = val),
        ),
      ),
    );
  }

  Widget _buildDropdownStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF2F4157)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          isExpanded: true,
          hint: Text("Pilih Status",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2F4157)),
          items: ['Tersedia', 'Dipinjam', 'Rusak']
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s, style: GoogleFonts.poppins(fontSize: 13)),
                  ))
              .toList(),
          onChanged: (val) => setState(() => _selectedStatus = val),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9D9D9),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Batal",
                style: GoogleFonts.poppins(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _prosesSimpan,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F4157),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Simpan",
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
