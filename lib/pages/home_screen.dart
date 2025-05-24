import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController taskController = TextEditingController();
  DateTime? selectedDate;
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      final fetchedTasks = await TaskService.getTasks();
      setState(() {
        tasks = fetchedTasks;
      });
    } catch (e) {
      debugPrint('Görevleri alma hatası: $e');
    }
  }

  Future<void> addTask() async {
    if (taskController.text.isEmpty || selectedDate == null) return;

    final newTask = Task(
      text: taskController.text.trim(),
      time: selectedDate!,
    );

    try {
      await TaskService.addTask(newTask);
      taskController.clear();
      selectedDate = null;
      fetchTasks();
    } catch (e) {
      debugPrint('Görev ekleme hatası: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await TaskService.deleteTask(id);
      fetchTasks();
    } catch (e) {
      debugPrint('Görev silme hatası: $e');
    }
  }

  Future<void> pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text('📌 Bugünkü Rutinini Yönet'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                labelText: "Görev: kitap oku, spor yap...",
                prefixIcon: const Icon(Icons.task_alt),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? "📅 Tarih/Saat seçilmedi"
                        : "📅 ${selectedDate.toString()}",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: pickDateTime,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("Tarih Seç"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: addTask,
              icon: const Icon(Icons.add),
              label: const Text("Ekle"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("📝 Görev Listesi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                child: Text(
                  "Henüz görev eklenmedi.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.check_circle_outline, color: Colors.indigo),
                      title: Text(task.text),
                      subtitle: Text(task.time.toString()),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteTask(task.id!),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
