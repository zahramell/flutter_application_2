import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AktivitasAdminPage extends StatefulWidget {
  const AktivitasAdminPage({super.key});

  @override
  State<AktivitasAdminPage> createState() => _AktivitasAdminPageState();
}

class _AktivitasAdminPageState extends State<AktivitasAdminPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _loading = true;
  List<Map<String, dynamic>> _aktivitasList = [];

  @override
  void initState() {
    super.initState();
    _ambilAktivitas();
  }

  Future<void> _ambilAktivitas() async {
    try {
      final response = await _supabase
          .from('log_aktivitas')
          .select()
          .order('waktu', ascending: false);

      setState(() {
        _aktivitasList = List<Map<String, dynamic>>.from(response);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aktivitas',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _aktivitasList.isEmpty
              ? Center(
                  child: Text(
                    'Belum ada aktivitas',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _aktivitasList.length,
                  itemBuilder: (context, index) {
                    final data = _aktivitasList[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Symbols.history_rounded,
                          color: Color(0xFF2F4157),
                        ),
                        title: Text(
                          data['aktivitas'] ?? '-',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          data['waktu']?.toString() ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
