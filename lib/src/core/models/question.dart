class Question {
  final String id;
  final String questionText;
  final List<QuestionOption> options;
  final int correctIndex;
  final String explanation;
  final String category;
  final int learnerCode;
  final String? imageUrl;
  final bool isReported;
  final int reportCount;
  final int difficulty;
  final int timesAnswered;
  final int timesCorrect;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.category,
    required this.learnerCode,
    this.imageUrl,
    this.isReported = false,
    this.reportCount = 0,
    this.difficulty = 0,
    this.timesAnswered = 0,
    this.timesCorrect = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      questionText: json['question_text'] ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((option) => QuestionOption.fromJson(option))
              .toList() ??
          [],
      correctIndex: json['correct_index'] ?? 0,
      explanation: json['explanation'] ?? '',
      category: json['category'] ?? '',
      learnerCode: json['learner_code'] ?? 0,
      imageUrl: json['image_url'],
      isReported: json['is_reported'] ?? false,
      reportCount: json['report_count'] ?? 0,
      difficulty: json['difficulty'] ?? 0,
      timesAnswered: json['times_answered'] ?? 0,
      timesCorrect: json['times_correct'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  factory Question.fromSupabase(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      questionText: json['question_text'] ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((option) => QuestionOption.fromJson(option))
              .toList() ??
          [],
      correctIndex: json['correct_index'] ?? 0,
      explanation: json['explanation'] ?? '',
      category: json['category'] ?? '',
      learnerCode: json['learner_code'] ?? 0,
      imageUrl: json['image_url'],
      isReported: json['is_reported'] ?? false,
      reportCount: json['report_count'] ?? 0,
      difficulty: json['difficulty'] ?? 0,
      timesAnswered: json['times_answered'] ?? 0,
      timesCorrect: json['times_correct'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': questionText,
      'options': options.map((option) => option.toJson()).toList(),
      'correct_index': correctIndex,
      'explanation': explanation,
      'category': category,
      'learner_code': learnerCode,
      'image_url': imageUrl,
      'is_reported': isReported,
      'report_count': reportCount,
      'difficulty': difficulty,
      'times_answered': timesAnswered,
      'times_correct': timesCorrect,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool isAnswerCorrect(int answerIndex) {
    return answerIndex == correctIndex;
  }

  double get accuracy {
    if (timesAnswered == 0) return 0.0;
    return timesCorrect / timesAnswered;
  }

  String get formattedCategory {
    switch (category) {
      case 'rules_of_road':
        return 'Rules of the Road';
      case 'road_signs':
        return 'Road Signs';
      case 'vehicle_controls':
        return 'Vehicle Controls';
      default:
        return category;
    }
  }

  String get formattedLearnerCode {
    switch (learnerCode) {
      case 1:
        return 'Code 1 (Motorcycles)';
      case 2:
        return 'Code 2 (Light Vehicles)';
      case 3:
        return 'Code 3 (Heavy Vehicles)';
      default:
        return 'All Codes';
    }
  }

  bool get isActive => !isReported || reportCount < 5;
}

class QuestionOption {
  final String text;
  final bool isCorrect;

  QuestionOption({
    required this.text,
    this.isCorrect = false,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      text: json['text'] ?? '',
      isCorrect: json['is_correct'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'is_correct': isCorrect,
    };
  }
}
