import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<Note> _notes = [];
  String? _token;

  final List<Color> cardColors = [
    Color(0xFF2c2c54),
    Color(0xFF30336b),
    Color(0xFF2f3640),
    Color(0xFF3d3d3d),
    Color(0xFF4b4b4b),
    Color(0xFF37474F),
    Color(0xFF263238),
  ];

  final List<Color> deleteBtnColors = [
    Color(0xFFe74c3c),
    Color(0xFFc0392b),
    Color(0xFFd35400),
    Color(0xFFe67e22),
    Color(0xFF8e44ad),
    Color(0xFF16a085),
    Color(0xFF2c3e50),
    Color(0xFF6c5ce7),
  ];

  final _cardColorMap = <String, Color>{};
  final _btnColorMap = <String, Color>{};
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _loadTokenAndNotes();
  }

  Future<void> _loadTokenAndNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      try {
        final notes = await NoteService.fetchNotes(token);
        setState(() {
          _token = token;
          _notes = notes;
        });
      } catch (e) {
        print('Notlar alınamadı: $e');
      }
    }
  }

  Future<void> _addNote() async {
    if (_titleController.text.isEmpty || _textController.text.isEmpty || _token == null) return;

    final newNote = Note(
      id: '',
      title: _titleController.text,
      text: _textController.text,
      date: _selectedDate,
      color: '#000000',
    );

    try {
      await NoteService.addNote(newNote, _token!);
      _titleController.clear();
      _textController.clear();
      _loadTokenAndNotes();
    } catch (e) {
      print('Not eklenemedi: $e');
    }
  }

  Future<void> _deleteNote(String id) async {
    try {
      await NoteService.deleteNote(id, _token!);
      _cardColorMap.remove(id);
      _btnColorMap.remove(id);
      _loadTokenAndNotes();
    } catch (e) {
      print('Silme hatası: $e');
    }
  }

  String formatDate(DateTime date) =>
      "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";

  Color _getCardColor(String id) =>
      _cardColorMap.putIfAbsent(id, () => cardColors[_random.nextInt(cardColors.length)]);
  Color _getBtnColor(String id) =>
      _btnColorMap.putIfAbsent(id, () => deleteBtnColors[_random.nextInt(deleteBtnColors.length)]);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "assets/images/notlar.jpg",
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Scaffold(
          backgroundColor: Colors.black.withOpacity(0.5),
          appBar: AppBar(
            backgroundColor: Colors.black87,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              "📝 Notlarım",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Not ekleme formu
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF5c6bc0), width: 2),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text("🖋️ Yeni Not Ekle",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Başlık',
                          hintStyle: const TextStyle(color: Colors.white60),
                          filled: true,
                          fillColor: Colors.black54,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _textController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Bugün neler yaptın?',
                          hintStyle: const TextStyle(color: Colors.white60),
                          filled: true,
                          fillColor: Colors.black54,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              formatDate(_selectedDate),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today, color: Colors.white70),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  _selectedDate = picked;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _addNote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5c6bc0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Kaydet", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Not kartları
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    final cardColor = _getCardColor(note.id);
                    final btnColor = _getBtnColor(note.id);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("📌", style: TextStyle(fontSize: 20, color: Colors.white)),
                              IconButton(
                                icon: Icon(Icons.delete, color: btnColor),
                                onPressed: () => _deleteNote(note.id),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(note.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(note.text, style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 6),
                          Text("Tarih: ${formatDate(note.date)}",
                              style: const TextStyle(fontSize: 12, color: Colors.white54)),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
