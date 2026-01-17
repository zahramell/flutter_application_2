import 'package:flutter/material.dart';

import 'main.dart'; // Memastikan variabel 'supabase' bisa diakses

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;
  String message = "";
  bool isError = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    setState(() {
      loading = true;
      message = "";
    });

    try {
      // 1. Proses Sign In ke Supabase Auth
      final res = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (res.user == null) throw 'Login gagal';

      // 2. Ambil data role dari tabel 'profiles' dan kolom 'id' (Sesuai ERD Anda)
      final userData = await supabase
          .from('profiles')
          .select('role')
          .eq('id', res.user!.id)
          .single();

      String role = userData['role'].toString().toLowerCase();

      if (!mounted) return;

      // 3. Set pesan sukses
      setState(() {
        message = "Sandi Benar! Masuk sebagai $role";
        isError = false;
      });

      // Delay sedikit agar user bisa melihat pesan sukses
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      // 4. Navigasi Berdasarkan Role
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text("Halaman Dashboard Admin")),
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text("Halaman Dashboard Petugas")),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        message = "Email atau Kata Sandi Salah!";
        isError = true;
        loading = false;
      });
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon Utama
              const Icon(
                Icons.inventory_2_outlined,
                size: 100,
                color: Color(0xFF0BB44F),
              ),
              const SizedBox(height: 10),

              const Text(
                "Masuk System",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Field Email
              _buildField("Email", emailController, false),
              const SizedBox(height: 20),

              // Field Password
              _buildField("Kata Sandi", passwordController, true),
              const SizedBox(height: 40),

              // Tombol Login
              SizedBox(
                width: 279,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0BB44F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Masuk Sekarang',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              // Notifikasi Pesan Error/Sukses
              if (message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isError ? Colors.red : const Color(0xFF0BB44F),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pendukung untuk Text Field
  Widget _buildField(
      String hint, TextEditingController controller, bool isPass) {
    return SizedBox(
      width: 279,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Masukan $hint"),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: isPass ? obscurePassword : false,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              suffixIcon: isPass
                  ? IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF0BB44F),
                      ),
                      onPressed: () =>
                          setState(() => obscurePassword = !obscurePassword),
                    )
                  : null,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF0BB44F)),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFF0BB44F), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
