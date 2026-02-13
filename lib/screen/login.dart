import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'peminjaman/navbar.dart'; // Halaman Peminjam
import 'admin/navbar.dart'; // Halaman Admin
import 'petugas/navbar.dart'; // Halaman Petugas (Pastikan file ini ada)

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  String message = "";
  bool _obscureText = true;
  bool isSuccess = false;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
      message = "";
      isSuccess = false;
    });

    try {
      // 1. Proses Login ke Supabase
      final res = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 2. Ambil data role dari tabel profiles
      final userData = await supabase
          .from('profiles')
          .select('role')
          .eq('id', res.user!.id)
          .single();

      // Memastikan role dibaca sebagai huruf kecil agar tidak salah banding
      String role = userData['role'].toString().toLowerCase().trim();

      setState(() {
        isSuccess = true;
        message = "Berhasil! Masuk sebagai $role";
      });

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      // 3. LOGIKA NAVIGASI 3 ROLE
      if (role == 'admin') {
        // Jika Admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationAdmin()),
        );
      } else if (role == 'petugas') {
        // Jika Petugas
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationPetugas()),
        );
      } else {
        // Jika Peminjam / Siswa (Default)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } on AuthException {
      setState(() {
        isSuccess = false;
        message = "Email atau Sandi salah!";
      });
    } catch (e) {
      setState(() {
        isSuccess = false;
        message = "Terjadi kesalahan koneksi.";
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // Background Biru Muda
          Container(
            height: screenHeight * 0.4,
            color: const Color(0xFFC7D9E5),
          ),
          Positioned(
            top: -(screenHeight * 0.15),
            left: -(screenWidth * 0.2),
            right: -(screenWidth * 0.2),
            child: Container(
              height: screenHeight * 0.65,
              decoration: const BoxDecoration(
                color: Color(0xFFC7D9E5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Kotak Login Biru Tua
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F4157),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Masuk",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFFFFF),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildLabel("Masukan Email"),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 14),
                            decoration: _inputDecoration("Email"),
                            validator: (value) => value == null || value.isEmpty
                                ? "Email tidak boleh kosong"
                                : null,
                          ),
                          const SizedBox(height: 15),
                          _buildLabel("Masukan Kata Sandi"),
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscureText,
                            style: const TextStyle(fontSize: 14),
                            decoration: _inputDecoration("Kata Sandi").copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 20,
                                    color: const Color(0xFF999999)),
                                onPressed: () => setState(
                                    () => _obscureText = !_obscureText),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? "Sandi tidak boleh kosong"
                                : null,
                          ),
                          const SizedBox(height: 35),
                          SizedBox(
                            width: 180,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: loading ? null : login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC7D9E5),
                                foregroundColor: const Color(0xFF2F4157),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              child: loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF2F4157)))
                                  : const Text("Masuk",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (message.isNotEmpty)
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: isSuccess ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(text,
          style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 13)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFFFFFFF),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
  }
}