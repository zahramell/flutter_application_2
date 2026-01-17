import 'package:flutter/material.dart';
import 'model.dart'; // Import agar kenal AlatModel
import 'servis.dart'; // Import agar kenal AlatService

class DaftarAlatScreen extends StatelessWidget {
  final AlatService _alatService = AlatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Alat')),
      body: FutureBuilder<List<AlatModel>>(
        future: _alatService.fetchAlat(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada alat tersedia.'));
          }

          final listAlat = snapshot.data!;
          return ListView.builder(
            itemCount: listAlat.length,
            itemBuilder: (context, index) {
              final alat = listAlat[index];
              return ListTile(
                title: Text(alat.namaAlat), // Sesuai model
                subtitle: Text('Status: ${alat.statusAlat}'),
                leading: const Icon(Icons.inventory),
              );
            },
          );
        },
      ),
    );
  }
}
