class Note {
  final String id;
  final String title;
  final String text;
  final DateTime date;
  final String color;

  Note({
    required this.id,
    required this.title,
    required this.text,
    required this.date,
    required this.color,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['_id'] ?? '',
      title: json['title'],
      text: json['text'],
      date: DateTime.parse(json['date']),
      color: json['color'] ?? '#fff0f5',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'text': text,
      'date': date.toIso8601String(),
      'color': color,
    };
  }
}
