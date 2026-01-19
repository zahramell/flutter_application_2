import 'package:flutter/material.dart';
import 'model.dart'; 
import 'servis.dart'; // File DatabaseService kamu

class DaftarAlatScreen extends StatelessWidget {
  // Samakan nama kelas dengan yang ada di servis.dart
  final DatabaseService _dbService = DatabaseService();

  DaftarAlatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Alat'),
        elevation: 2,
      ),
      body: FutureBuilder<List<AlatModel>>(
        // Gunakan instance _dbService yang memanggil fetchAlat()
        future: _dbService.fetchAlat(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi Error: ${snapshot.error}'),
            );
          }

          // 3. Empty State
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Tidak ada alat tersedia.'),
            );
          }

          // 4. Success State
          final listAlat = snapshot.data!;
          return ListView.builder(
            itemCount: listAlat.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final alat = listAlat[index];
              return Card(
                child: ListTile(
                  title: Text(
                    alat.namaAlat, 
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  subtitle: Text('Status: ${alat.statusAlat}'),
                  leading: const CircleAvatar(
                    child: Icon(Icons.inventory),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}