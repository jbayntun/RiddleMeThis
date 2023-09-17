class DailyRiddle {
  final String publishedDatetime;
  final String riddle;
  final String correctAnswer;
  final int id;
  final List<Hint> hints;

  DailyRiddle({
    required this.publishedDatetime,
    required this.riddle,
    required this.correctAnswer,
    required this.hints,
    required this.id,
  });

  factory DailyRiddle.fromJson(Map<String, dynamic> json) {
    return DailyRiddle(
      publishedDatetime: json['published_date'],
      riddle: json['riddle'],
      correctAnswer: json['correct_answer'],
      id: json['id'],
      hints:
          (json['hints'] as List).map((hint) => Hint.fromJson(hint)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'published_date': publishedDatetime,
      'riddle': riddle,
      'correct_answer': correctAnswer,
      'id': id,
      'hints': hints.map((hint) => hint.toJson()).toList(),
    };
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

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'hint': hint,
    };
  }
}
