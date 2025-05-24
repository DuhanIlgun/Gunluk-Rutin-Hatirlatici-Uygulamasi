import 'package:flutter/material.dart';
import '../services/api_service.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  List<dynamic> goals = [];
  bool isLoading = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchGoals();
  }

  void fetchGoals() async {
    try {
      final data = await ApiService.getData('goals');
      setState(() {
        goals = data;
        isLoading = false;
      });
    } catch (e) {
      print('Hata: $e');
    }
  }

  void addGoal() async {
    final newGoal = {
      "title": _titleController.text,
      "desc": _descController.text,
      "date": _dateController.text,
    };

    await ApiService.postData('goals', newGoal);
    _titleController.clear();
    _descController.clear();
    _dateController.clear();
    fetchGoals(); // yeniden listele
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hedefler')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ Form Alanı
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Hedef Başlığı'),
                  ),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Açıklama'),
                  ),
                  TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(labelText: 'Tarih (gg.aa.yyyy)'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _dateController.text =
                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: addGoal,
                    child: const Text('Ekle'),
                  ),
                ],
              ),
            ),

            // ✅ Liste Alanı
            isLoading
                ? const CircularProgressIndicator()
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              goal['title'] ?? 'Başlık Yok',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text('%${goal['percent'] ?? 0}', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(goal['desc'] ?? 'Açıklama Yok'),
                        const SizedBox(height: 6),
                        Text("Hedef Tarihi: ${goal['date'] ?? 'Yok'}"),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (goal['percent'] ?? 0) / 100,
                          backgroundColor: Colors.grey[200],
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
