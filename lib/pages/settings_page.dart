import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool notificationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final localSetting = prefs.getBool("reminderNotifs");
    final backendSetting = await SettingsService.getEmailNotificationsFromBackend();

    setState(() {
      notificationEnabled = backendSetting ?? localSetting ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("reminderNotifs", notificationEnabled);
    await SettingsService.updateEmailNotifications(notificationEnabled);

    final newPassword = _passwordController.text.trim();
    bool result = true;

    if (newPassword.isNotEmpty) {
      final oldPasswordController = TextEditingController();
      final oldConfirmed = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Mevcut Şifrenizi Girin"),
          content: TextField(
            controller: oldPasswordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: "Mevcut şifreniz"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, null), child: const Text("İptal")),
            TextButton(
              onPressed: () => Navigator.pop(context, oldPasswordController.text.trim()),
              child: const Text("Onayla"),
            ),
          ],
        ),
      );

      if (oldConfirmed != null && oldConfirmed.isNotEmpty) {
        result = await SettingsService.updatePassword(oldConfirmed, newPassword);
      } else {
        result = false;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result ? "Ayarlar kaydedildi." : "Ayarlar kaydedilemedi."),
      ),
    );

    if (result) _passwordController.clear();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hesabı Sil"),
        content: const Text("Hesabınızı silmek istediğinizden emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("İptal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Sil")),
        ],
      ),
    );

    if (confirm == true) {
      final result = await SettingsService.deleteAccount();
      if (result && mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove("token");
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hesap silinemedi.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "assets/images/ayarlar.jpg",
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
        ),
        Container(
          color: Colors.black.withOpacity(0.4),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("⚙️ Ayarlar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Yeni Şifre (isteğe bağlı)",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: notificationEnabled,
                    onChanged: (val) {
                      setState(() {
                        notificationEnabled = val ?? true;
                      });
                    },
                    title: const Text("🔔 Bildirimleri Aç", style: TextStyle(color: Colors.white)),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Colors.greenAccent,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Kaydet"),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                    child: const Text("Çıkış Yap"),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _deleteAccount,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Hesabı Sil"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
