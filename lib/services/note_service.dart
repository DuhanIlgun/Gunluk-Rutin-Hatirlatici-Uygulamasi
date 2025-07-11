import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';

class NoteService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/notes';
  // Android emülatör için

  static Future<List<Note>> fetchNotes(String token) async {
    final res = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) {
      final List jsonData = jsonDecode(res.body);
      return jsonData.map((item) => Note.fromJson(item)).toList();
    } else {
      throw Exception('Notlar alınamadı');
    }
  }

  static Future<void> addNote(Note note, String token) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(note.toJson()),
    );
    if (res.statusCode != 201) {
      throw Exception('Not eklenemedi');
    }
  }

  static Future<void> deleteNote(String id, String token) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode != 200) {
      throw Exception('Silinemedi');
    }
  }
}
