import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screen/login.dart'; 

// Inisialisasi variabel supabase agar bisa dipanggil di file lain
final supabase = Supabase.instance.client;

void main() async {
  // Pastikan binding Flutter sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://swrzkjjdemasvqdqnyvz.supabase.co', // Masukkan URL Supabase Anda di sini
    anonKey: 'sb_publishable_UBwHp0hdeX1RS9tpkQLWJQ_ALMfzGrb', // Masukkan Anon Key Supabase Anda di sini
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Manajemen Alat',
      theme: ThemeData(
        // Menggunakan skema warna hijau agar senada dengan UI Login
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      // Menjadikan LoginPage sebagai tampilan pertama
      home: const LoginPage(), 
    );
  }
}