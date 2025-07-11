import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? selectedDate;
  List<Task> allTasks = [];
  List<Task> filteredTasks = [];

  @override
  void initState() {
    super.initState();
    fetchAllTasks();
  }

  Future<void> fetchAllTasks() async {
    try {
      final tasks = await TaskService.getTasks();
      setState(() {
        allTasks = tasks;
        if (selectedDate != null) {
          filterTasksByDate();
        }
      });
    } catch (e) {
      debugPrint('Görevleri çekme hatası: $e');
    }
  }

  void filterTasksByDate() {
    setState(() {
      filteredTasks = allTasks.where((task) {
        return task.time.year == selectedDate!.year &&
            task.time.month == selectedDate!.month &&
            task.time.day == selectedDate!.day;
      }).toList();
    });
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        filterTasksByDate();
      });
    }
  }

  String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ✅ Arka Plan
        Positioned.fill(
          child: Image.asset(
            "assets/images/takvim.jpg",
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.4),
            colorBlendMode: BlendMode.darken,
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: const Color(0xff1B2A42),
            title: const Text(
              '📅 Görev Takvimi',
              style: TextStyle(color: Colors.amberAccent),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // İlham Kutusu
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xff1B2A42).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "🎯 Günlük İlham",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text("✨ Bugün bir adım at, yarın gururla hatırla.",
                              style: TextStyle(color: Colors.white70)),
                          Text("🔥 Zorluklar seni durdurmasın, seni büyütsün.",
                              style: TextStyle(color: Colors.white70)),
                          Text("💪 Rutinlerin gücüyle hedeflerine ulaş!",
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),

                    // Tarih Seç Butonu
                    ElevatedButton.icon(
                      onPressed: pickDate,
                      icon: const Icon(Icons.calendar_today, color: Colors.white),
                      label: const Text("Tarih Seç", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2D82B5),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Başlık
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xff1B2A42).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "📌 Seçilen Günün Görevleri",
                        style: TextStyle(
                          color: Colors.amberAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Liste
                    if (filteredTasks.isEmpty)
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 30),
                        child: const Text(
                          "📭 Henüz görev yok...",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      )
                    else
                      Column(
                        children: filteredTasks.map((task) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xfff4e2b5), width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Color(0xff1B2A42), size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    task.text,
                                    style: const TextStyle(color: Color(0xff333333), fontSize: 15),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff1B2A42),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    formatTime(task.time),
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
