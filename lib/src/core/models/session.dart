import 'dart:convert';
import 'question.dart';

enum SessionType { study, exam }

class Session {
  final String id;
  final SessionType type;
  final String? userId;
  final String? category;
  final int totalQuestions;
  final int currentQuestionIndex;
  final int correctAnswers;
  final int totalAnswered;
  final int timeRemainingSeconds;
  final bool isPaused;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime expiresAt;
  final Map<String, dynamic> metadata;

  Session({
    required this.id,
    required this.type,
    this.userId,
    this.category,
    required this.totalQuestions,
    required this.currentQuestionIndex,
    required this.correctAnswers,
    required this.totalAnswered,
    required this.timeRemainingSeconds,
    required this.isPaused,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
    this.metadata = const {},
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      type: SessionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => SessionType.study,
      ),
      userId: json['userId'],
      category: json['category'],
      totalQuestions: json['totalQuestions'] as int,
      currentQuestionIndex: json['currentQuestionIndex'] as int,
      correctAnswers: json['correctAnswers'] as int,
      totalAnswered: json['totalAnswered'] as int,
      timeRemainingSeconds: json['timeRemainingSeconds'] as int,
      isPaused: json['isPaused'] as bool,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'userId': userId,
      'category': category,
      'totalQuestions': totalQuestions,
      'currentQuestionIndex': currentQuestionIndex,
      'correctAnswers': correctAnswers,
      'totalAnswered': totalAnswered,
      'timeRemainingSeconds': timeRemainingSeconds,
      'isPaused': isPaused,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  Session copyWith({
    String? id,
    SessionType? type,
    String? userId,
    String? category,
    int? totalQuestions,
    int? currentQuestionIndex,
    int? correctAnswers,
    int? totalAnswered,
    int? timeRemainingSeconds,
    bool? isPaused,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return Session(
      id: id ?? this.id,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalAnswered: totalAnswered ?? this.totalAnswered,
      timeRemainingSeconds: timeRemainingSeconds ?? this.timeRemainingSeconds,
      isPaused: isPaused ?? this.isPaused,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get canRecover => !isCompleted && !isExpired;
  double get progress => totalQuestions > 0 ? currentQuestionIndex / totalQuestions : 0;
  double get accuracy => totalAnswered > 0 ? correctAnswers / totalAnswered : 0;

  @override
  String toString() {
    return 'Session(id: $id, type: $type, progress: $progress, completed: $isCompleted)';
  }
}

class SessionQuestion {
  final String sessionId;
  final String questionId;
  final int questionIndex;
  final Map<String, dynamic> questionData;

  SessionQuestion({
    required this.sessionId,
    required this.questionId,
    required this.questionIndex,
    required this.questionData,
  });

  factory SessionQuestion.fromJson(Map<String, dynamic> json) {
    return SessionQuestion(
      sessionId: json['sessionId'] as String,
      questionId: json['questionId'] as String,
      questionIndex: json['questionIndex'] as int,
      questionData: Map<String, dynamic>.from(json['questionData']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'questionId': questionId,
      'questionIndex': questionIndex,
      'questionData': questionData,
    };
  }

  Question toQuestion() {
    return Question.fromSupabase(questionData);
  }
}

class SessionAnswer {
  final String sessionId;
  final String questionId;
  final int chosenIndex;
  final bool isCorrect;
  final int elapsedMs;
  final int hintsUsed;
  final DateTime answeredAt;

  SessionAnswer({
    required this.sessionId,
    required this.questionId,
    required this.chosenIndex,
    required this.isCorrect,
    required this.elapsedMs,
    this.hintsUsed = 0,
    required this.answeredAt,
  });

  factory SessionAnswer.fromJson(Map<String, dynamic> json) {
    return SessionAnswer(
      sessionId: json['sessionId'] as String,
      questionId: json['questionId'] as String,
      chosenIndex: json['chosenIndex'] as int,
      isCorrect: json['isCorrect'] as bool,
      elapsedMs: json['elapsedMs'] as int,
      hintsUsed: json['hintsUsed'] as int,
      answeredAt: DateTime.parse(json['answeredAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'questionId': questionId,
      'chosenIndex': chosenIndex,
      'isCorrect': isCorrect,
      'elapsedMs': elapsedMs,
      'hintsUsed': hintsUsed,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }
}