import '../models/achievement.dart';
import '../models/session.dart';
import '../models/user_profile.dart';
import './database_service.dart';
import './supabase_service.dart';
import './offline_database_service.dart';
import './gamification_service.dart';

class GamificationIntegrationService {
  static final GamificationIntegrationService _instance = GamificationIntegrationService._internal();
  factory GamificationIntegrationService() => _instance;
  GamificationIntegrationService._internal();

  // Track study session and award points/achievements
  Future<void> trackStudySession({
    required String sessionId,
    required int correctAnswers,
    required int totalQuestions,
    required String category,
    required int timeSpentSeconds,
    required List<SessionAnswer> answers,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    try {
      final gamificationService = GamificationService();
      
      // Award points for correct answers
      final pointsAwarded = correctAnswers;
      if (pointsAwarded > 0) {
        await gamificationService.awardGamingPoints(
          points: pointsAwarded,
          reason: 'Study session completion',
          metadata: {
            'session_id': sessionId,
            'correct_answers': correctAnswers,
            'total_questions': totalQuestions,
            'category': category,
            'time_spent_seconds': timeSpentSeconds,
          },
        );
      }

      // Track completion achievement
      await gamificationService.trackStudySessionComplete(
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        category: category,
      );

      // Track accuracy achievements
      final accuracy = totalQuestions > 0 ? correctAnswers / totalQuestions : 0;
      if (accuracy >= 0.8) {
        await gamificationService.trackProgress(
          type: AchievementType.accuracy,
          value: 1,
          userId: userId,
        );
      }

      // Track category-specific achievements
      if (category.isNotEmpty && category != 'all') {
        await _trackCategoryProgress(category, correctAnswers, userId);
      }

      // Track speed achievements for quick answers
      await _trackSpeedAchievements(answers, userId);

      // Update user stats
      await _updateUserStats(
        userId: userId,
        studySessions: 1,
        correctAnswers: correctAnswers,
        totalAnswers: totalQuestions,
      );

    } catch (e) {
      print('Error tracking study session: $e');
      // Track offline as fallback
      await _trackOfflineStudySession(
        sessionId: sessionId,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        category: category,
        timeSpentSeconds: timeSpentSeconds,
      );
    }
  }

  // Track exam session and award points/achievements
  Future<void> trackExamSession({
    required String sessionId,
    required int correctAnswers,
    required int totalQuestions,
    required String category,
    required bool passed,
    required int timeSpentSeconds,
    required List<SessionAnswer> answers,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    try {
      final gamificationService = GamificationService();
      
      // Award bonus points for passing exams
      if (passed) {
        final bonusPoints = _calculateExamBonusPoints(correctAnswers, totalQuestions);
        await gamificationService.awardGamingPoints(
          points: bonusPoints,
          reason: 'Mock exam passed',
          metadata: {
            'session_id': sessionId,
            'correct_answers': correctAnswers,
            'total_questions': totalQuestions,
            'category': category,
            'passed': passed,
            'bonus_points': bonusPoints,
          },
        );
      }

      // Track exam completion
      await gamificationService.trackExamSessionComplete(
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        category: category,
        passed: passed,
      );

      // Track perfect score achievement
      if (correctAnswers == totalQuestions) {
        await gamificationService.trackProgress(
          type: AchievementType.accuracy,
          value: 1,
          userId: userId,
        );
      }

      // Track speed achievements
      await _trackSpeedAchievements(answers, userId);

      // Update user stats
      await _updateUserStats(
        userId: userId,
        examSessions: 1,
        correctAnswers: correctAnswers,
        totalAnswers: totalQuestions,
      );

    } catch (e) {
      print('Error tracking exam session: $e');
      // Track offline as fallback
      await _trackOfflineExamSession(
        sessionId: sessionId,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        category: category,
        passed: passed,
        timeSpentSeconds: timeSpentSeconds,
      );
    }
  }

  // Track daily login and award streak points
  Future<void> trackDailyLogin() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    try {
      final gamificationService = GamificationService();
      await gamificationService.trackDailyLogin();
      
      // Record login event for analytics
      await _recordLoginEvent(userId);

    } catch (e) {
      print('Error tracking daily login: $e');
      await _trackOfflineDailyLogin(userId);
    }
  }

  // Track question answer with point adjustment
  Future<void> trackQuestionAnswer({
    required String sessionId,
    required String questionId,
    required int chosenIndex,
    required bool isCorrect,
    required int elapsedMs,
    int hintsUsed = 0,
  }) async {
    final gamificationService = GamificationService();
    await gamificationService.trackQuestionAnswer(
      sessionId: sessionId,
      questionId: questionId,
      chosenIndex: chosenIndex,
      isCorrect: isCorrect,
      elapsedMs: elapsedMs,
      hintsUsed: hintsUsed,
    );
  }

  // Handle navigation back with point deduction
  Future<void> handleNavigationBack({
    required String sessionId,
    required String questionId,
  }) async {
    final gamificationService = GamificationService();
    await gamificationService.handleNavigationBack(
      sessionId: sessionId,
      questionId: questionId,
    );
  }

  // Sync offline gamification data when online
  Future<void> syncOfflineGamificationData() async {
    final gamificationService = GamificationService();
    await gamificationService.syncOfflineGamificationData();
  }

  // Private helper methods

  Future<void> _trackCategoryProgress(String category, int correctAnswers, String userId) async {
    final gamificationService = GamificationService();
    
    // Track progress for category-specific achievements
    switch (category) {
      case 'rules_of_road':
        await gamificationService.trackProgress(
          type: AchievementType.completion,
          value: correctAnswers,
          userId: userId,
        );
        break;
      case 'road_signs':
        await gamificationService.trackProgress(
          type: AchievementType.completion,
          value: correctAnswers,
          userId: userId,
        );
        break;
      case 'vehicle_controls':
        await gamificationService.trackProgress(
          type: AchievementType.completion,
          value: correctAnswers,
          userId: userId,
        );
        break;
    }
  }

  Future<void> _trackSpeedAchievements(List<SessionAnswer> answers, String userId) async {
    final gamificationService = GamificationService();
    
    // Count quick answers (under 10 seconds and correct)
    final quickAnswers = answers.where((answer) => 
      answer.elapsedMs < 10000 && answer.isCorrect
    ).length;

    if (quickAnswers >= 5) {
      await gamificationService.trackProgress(
        type: AchievementType.speed,
        value: quickAnswers,
        userId: userId,
      );
    }
  }

  Future<void> _updateUserStats({
    required String userId,
    int studySessions = 0,
    int examSessions = 0,
    int correctAnswers = 0,
    int totalAnswers = 0,
  }) async {
    try {
      // Get current stats
      final currentStats = await DatabaseService.getUserStats(userId);
      
      // Update stats
      final updatedStats = {
        'total_study_sessions': (currentStats['totalSessions'] ?? 0) + studySessions,
        'total_exam_sessions': (currentStats['totalSessions'] ?? 0) + examSessions,
        'total_correct_answers': (currentStats['correctAnswers'] ?? 0) + correctAnswers,
        'total_answers': (currentStats['totalAnswers'] ?? 0) + totalAnswers,
      };

      // Update in database
      await DatabaseService.updateUserStats(
        userId: userId,
        points: updatedStats['total_correct_answers'] ?? 0,
        level: _calculateLevel(updatedStats['total_correct_answers'] ?? 0),
        unlockedAchievements: 0, // This would need to be calculated
      );

    } catch (e) {
      print('Error updating user stats: $e');
    }
  }

  Future<void> _recordLoginEvent(String userId) async {
    try {
      await DatabaseService.getLastLogin(userId); // This will create the login event
    } catch (e) {
      print('Error recording login event: $e');
    }
  }

  int _calculateExamBonusPoints(int correctAnswers, int totalQuestions) {
    final accuracy = totalQuestions > 0 ? correctAnswers / totalQuestions : 0;
    
    if (accuracy >= 0.9) return 10; // Excellent performance
    if (accuracy >= 0.8) return 5;  // Good performance
    if (accuracy >= 0.7) return 2;  // Passing performance
    return 0; // Failed exam
  }

  int _calculateLevel(int points) {
    if (points < 100) return 1;
    if (points < 300) return 2;
    if (points < 600) return 3;
    if (points < 1000) return 4;
    if (points < 1500) return 5;
    if (points < 2100) return 6;
    if (points < 2800) return 7;
    if (points < 3600) return 8;
    if (points < 4500) return 9;
    return 10;
  }

  // Offline tracking methods

  Future<void> _trackOfflineStudySession({
    required String sessionId,
    required int correctAnswers,
    required int totalQuestions,
    required String category,
    required int timeSpentSeconds,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    await OfflineDatabaseService.trackOfflineActivity(
      userId: userId,
      activityType: 'study_session',
      value: correctAnswers,
      metadata: {
        'session_id': sessionId,
        'correct_answers': correctAnswers,
        'total_questions': totalQuestions,
        'category': category,
        'time_spent_seconds': timeSpentSeconds,
        'points_awarded': correctAnswers,
      },
    );
  }

  Future<void> _trackOfflineExamSession({
    required String sessionId,
    required int correctAnswers,
    required int totalQuestions,
    required String category,
    required bool passed,
    required int timeSpentSeconds,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    final bonusPoints = _calculateExamBonusPoints(correctAnswers, totalQuestions);
    
    await OfflineDatabaseService.trackOfflineActivity(
      userId: userId,
      activityType: 'exam_session',
      value: bonusPoints,
      metadata: {
        'session_id': sessionId,
        'correct_answers': correctAnswers,
        'total_questions': totalQuestions,
        'category': category,
        'passed': passed,
        'bonus_points': bonusPoints,
        'time_spent_seconds': timeSpentSeconds,
      },
    );
  }

  Future<void> _trackOfflineDailyLogin(String userId) async {
    await OfflineDatabaseService.trackOfflineActivity(
      userId: userId,
      activityType: 'daily_login',
      value: 1,
      metadata: {
        'login_date': DateTime.now().toIso8601String(),
        'points_awarded': 1, // Base daily points
      },
    );
  }

  // Get comprehensive gamification summary for user
  Future<Map<String, dynamic>> getUserGamificationSummary() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return {};

    try {
      final gamificationService = GamificationService();
      
      final userStats = await gamificationService.getUserStats();
      final userAchievements = await gamificationService.getUserAchievements();
      final userProfile = await DatabaseService.getUserProfile(userId);

      return {
        'stats': userStats,
        'achievements': {
          'total': userAchievements.length,
          'unlocked': userAchievements.where((ua) => ua.unlocked).length,
          'progress': userAchievements.where((ua) => !ua.unlocked).length,
        },
        'profile': {
          'dailyPoints': userProfile?.dailyPoints ?? 0,
          'gamingPoints': userProfile?.gamingPoints ?? 0,
          'totalPoints': userProfile?.totalPoints ?? 0,
          'level': userProfile?.level ?? 1,
          'loginStreak': userProfile?.loginStreak ?? 0,
        },
        'nextLevelPoints': _calculateNextLevelPoints(userProfile?.level ?? 1),
      };

    } catch (e) {
      print('Error getting gamification summary: $e');
      return {};
    }
  }

  int _calculateNextLevelPoints(int currentLevel) {
    return currentLevel * (currentLevel + 1) * 50;
  }
}