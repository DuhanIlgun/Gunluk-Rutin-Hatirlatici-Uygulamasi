// lib/services/letter_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class Letter {
  final String id;
  final String text;
  final String date;

  Letter({required this.id, required this.text, required this.date});

  factory Letter.fromJson(Map<String, dynamic> json) {
    return Letter(
      id: json['_id'],
      text: json['text'],
      date: json['date'],
    );
  }
}

class LetterService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/letters';


  static Future<bool> saveLetter(String text, String date, String token) async {
    final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({ 'text': text, 'date': date })
    );
    return response.statusCode == 201;
  }

  static Future<List<Letter>> getLetters(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: { 'Authorization': 'Bearer $token' },
    );
    if (response.statusCode == 200) {
      final List list = json.decode(response.body);
      return list.map((e) => Letter.fromJson(e)).toList();
    }
    return [];
  }

  static Future<bool> deleteLetter(String id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: { 'Authorization': 'Bearer $token' },
    );
    return response.statusCode == 200;
  }
}
