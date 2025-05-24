import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ✅ Android emulator için doğru base URL (api eklendi!)
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // ✅ Emülatör içindir


  // ✅ GET isteği
  static Future<List<dynamic>> getData(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Veri alınamadı! Hata: ${response.statusCode}');
    }
  }

  // ✅ POST isteği
  static Future<dynamic> postData(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Veri gönderilemedi! Hata: ${response.statusCode}');
    }
  }
}
