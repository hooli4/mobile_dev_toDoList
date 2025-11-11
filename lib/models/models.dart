class Task {
  int id;
  String title;
  DateTime date;
  int isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.date,
    required this.isCompleted,
  });

  String get formattedDate {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day.$month.$year';
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      title: map['title'] as String,
      date: _parseDate(map['date']),
      isCompleted: map['isCompleted'] as int,
    );
  }

  static DateTime _parseDate(dynamic dateValue) {
    try {
      if (dateValue is DateTime) {
        return dateValue;
      } else if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      } else {
        return DateTime.now();
      }
    } catch (e) {
      print('Ошибка парсинга даты: $dateValue, ошибка: $e');
      return DateTime.now();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }
}