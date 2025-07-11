import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'goals_page.dart';
import 'calendar_screen.dart';
import 'note_pages.dart';
import 'motivation_page.dart';
import 'settings_page.dart'; // ✅ Gerçek sayfa import edildi
import 'login_screen.dart';

class MainPage extends StatefulWidget {
  final VoidCallback onLogout;
  const MainPage({super.key, required this.onLogout});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const HomeScreen(),
      const CalendarScreen(),
      const GoalsPage(),
      const NotesPage(),
      const MotivationPage(),
      SettingsPage(), // ✅ Buraya gerçek settings sayfası geldi
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    widget.onLogout();
  }

  final List<String> _titles = [
    'Ana Sayfa',
    'Takvim',
    'Hedefler',
    'Notlar',
    'Motivasyon',
    'Ayarlar',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.indigo,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.indigo,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Takvim'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Hedefler'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notlar'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Motivasyon'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
      ),
    );
  }
}
