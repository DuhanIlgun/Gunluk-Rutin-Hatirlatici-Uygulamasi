// lib/services/motivation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class MotivationService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/motivation';


  static Future<String?> getDailyMotivation(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/daily'),
      headers: { 'Authorization': 'Bearer $token' },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['text'];
    }
    return null;
  }

  static Future<String?> getMoodMotivation(String moodLevel, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mood?level=$moodLevel'),
      headers: { 'Authorization': 'Bearer $token' },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['text'];
    }
    return null;
  }

  static Future<List<String>> getMotivationHistory(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/history'),
      headers: { 'Authorization': 'Bearer $token' },
    );
    if (response.statusCode == 200) {
      final List list = json.decode(response.body);
      return list.map((item) => item['text'].toString()).toList();
    }
    return [];
  }
}
