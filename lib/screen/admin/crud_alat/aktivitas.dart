import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AktivitasPage extends StatefulWidget {
  const AktivitasPage({super.key});

  @override
  State<AktivitasPage> createState() => _AktivitasPageState();
}

class _AktivitasPageState extends State<AktivitasPage> {
  final supabase = Supabase.instance.client;

  // ambil data aktivitas
  Future<List<Map<String, dynamic>>> getAktivitas() async {
    final response = await supabase
        .from('aktivitas')
        .select()
        .order('created_at', ascending: false);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            /// SEARCH BAR
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Pencarian",
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                    icon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// JUDUL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                "Hari ini",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// LIST AKTIVITAS
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getAktivitas(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("Tidak ada aktivitas hari ini"),
                    );
                  }

                  final listAktivitas = snapshot.data!;

                  return ListView.builder(
                    itemCount: listAktivitas.length,
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: MediaQuery.of(context).padding.bottom + 20,
                    ),
                    itemBuilder: (context, index) {
                      final item = listAktivitas[index];

                      final DateTime createdAt =
                          DateTime.parse(item['created_at']).toLocal();

                      final String jam =
                          createdAt.hour.toString().padLeft(2, '0');
                      final String menit =
                          createdAt.minute.toString().padLeft(2, '0');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              item['tipe'] == 'pinjam'
                                  ? Icons.check_circle_outline
                                  : Icons.delete_outline,
                              size: 35,
                              color: const Color(0xFF2F4157),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['judul'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['deskripsi'],
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      "($jam:$menit WIB)",
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
