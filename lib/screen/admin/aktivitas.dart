import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogAktivitasAdminPage extends StatefulWidget {
  const LogAktivitasAdminPage({super.key});

  @override
  State<LogAktivitasAdminPage> createState() => _LogAktivitasAdminPageState();
}

class _LogAktivitasAdminPageState extends State<LogAktivitasAdminPage> {
  final supabase = Supabase.instance.client;

  // ================= FETCH LOG =================
  Future<List<Map<String, dynamic>>> fetchLog() async {
    final res = await supabase
        .from('log_aktivitas')
        .select('''
          id_log,
          aktivitas,
          waktu,
          profiles (
            nama,
            role
          )
        ''')
        .order('waktu', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  // ================= FORMAT WAKTU =================
  String formatWaktu(String waktu) {
    final dt = DateTime.parse(waktu);
    return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute}";
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Log Aktivitas"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchLog(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "Tidak ada aktivitas",
                style: GoogleFonts.poppins(),
              ),
            );
          }

          final data = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final log = data[index];
              final profil = log['profiles'];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profil['nama'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "Role : ${profil['role']}",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      log['aktivitas'],
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatWaktu(log['waktu']),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
