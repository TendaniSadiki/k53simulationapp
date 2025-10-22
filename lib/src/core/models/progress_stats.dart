class ProgressStats {
  final int totalQuestionsAnswered;
  final int correctAnswers;
  final double accuracy;
  final Map<String, Map<String, dynamic>> categories;

  const ProgressStats({
    required this.totalQuestionsAnswered,
    required this.correctAnswers,
    required this.accuracy,
    required this.categories,
  });

  factory ProgressStats.fromJson(Map<String, dynamic> json) {
    return ProgressStats(
      totalQuestionsAnswered: json['total_questions_answered'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      categories: Map<String, Map<String, dynamic>>.from(json['categories'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_questions_answered': totalQuestionsAnswered,
      'correct_answers': correctAnswers,
      'accuracy': accuracy,
      'categories': categories,
    };
  }

  factory ProgressStats.empty() {
    return ProgressStats(
      totalQuestionsAnswered: 0,
      correctAnswers: 0,
      accuracy: 0.0,
      categories: {},
    );
  }

  ProgressStats copyWith({
    int? totalQuestionsAnswered,
    int? correctAnswers,
    double? accuracy,
    Map<String, Map<String, dynamic>>? categories,
  }) {
    return ProgressStats(
      totalQuestionsAnswered: totalQuestionsAnswered ?? this.totalQuestionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      accuracy: accuracy ?? this.accuracy,
      categories: categories ?? this.categories,
    );
  }

  @override
  String toString() {
    return 'ProgressStats(totalQuestionsAnswered: $totalQuestionsAnswered, correctAnswers: $correctAnswers, accuracy: $accuracy, categories: $categories)';
  }
}