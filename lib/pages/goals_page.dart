import 'package:flutter/material.dart';
import '../services/goal_service.dart';

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
      final data = await GoalService.getGoals();
      setState(() {
        goals = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Hata: $e');
    }
  }

  void addGoal() async {
    final newGoal = {
      "title": _titleController.text,
      "desc": _descController.text,
      "date": _dateController.text,
    };
    await GoalService.addGoal(newGoal);
    _titleController.clear();
    _descController.clear();
    _dateController.clear();
    fetchGoals();
  }

  void deleteGoal(String id) async {
    await GoalService.deleteGoal(id);
    fetchGoals();
  }

  void toggleComplete(String id, bool current) async {
    await GoalService.updateGoal(id, {
      'completed': !current,
      'percent': !current ? 100 : 0,
    });
    fetchGoals();
  }

  void editGoal(String id, String currentTitle, String currentDesc, String currentDate) {
    final titleCtrl = TextEditingController(text: currentTitle);
    final descCtrl = TextEditingController(text: currentDesc);
    final dateCtrl = TextEditingController(text: currentDate);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('🎯 Hedefi Düzenle', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              TextField(
                controller: dateCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Tarih',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    dateCtrl.text =
                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              await GoalService.updateGoal(id, {
                'title': titleCtrl.text,
                'desc': descCtrl.text,
                'date': dateCtrl.text,
              });
              Navigator.pop(context);
              fetchGoals();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/hedefler.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              const Text(
                '🎯 Hedefler',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Hedef Başlığı',
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                      ),
                      TextField(
                        controller: _descController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Açıklama',
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                      ),
                      TextField(
                        controller: _dateController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Tarih (gg.aa.yyyy)',
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            _dateController.text =
                            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: addGoal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5c6bc0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Ekle', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
              isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final completed = goal['completed'] ?? false;

                  return Card(
                    color: Colors.black.withOpacity(0.85),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(goal['title'] ?? 'Başlık Yok',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 6),
                          Text(goal['desc'] ?? 'Açıklama Yok', style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 6),
                          Text("Tarih: ${goal['date'] ?? 'Yok'}", style: const TextStyle(color: Colors.white60)),
                          const SizedBox(height: 6),
                          Text("${goal['percent']}% tamamlandı", style: const TextStyle(color: Colors.white54)),
                          Slider(
                            activeColor: const Color(0xFF4c84ff), // Webdeki mavi tonu
                            value: (goal['percent'] ?? 0).toDouble(),
                            min: 0,
                            max: 100,
                            divisions: 20,
                            label: "${goal['percent']}%",
                            onChanged: (value) async {
                              await GoalService.updateGoal(goal['_id'], {
                                'percent': value.round(),
                                'completed': value == 100,
                              });
                              fetchGoals();
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () => toggleComplete(goal['_id'], completed),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber[100],
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(completed ? 'Geri Al' : 'Tamamla', style: const TextStyle(color: Colors.black)),
                              ),
                              ElevatedButton(
                                onPressed: () => editGoal(goal['_id'], goal['title'], goal['desc'], goal['date']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Düzenle', style: TextStyle(color: Colors.white)),
                              ),
                              ElevatedButton(
                                onPressed: () => deleteGoal(goal['_id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFe84393), // Webdeki pembe
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Sil', style: TextStyle(color: Colors.white)),
                              ),
                            ],
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
      ),
    );
  }
}
