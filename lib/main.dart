import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_screen.dart';
import 'pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.isLoggedIn;
  }

  void _handleLogin() {
    setState(() {
      _isLoggedIn = true;
    });

    // Girişten sonra ana sayfaya yönlendir
    Future.microtask(() {
      Navigator.pushReplacementNamed(context, "/main");
    });
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    setState(() {
      _isLoggedIn = false;
    });

    // Çıkıştan sonra login sayfasına yönlendir
    Future.microtask(() {
      Navigator.pushReplacementNamed(context, "/login");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RutinApp',
      theme: ThemeData(primarySwatch: Colors.indigo),

      // ✅ Route tanımları
      routes: {
        '/login': (context) => LoginScreen(onLogin: _handleLogin),
        '/main': (context) => MainPage(onLogout: _handleLogout),
      },

      // ✅ Başlangıç durumu
      home: _isLoggedIn
          ? MainPage(onLogout: _handleLogout)
          : LoginScreen(onLogin: _handleLogin),
    );
  }
}
