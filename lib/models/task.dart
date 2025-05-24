class Task {
  final String? id;
  final String text;
  final DateTime time;

  Task({this.id, required this.text, required this.time});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      text: json['text'],
      time: DateTime.parse(json['time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'time': time.toIso8601String(),
    };
  }
}
