import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/reminders';

  static Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception('Görevler alınamadı!');
    }
  }

  static Future<void> addTask(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Görev eklenemedi!');
    }
  }
  static Future<List<Task>> getTasksByDate(DateTime date) async {
    final allTasks = await getTasks();
    return allTasks.where((task) =>
    task.time.year == date.year &&
        task.time.month == date.month &&
        task.time.day == date.day
    ).toList();
  }

  static Future<void> deleteTask(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Görev silinemedi!');
    }
  }
}
