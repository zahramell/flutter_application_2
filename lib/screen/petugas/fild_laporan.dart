import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FieldLaporan extends StatelessWidget {
  final DateTime? tanggalMulai;
  final DateTime? tanggalAkhir;
  final String jenisLaporan;
  final VoidCallback onPickMulai;
  final VoidCallback onPickAkhir;
  final Function(String) onJenisChanged;
  final VoidCallback onSubmit;

  const FieldLaporan({
    super.key,
    required this.tanggalMulai,
    required this.tanggalAkhir,
    required this.jenisLaporan,
    required this.onPickMulai,
    required this.onPickAkhir,
    required this.onJenisChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Filter Laporan",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        _dateField("Tanggal Mulai", tanggalMulai, onPickMulai),
        const SizedBox(height: 12),
        _dateField("Tanggal Akhir", tanggalAkhir, onPickAkhir),
        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          value: jenisLaporan,
          items: const [
            DropdownMenuItem(value: 'peminjaman', child: Text("Peminjaman")),
            DropdownMenuItem(value: 'pengembalian', child: Text("Pengembalian")),
            DropdownMenuItem(value: 'denda', child: Text("Denda")),
          ],
          onChanged: (val) => onJenisChanged(val!),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Jenis Laporan",
          ),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSubmit,
            child: const Text("TAMPILKAN LAPORAN"),
          ),
        )
      ],
    );
  }

  Widget _dateField(
      String label, DateTime? value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.calendar_today),
            border: const OutlineInputBorder(),
          ),
          controller: TextEditingController(
            text: value == null
                ? ""
                : "${value.day}/${value.month}/${value.year}",
          ),
        ),
      ),
    );
  }
}
