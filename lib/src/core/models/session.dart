import 'package:equatable/equatable.dart';
import 'question.dart';

enum SessionType {
  study,
  exam,
}

class Session extends Equatable {
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

  const Session({
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

  bool get canRecover {
    return !isCompleted &&
           DateTime.now().isBefore(expiresAt) &&
           currentQuestionIndex < totalQuestions;
  }

  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  double get progress {
    if (totalQuestions == 0) return 0.0;
    return currentQuestionIndex / totalQuestions;
  }

  double get accuracy {
    if (totalAnswered == 0) return 0.0;
    return correctAnswers / totalAnswered;
  }

  @override
  List<Object?> get props => [
        id,
        type,
        userId,
        category,
        totalQuestions,
        currentQuestionIndex,
        correctAnswers,
        totalAnswered,
        timeRemainingSeconds,
        isPaused,
        isCompleted,
        createdAt,
        updatedAt,
        expiresAt,
        metadata,
      ];
}

class SessionAnswer {
  final String sessionId;
  final String questionId;
  final int chosenIndex;
  final bool isCorrect;
  final int elapsedMs;
  final DateTime answeredAt;
  final int pointsAwarded;

  SessionAnswer({
    required this.sessionId,
    required this.questionId,
    required this.chosenIndex,
    required this.isCorrect,
    required this.elapsedMs,
    required this.answeredAt,
    this.pointsAwarded = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'question_id': questionId,
      'chosen_index': chosenIndex,
      'is_correct': isCorrect,
      'elapsed_ms': elapsedMs,
      'answered_at': answeredAt.toIso8601String(),
      'points_awarded': pointsAwarded,
    };
  }

  factory SessionAnswer.fromJson(Map<String, dynamic> json) {
    return SessionAnswer(
      sessionId: json['session_id'] ?? '',
      questionId: json['question_id'] ?? '',
      chosenIndex: json['chosen_index'] ?? -1,
      isCorrect: json['is_correct'] ?? false,
      elapsedMs: json['elapsed_ms'] ?? 0,
      answeredAt: DateTime.parse(json['answered_at'] ?? DateTime.now().toIso8601String()),
      pointsAwarded: json['points_awarded'] ?? 0,
    );
  }
}

// Legacy session state for backward compatibility
class SessionState {
  final SessionType type;
  final List<Question> questions;
  final int currentQuestionIndex;
  final int? selectedAnswerIndex;
  final bool showExplanation;
  final String? sessionId;
  final int correctAnswers;
  final int totalAnswered;
  final Map<String, int> userAnswers;
  final Map<String, dynamic> additionalData;

  SessionState({
    required this.type,
    required this.questions,
    required this.currentQuestionIndex,
    this.selectedAnswerIndex,
    required this.showExplanation,
    this.sessionId,
    required this.correctAnswers,
    required this.totalAnswered,
    this.userAnswers = const {},
    this.additionalData = const {},
  });

  double get progress {
    if (questions.isEmpty) return 0.0;
    return (currentQuestionIndex + 1) / questions.length;
  }

  double get accuracy {
    if (totalAnswered == 0) return 0.0;
    return correctAnswers / totalAnswered;
  }

  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;
  bool get isFirstQuestion => currentQuestionIndex == 0;
}