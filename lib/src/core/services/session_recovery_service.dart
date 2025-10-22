import '../models/session.dart' as session_models;
import './session_database_service.dart';

class SessionRecoveryService {
  static Future<List<session_models.Session>> getRecoverableSessions(String userId) async {
    try {
      final sessions = await SessionDatabaseService.getUserSessions(userId);
      return sessions.where((session) => session.canRecover).toList();
    } catch (e) {
      print('Error getting recoverable sessions: $e');
      return [];
    }
  }

  static Future<bool> validateSession(session_models.Session session) async {
    if (session.isCompleted) {
      return false;
    }

    if (session.isExpired) {
      // Auto-cleanup expired sessions
      await SessionDatabaseService.deleteSession(session.id);
      return false;
    }

    // Check if session has valid questions
    try {
      final sessionWithQuestions = await SessionDatabaseService.getSession(session.id);
      return sessionWithQuestions != null && sessionWithQuestions.totalQuestions > 0;
    } catch (e) {
      return false;
    }
  }

  static Future<void> cleanupOldSessions() async {
    try {
      await SessionDatabaseService.cleanupExpiredSessions();
      
      // Additional cleanup logic can be added here
      // For example, remove sessions older than 7 days
    } catch (e) {
      print('Error cleaning up old sessions: $e');
    }
  }

  static Future<Map<String, dynamic>> getSessionStatistics(String userId) async {
    try {
      final sessions = await SessionDatabaseService.getUserSessions(userId);
      
      final totalSessions = sessions.length;
      final activeSessions = sessions.where((s) => !s.isCompleted).length;
      final completedSessions = sessions.where((s) => s.isCompleted).length;
      final expiredSessions = sessions.where((s) => s.isExpired).length;

      return {
        'total_sessions': totalSessions,
        'active_sessions': activeSessions,
        'completed_sessions': completedSessions,
        'expired_sessions': expiredSessions,
        'recoverable_sessions': sessions.where((s) => s.canRecover).length,
      };
    } catch (e) {
      print('Error getting session statistics: $e');
      return {};
    }
  }

  static Future<void> markSessionAsCompleted(String sessionId) async {
    try {
      final session = await SessionDatabaseService.getSession(sessionId);
      if (session != null) {
        final completedSession = session.copyWith(
          isCompleted: true,
          updatedAt: DateTime.now(),
        );
        await SessionDatabaseService.updateSession(completedSession);
      }
    } catch (e) {
      print('Error marking session as completed: $e');
    }
  }

  static Future<void> updateSessionProgress({
    required String sessionId,
    required int currentQuestionIndex,
    required int correctAnswers,
    required int totalAnswered,
    required int timeRemainingSeconds,
  }) async {
    try {
      final session = await SessionDatabaseService.getSession(sessionId);
      if (session != null) {
        final updatedSession = session.copyWith(
          currentQuestionIndex: currentQuestionIndex,
          correctAnswers: correctAnswers,
          totalAnswered: totalAnswered,
          timeRemainingSeconds: timeRemainingSeconds,
          updatedAt: DateTime.now(),
        );
        await SessionDatabaseService.updateSession(updatedSession);
      }
    } catch (e) {
      print('Error updating session progress: $e');
    }
  }

  static Future<void> pauseSession(String sessionId) async {
    try {
      final session = await SessionDatabaseService.getSession(sessionId);
      if (session != null && !session.isPaused && !session.isCompleted) {
        final pausedSession = session.copyWith(
          isPaused: true,
          updatedAt: DateTime.now(),
        );
        await SessionDatabaseService.updateSession(pausedSession);
      }
    } catch (e) {
      print('Error pausing session: $e');
    }
  }

  static Future<void> resumeSession(String sessionId) async {
    try {
      final session = await SessionDatabaseService.getSession(sessionId);
      if (session != null && session.isPaused && !session.isCompleted) {
        final resumedSession = session.copyWith(
          isPaused: false,
          updatedAt: DateTime.now(),
        );
        await SessionDatabaseService.updateSession(resumedSession);
      }
    } catch (e) {
      print('Error resuming session: $e');
    }
  }

  static Future<session_models.Session?> getMostRecentSession(String userId) async {
    try {
      final sessions = await SessionDatabaseService.getUserSessions(userId);
      if (sessions.isEmpty) return null;

      // Sort by creation date descending and return the most recent
      sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sessions.first;
    } catch (e) {
      print('Error getting most recent session: $e');
      return null;
    }
  }

  static Future<bool> hasActiveSessions(String userId) async {
    try {
      final sessions = await SessionDatabaseService.getUserSessions(userId);
      return sessions.any((session) => session.canRecover);
    } catch (e) {
      print('Error checking for active sessions: $e');
      return false;
    }
  }
}