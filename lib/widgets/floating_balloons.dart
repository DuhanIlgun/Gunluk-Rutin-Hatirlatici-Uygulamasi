import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FloatingBalloons extends StatefulWidget {
  const FloatingBalloons({super.key});

  @override
  State<FloatingBalloons> createState() => _FloatingBalloonsState();
}

class _FloatingBalloonsState extends State<FloatingBalloons>
    with TickerProviderStateMixin {
  final List<_Balloon> _balloons = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: 12 + Random().nextInt(6)),
      )..repeat();

      _balloons.add(_Balloon(
        left: Random().nextDouble(),
        color: _randomColor(),
        emoji: "🎈",
        controller: controller,
        speed: 1 + Random().nextDouble(),
      ));
    }
  }

  Color _randomColor() {
    const colors = [
      Colors.indigo,
    ];
    return colors[Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    for (var balloon in _balloons) {
      balloon.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _showMotivationMessage(BuildContext context) async {
    String message = "⚠️ Motivasyon mesajı alınamadı.";
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final res = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/motivation/daily"),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['text'] != null) {
        message = data['text'];
      }
    } catch (_) {}

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("✨ Motivasyon Mesajı"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("Kapat"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: _balloons.map((balloon) {
        return AnimatedBuilder(
          animation: balloon.controller,
          builder: (context, child) {
            final progress = balloon.controller.value;
            final top = (1 - progress) * (size.height + 60) - 60;
            return Positioned(
              top: top,
              left: size.width * balloon.left,
              child: GestureDetector(
                onTap: () => _showMotivationMessage(context),
                child: Opacity(
                  opacity: 0.75,
                  child: Text(
                    balloon.emoji,
                    style: TextStyle(
                      fontSize: 28,
                      color: balloon.color,
                      shadows: const [
                        Shadow(blurRadius: 4, color: Colors.black26),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class _Balloon {
  final double left;
  final Color color;
  final String emoji;
  final AnimationController controller;
  final double speed;

  _Balloon({
    required this.left,
    required this.color,
    required this.emoji,
    required this.controller,
    required this.speed,
  });
}
