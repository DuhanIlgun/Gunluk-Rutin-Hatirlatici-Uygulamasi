import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // 🔐 Şifre güncelleme
  static Future<bool> updatePassword(String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('http://10.0.2.2:5000/api/update-password');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    print("Şifre Güncelleme - Status Code: ${response.statusCode}");
    print("Şifre Güncelleme - Body: ${response.body}");

    return response.statusCode == 200;
  }

  // 🔔 Bildirim ayarını local'e kaydet
  static Future<void> saveNotificationSetting(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("reminderNotifs", enabled);
  }

  // 🔁 Backend'e bildirim ayarını gönder
  static Future<bool> updateEmailNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('http://10.0.2.2:5000/api/users/update-notifications');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'enabled': enabled}),
    );

    print("Bildirim Ayarı Güncelleme - Status: ${response.statusCode}");
    return response.statusCode == 200;
  }

  // 🔁 Backend'den bildirimi çek
  static Future<bool?> getEmailNotificationsFromBackend() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('http://10.0.2.2:5000/api/users/get-notifications');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['enabled'] as bool;
    } else {
      print("Bildirim Ayarı Getirme Hatası: ${response.statusCode}");
      return null;
    }
  }

  // 🧨 Hesabı sil
  static Future<bool> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('http://10.0.2.2:5000/api/delete-account');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print("Hesap Silme - Status Code: ${response.statusCode}");
    print("Hesap Silme - Body: ${response.body}");

    return response.statusCode == 200;
  }
}
