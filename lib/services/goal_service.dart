import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GoalService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/goals';

  // 🔐 Token + Header oluştur
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
  }

  // ✅ GET - Tüm hedefleri getir
  static Future<List<dynamic>> getGoals() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Hedefler alınamadı');
    }
  }

  // ✅ POST - Yeni hedef ekle
  static Future<dynamic> addGoal(Map<String, dynamic> goal) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(goal),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Hedef eklenemedi');
    }
  }

  // ✅ DELETE - Hedefi sil
  static Future<void> deleteGoal(String id) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.delete(url, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Hedef silinemedi');
    }
  }

  // ✅ PATCH - Hedefi güncelle (tamamla, düzenle vb.)
  static Future<void> updateGoal(String id, Map<String, dynamic> updatedData) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.patch(
      url,
      headers: headers,
      body: jsonEncode(updatedData),
    );
    if (response.statusCode != 200) {
      throw Exception('Hedef güncellenemedi');
    }
  }
}
