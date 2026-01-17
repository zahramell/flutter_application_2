import 'package:flutter/material.dart';
import 'servis.dart';
import 'model.dart';

class DaftarAlatScreen extends StatelessWidget {
  const DaftarAlatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Alat')),
      body: FutureBuilder<List<AlatModel>>(
        future: DatabaseService().fetchAlat(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(data[i].namaAlat),
              subtitle: Text(data[i].statusAlat),
              leading: const Icon(Icons.build),
            ),
          );
        },
      ),
    );
  }
}