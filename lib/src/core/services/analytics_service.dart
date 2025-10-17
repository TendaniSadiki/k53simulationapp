import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Track user engagement events
  static Future<void> trackUserEngagement({
    required String eventName,
    Map<String, dynamic>? properties,
  }) async {
    if (kDebugMode) {
      print('📊 Analytics Event: $eventName');
      if (properties != null) {
        print('📊 Properties: $properties');
      }
    }
    
    // In production, this would send to your analytics service
    // For now, we just log to console in debug mode
  }

  // Track exam session start
  static Future<void> trackExamSessionStart({
    required String sessionId,
    String? category,
    int timeLimitMinutes = 45,
  }) async {
    await trackUserEngagement(
      eventName: 'exam_session_start',
      properties: {
        'session_id': sessionId,
        'category': category ?? 'all',
        'time_limit_minutes': timeLimitMinutes,
      },
    );
  }

  // Track exam session completion
  static Future<void> trackExamSessionComplete({
    required String sessionId,
    required int score,
    required int totalQuestions,
    required bool passed,
    required int timeSpentSeconds,
  }) async {
    await trackUserEngagement(
      eventName: 'exam_session_complete',
      properties: {
        'session_id': sessionId,
        'score': score,
        'total_questions': totalQuestions,
        'passed': passed,
        'time_spent_seconds': timeSpentSeconds,
        'accuracy': totalQuestions > 0 ? (score / totalQuestions) : 0,
      },
    );
  }

  // Track study session start
  static Future<void> trackStudySessionStart({
    required String sessionId,
    String? category,
    int? learnerCode,
  }) async {
    await trackUserEngagement(
      eventName: 'study_session_start',
      properties: {
        'session_id': sessionId,
        'category': category ?? 'all',
        'learner_code': learnerCode,
      },
    );
  }

  // Track study session completion
  static Future<void> trackStudySessionComplete({
    required String sessionId,
    required int correctAnswers,
    required int totalAnswered,
    String? category,
  }) async {
    await trackUserEngagement(
      eventName: 'study_session_complete',
      properties: {
        'session_id': sessionId,
        'correct_answers': correctAnswers,
        'total_answered': totalAnswered,
        'category': category ?? 'all',
        'accuracy': totalAnswered > 0 ? (correctAnswers / totalAnswered) : 0,
      },
    );
  }

  // Track question answered
  static Future<void> trackQuestionAnswered({
    required String sessionId,
    required String questionId,
    required bool isCorrect,
    required int elapsedMs,
    required int hintsUsed,
  }) async {
    await trackUserEngagement(
      eventName: 'question_answered',
      properties: {
        'session_id': sessionId,
        'question_id': questionId,
        'is_correct': isCorrect,
        'elapsed_ms': elapsedMs,
        'hints_used': hintsUsed,
      },
    );
  }

  // Track image requirement for questions
  static Future<void> trackImageRequirement({
    required String questionId,
    required String questionText,
    String? imageUrl,
    required String category,
    required int learnerCode,
  }) async {
    await trackUserEngagement(
      eventName: 'image_requirement',
      properties: {
        'question_id': questionId,
        'question_text_length': questionText.length,
        'has_image': imageUrl != null,
        'category': category,
        'learner_code': learnerCode,
      },
    );
  }

  // Track user registration
  static Future<void> trackUserRegistration({
    required String userId,
    String? email,
  }) async {
    await trackUserEngagement(
      eventName: 'user_registration',
      properties: {
        'user_id': userId,
        'has_email': email != null,
      },
    );
  }

  // Track user login
  static Future<void> trackUserLogin({
    required String userId,
  }) async {
    await trackUserEngagement(
      eventName: 'user_login',
      properties: {
        'user_id': userId,
      },
    );
  }

  // Track app errors
  static Future<void> trackError({
    required String error,
    required String stackTrace,
    String? context,
  }) async {
    await trackUserEngagement(
      eventName: 'app_error',
      properties: {
        'error': error,
        'stack_trace': stackTrace,
        'context': context,
      },
    );
  }

  // Track feature usage
  static Future<void> trackFeatureUsage({
    required String featureName,
    Map<String, dynamic>? additionalProperties,
  }) async {
    await trackUserEngagement(
      eventName: 'feature_usage',
      properties: {
        'feature_name': featureName,
        ...?additionalProperties,
      },
    );
  }

  // Track gamification events
  static Future<void> trackGamificationEvent({
    required String eventType,
    required int points,
    String? achievementId,
    Map<String, dynamic>? metadata,
  }) async {
    await trackUserEngagement(
      eventName: 'gamification_event',
      properties: {
        'event_type': eventType,
        'points': points,
        'achievement_id': achievementId,
        ...?metadata,
      },
    );
  }

  // Track offline mode usage
  static Future<void> trackOfflineModeUsage({
    required bool isOffline,
    required String activity,
    Map<String, dynamic>? additionalData,
  }) async {
    await trackUserEngagement(
      eventName: 'offline_mode_usage',
      properties: {
        'is_offline': isOffline,
        'activity': activity,
        ...?additionalData,
      },
    );
  }

  // Track session recovery
  static Future<void> trackSessionRecovery({
    required String sessionId,
    required String sessionType,
    required bool success,
    String? error,
  }) async {
    await trackUserEngagement(
      eventName: 'session_recovery',
      properties: {
        'session_id': sessionId,
        'session_type': sessionType,
        'success': success,
        'error': error,
      },
    );
  }
}