import 'package:flutter/material.dart';
import 'alat_servis.dart';
import 'input_alat.dart';

class BerandaScreen extends StatefulWidget {
  final String role; // Menerima role dari Login
  const BerandaScreen({super.key, required this.role});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final alatService = AlatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard ${widget.role.toUpperCase()}"),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder(
        future: alatService.getAlat(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              return ListTile(
                title: Text(data[i]['nama_alat']),
                subtitle:
                    Text("Merk: ${data[i]['merk']} - Stok: ${data[i]['stok']}"),
                // Contoh: tombol pinjam hanya untuk role peminjam
                trailing: widget.role == 'peminjam'
                    ? ElevatedButton(
                        onPressed: () {}, child: const Text("Pinjam"))
                    : null,
              );
            },
          );
        },
      ),
      // TOMBOL TAMBAH: Hanya muncul jika role adalah ADMIN
      floatingActionButton: widget.role == 'admin'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const InputAlatPage()))
                    .then((_) => setState(() {})); // Refresh data setelah input
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
