import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  Future<void> sendResetEmail() async {
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:5000/api/users/forgot-password"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": emailController.text.trim()}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Şifre sıfırlama bağlantısı gönderildi.")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? "Bir hata oluştu")),
        );
      }
    } catch (e) {
      print("❌ Hata: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sunucuya bağlanılamadı.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Şifremi Unuttum")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("E-posta adresinizi girin, size bir bağlantı gönderelim.",
                style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "E-Posta"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: sendResetEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text("Bağlantı Gönder"),
            ),
          ],
        ),
      ),
    );
  }
}
