class DailyRiddle {
  final String publishedDate;
  final String riddle;
  final String correctAnswer;
  final int id;
  final List<Hint> hints;

  DailyRiddle({
    required this.publishedDate,
    required this.riddle,
    required this.correctAnswer,
    required this.hints,
    required this.id,
  });

  factory DailyRiddle.fromJson(Map<String, dynamic> json) {
    return DailyRiddle(
      publishedDate: json['published_date'],
      riddle: json['riddle'],
      correctAnswer: json['correct_answer'],
      id: json['id'],
      hints:
          (json['hints'] as List).map((hint) => Hint.fromJson(hint)).toList(),
    );
  }
}

class Hint {
  final String description;
  final String hint;

  Hint({
    required this.description,
    required this.hint,
  });

  factory Hint.fromJson(Map<String, dynamic> json) {
    return Hint(
      description: json['description'],
      hint: json['hint'],
    );
  }
}
