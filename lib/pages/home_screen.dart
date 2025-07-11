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
  final TextEditingController searchController = TextEditingController();
  DateTime? selectedDate;
  List<Task> tasks = [];
  String searchQuery = '';

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
    if (taskController.text.isEmpty || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun.")),
      );
      return;
    }

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
    // filtreli görev listesi
    final filteredTasks = tasks.where((task) {
      return task.text.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "📌 Bugünkü Rutinini Yönet",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // 🔍 Görev Ara
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Görev ara...",
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.4),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 12),

                // 📝 Görev Girişi
                TextField(
                  controller: taskController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Görev: kitap oku, spor yap...",
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.task_alt, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.4),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedDate == null
                            ? "📅 Lütfen tarih/saat seçin"
                            : "📅 ${selectedDate.toString()}",
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: pickDateTime,
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: const Text("Tarih Seç"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B2A42),
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
                    backgroundColor: const Color(0xFF1B2A42),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "📝 Görev Listesi",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filteredTasks.isEmpty
                      ? const Center(
                    child: Text(
                      "Henüz görev eklenmedi.",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  )
                      : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return Card(
                        color: Colors.black.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.check_circle_outline, color: Colors.white),
                          title: Text(task.text, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(task.time.toString(),
                              style: const TextStyle(color: Colors.white70)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
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
        ),
      ),
    );
  }
}
