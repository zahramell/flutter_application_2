import 'package:flutter/material.dart';
import 'tab_index_notifier.dart';

class LiatStatusPage extends StatelessWidget {
  const LiatStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Pesan Dikirim"),
      content: const Text(
        "Permintaan peminjaman telah dikirim ke petugas.",
      ),
      actions: [
        TextButton(
          child: const Text("Lihat Status"),
          onPressed: () {
            Navigator.pop(context);      // tutup popup
            tabIndexNotifier.value = 1;  // ⬅️ PINDAH KE AKTIVITAS
          },
        ),
      ],
    );
  }
}
