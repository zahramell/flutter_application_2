import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogAktivitasPage extends StatefulWidget {
  const LogAktivitasPage({super.key});

  @override
  State<LogAktivitasPage> createState() => _LogAktivitasPageState();
}

class _LogAktivitasPageState extends State<LogAktivitasPage> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchLog() async {
    final res = await supabase.from('log_aktivitas').select('''
          aktivitas,
          waktu,
          profiles!log_aktivitas_id_pengguna_fkey ( nama )
        ''').order('waktu', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Log Aktivitas")),
      body: FutureBuilder(
        future: fetchLog(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data as List;

          if (data.isEmpty) {
            return const Center(child: Text("Tidak ada aktivitas"));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              final d = data[i];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(
                  d['aktivitas'],
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                subtitle: Text(
                  d['profiles']['nama'],
                  style: GoogleFonts.poppins(fontSize: 11),
                ),
                trailing: Text(
                  d['waktu'].toString(),
                  style: GoogleFonts.poppins(fontSize: 10),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
