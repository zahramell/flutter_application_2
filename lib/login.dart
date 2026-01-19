import 'package:flutter/material.dart';
import 'main.dart';
import 'beranda.dart'; // Import beranda agar bisa navigasi

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  String message = "";

  Future<void> login() async {
    setState(() {
      loading = true;
      message = "";
    });

    try {
      final res = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Ambil role dari tabel profiles
      final userData = await supabase
          .from('profiles')
          .select('role')
          .eq('id', res.user!.id)
          .single();

      String role = userData['role'].toString().toLowerCase();

      if (!mounted) return;

      // NAVIGASI BERDASARKAN ROLE
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BerandaScreen(role: role)),
      );
    } catch (e) {
      setState(() {
        message = "Email atau Sandi Salah!";
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Login System",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email")),
            TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Sandi")),
            const SizedBox(height: 30),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: login, child: const Text("Masuk")),
            Text(message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
