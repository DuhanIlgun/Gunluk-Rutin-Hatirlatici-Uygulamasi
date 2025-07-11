import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/motivation_service.dart';
import '../services/letter_service.dart';

class MotivationPage extends StatefulWidget {
  const MotivationPage({super.key});

  @override
  State<MotivationPage> createState() => _MotivationPageState();
}

class _MotivationPageState extends State<MotivationPage> {
  String dailyMessage = 'Motivasyon mesajı için butona bas.';
  String moodMessage = '';
  double moodValue = 1;

  List<String> history = [];
  List<Letter> letters = [];
  TextEditingController letterController = TextEditingController();

  String token = '';
  String date = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    final now = DateTime.now();
    date = "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}";

    _fetchHistory();
    _fetchLetters();
  }

  Future<void> _fetchDailyMessage() async {
    final text = await MotivationService.getDailyMotivation(token);
    if (text != null) {
      setState(() {
        dailyMessage = text;
      });
      _fetchHistory();
    }
  }

  Future<void> _fetchMoodMessage() async {
    final moods = ['sad', 'neutral', 'happy'];
    final text = await MotivationService.getMoodMotivation(moods[moodValue.toInt()], token);
    if (text != null) {
      setState(() => moodMessage = text);
    }
  }

  Future<void> _fetchHistory() async {
    final list = await MotivationService.getMotivationHistory(token);
    setState(() => history = list);
  }

  Future<void> _fetchLetters() async {
    final list = await LetterService.getLetters(token);
    setState(() => letters = list);
  }

  Future<void> _saveLetter() async {
    final text = letterController.text.trim();
    if (text.isEmpty) return;
    final success = await LetterService.saveLetter(text, date, token);
    if (success) {
      letterController.clear();
      _fetchLetters();
    }
  }

  Future<void> _deleteLetter(String id) async {
    final success = await LetterService.deleteLetter(id, token);
    if (success) _fetchLetters();
  }

  Widget _buildCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  String _moodEmoji(double val) {
    switch (val.toInt()) {
      case 0:
        return '😢';
      case 1:
        return '😐';
      case 2:
        return '😄';
      default:
        return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('🎯 RutinApp'),
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/motivasyon.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCard(
                icon: Icons.bolt,
                title: 'Bugünün Motivasyon Sözü',
                child: Column(
                  children: [
                    Text(
                      dailyMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _fetchDailyMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF002b5b),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('🎯 Sözü Çek'),
                    ),
                  ],
                ),
              ),
              _buildCard(
                icon: Icons.emoji_emotions,
                title: 'Ruh Haline Göre Mesaj',
                child: Column(
                  children: [
                    Text('Ruh Halini Seç: ${_moodEmoji(moodValue)}', style: const TextStyle(color: Colors.white70)),
                    Slider(
                      value: moodValue,
                      min: 0,
                      max: 2,
                      divisions: 2,
                      onChanged: (value) => setState(() => moodValue = value),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('😢 Üzgün'), Text('😐 Normal'), Text('😄 Mutlu')],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _fetchMoodMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF002b5b),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('🌀 Getir'),
                    ),
                    const SizedBox(height: 8),
                    Text(moodMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              if (history.isNotEmpty)
                _buildCard(
                  icon: Icons.history,
                  title: '🗓️ Önceki Günlerin Sözleri',
                  child: SizedBox(
                    height: 220,
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        return Text("📄 ${history[index]}", style: const TextStyle(color: Colors.white));
                      },
                    ),
                  ),
                ),
              _buildCard(
                icon: Icons.mail,
                title: '📬 Kendine Mektup Yaz',
                child: Column(
                  children: [
                    TextField(
                      controller: letterController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Bugünkü duygularını yaz...',
                        hintStyle: const TextStyle(color: Colors.white60),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        fillColor: Colors.white10,
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _saveLetter,
                      child: const Text('Kaydet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF002b5b),
                      ),
                    ),
                  ],
                ),
              ),
              if (letters.isNotEmpty)
                _buildCard(
                  icon: Icons.mark_email_read_outlined,
                  title: '📬 Önceki Günlerin Mektupları',
                  child: Column(
                    children: letters.map((letter) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("📅 ${letter.date}", style: const TextStyle(color: Colors.white70)),
                          Text("✉️ ${letter.text}", style: const TextStyle(color: Colors.white)),
                          TextButton(
                            onPressed: () => _deleteLetter(letter.id),
                            style: TextButton.styleFrom(foregroundColor: Colors.pink[200]),
                            child: const Text("Sil"),
                          ),
                          const Divider(color: Colors.white24),
                        ],
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}