import '../models/achievement.dart';
import '../models/session.dart';
import '../models/user_profile.dart';
import '../models/point_adjustment.dart';
import './database_service.dart';
import './supabase_service.dart';
import './offline_database_service.dart';
import './point_adjustment_service.dart';

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  // Track user progress for different achievement types
  Future<void> trackProgress({
    required AchievementType type,
    required int value,
    String? userId,
  }) async {
    final currentUserId = userId ?? SupabaseService.currentUserId;
    if (currentUserId == null) return;

    try {
      // Get all achievements of this type
      final achievementsData = await DatabaseService.getAchievementsByType(type.name);
      
      // Handle case where no achievements are found
      if (achievementsData.isEmpty) {
        print('No achievements found for type: ${type.name}');
        return;
      }
      
      for (final achievementData in achievementsData) {
        try {
          final achievement = Achievement.fromSupabase(achievementData);
          
          // Check if user already has this achievement
          final userAchievementData = await DatabaseService.getUserAchievement(currentUserId, achievement.id);
          final userAchievement = userAchievementData != null ? UserAchievement.fromSupabase(userAchievementData) : null;

          if (userAchievement != null && userAchievement.unlocked) {
            continue; // Already unlocked
          }

          // Calculate new progress
          final newProgress = (userAchievement?.progress ?? 0) + value;
          
          if (newProgress >= achievement.targetValue) {
            // Unlock achievement
            await DatabaseService.unlockAchievement(currentUserId, achievement.id);
            
            // Track achievement unlock in analytics
            await DatabaseService.trackAchievementUnlocked(currentUserId, achievement.id);
          } else {
            // Update progress
            await DatabaseService.updateAchievementProgress(currentUserId, achievement.id, newProgress);
          }
        } catch (e) {
          print('Error processing achievement: $e');
        }
      }
    } catch (e) {
      print('Error tracking progress: $e');
    }
  }

  // Track individual question answer with point adjustment
  Future<void> trackQuestionAnswer({
    required String sessionId,
    required String questionId,
    required int chosenIndex,
    required bool isCorrect,
    required int elapsedMs,
    int hintsUsed = 0,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    try {
      // Use PointAdjustmentService to record answer with point tracking
      await PointAdjustmentService().recordQuestionAnswer(
        sessionId: sessionId,
        questionId: questionId,
        chosenIndex: chosenIndex,
        isCorrect: isCorrect,
        elapsedMs: elapsedMs,
        hintsUsed: hintsUsed,
      );

      // Award gaming points for correct answers
      if (isCorrect) {
        await awardGamingPoints(
          points: 1,
          reason: 'Correct answer',
          metadata: {
            'session_id': sessionId,
            'question_id': questionId,
            'elapsed_ms': elapsedMs,
          },
        );
      }

      // Track offline activity for the answer
      await trackOfflineActivity(
        activityType: 'question_answer',
        value: isCorrect ? 1 : 0,
        metadata: {
          'session_id': sessionId,
          'question_id': questionId,
          'is_correct': isCorrect,
          'points_awarded': isCorrect ? 1 : 0,
        },
      );
    } catch (e) {
      print('Error tracking question answer: $e');
    }
  }

  // Award gaming points for in-game accomplishments
  Future<void> awardGamingPoints({
    required int points,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    try {
      final userProfileData = await DatabaseService.getUserProfile(userId);
      final now = DateTime.now();
      
      UserProfile updatedProfile;
      if (userProfileData != null) {
        final userProfile = UserProfile.fromSupabase(userProfileData);
        updatedProfile = userProfile.addGamingPoints(points);
      } else {
        updatedProfile = UserProfile(
          id: userId,
          handle: null,
          learnerCode: 0,
          locale: 'en',
          studyGoalDate: null,
          createdAt: now,
          updatedAt: now,
          gamingPoints: points,
          totalPoints: points,
        );
      }
      
      await DatabaseService.updateUserProfile(updatedProfile.toSupabase());
      
      // Track offline activity for gaming points
      await trackOfflineActivity(
        activityType: 'gaming_points',
        value: points,
        metadata: {
          'reason': reason,
          ...?metadata,
        },
      );
    } catch (e) {
      print('Error awarding gaming points: $e');
    }
  }

  // Handle navigation back to previous question (point deduction)
  Future<void> handleNavigationBack({
    required String sessionId,
    required String questionId,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    try {
      // Use PointAdjustmentService to handle point deduction
      await PointAdjustmentService().handleNavigationBack(
        sessionId: sessionId,
        questionId: questionId,
      );

      // Track offline activity for navigation back
      await trackOfflineActivity(
        activityType: 'navigation_back',
        value: -1,
        metadata: {
          'session_id': sessionId,
          'question_id': questionId,
          'reason': 'User navigated back to previous question',
        },
      );
    } catch (e) {
      print('Error handling navigation back: $e');
    }
  }

  // Track study session completion
  Future<void> trackStudySessionComplete({
    required int correctAnswers,
    required int totalQuestions,
    required String category,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    try {
      // Track accuracy achievement
      final accuracy = totalQuestions > 0 ? correctAnswers / totalQuestions : 0;
      if (accuracy >= 0.8) {
        await trackProgress(
          type: AchievementType.accuracy,
          value: 1,
          userId: userId,
        );
      }

      // Track completion achievement (every session counts)
      await trackProgress(
        type: AchievementType.completion,
        value: 1,
        userId: userId,
      );

      // Track category-specific achievements
      if (category.isNotEmpty && category != 'all') {
        await trackProgress(
          type: AchievementType.completion,
          value: 1,
          userId: userId,
        );
      }
    } catch (e) {
      print('Error tracking study session: $e');
    }
  }

  // Track exam session completion
  Future<void> trackExamSessionComplete({
    required int correctAnswers,
    required int totalQuestions,
    required String category,
    required bool passed,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    try {
      // Track accuracy achievement
      final accuracy = totalQuestions > 0 ? correctAnswers / totalQuestions : 0;
      if (accuracy >= 0.7) { // 70% for passing exam
        await trackProgress(
          type: AchievementType.accuracy,
          value: 1,
          userId: userId,
        );
      }

      // Track completion achievement (every exam counts)
      await trackProgress(
        type: AchievementType.completion,
        value: 1,
        userId: userId,
      );

      // Track exam-specific achievements
      if (passed) {
        await trackProgress(
          type: AchievementType.completion, // Or create a new type for exam passes?
          value: 1,
          userId: userId,
        );
      }

      // Track category-specific achievements
      if (category.isNotEmpty && category != 'all') {
        await trackProgress(
          type: AchievementType.completion,
          value: 1,
          userId: userId,
        );
      }
    } catch (e) {
      print('Error tracking exam session: $e');
    }
  }

  // Track daily login streak and award points
  Future<void> trackDailyLogin() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    try {
      final userProfileData = await DatabaseService.getUserProfile(userId);
      final now = DateTime.now();
      
      if (userProfileData != null) {
        final userProfile = UserProfile.fromSupabase(userProfileData);
        
        // Check if user can claim daily points today
        final canClaimDailyPoints = userProfile.canClaimDailyPoints();
        final hasLoggedInToday = userProfile.hasLoggedInToday();
        
        if (!hasLoggedInToday) {
          // Calculate new streak
          final currentStreak = userProfile.loginStreak;
          final newStreak = (userProfile.lastLoginDate != null &&
                            now.difference(userProfile.lastLoginDate!).inHours <= 28)
              ? currentStreak + 1
              : 1;
          
          // Update user profile with new streak and login date
          var updatedProfile = userProfile.updateLoginStreak(newStreak);
          await DatabaseService.updateUserProfile(updatedProfile.toSupabase());
          
          // Award daily points if eligible
          if (canClaimDailyPoints) {
            final dailyPoints = _calculateDailyPoints(newStreak);
            
            // Update user profile with daily points
            final pointsProfile = updatedProfile.addDailyPoints(dailyPoints);
            await DatabaseService.updateUserProfile(pointsProfile.toSupabase());
            
            // Track streak achievements
            await trackProgress(
              type: AchievementType.streak,
              value: newStreak,
              userId: userId,
            );
            
            // Track offline activity for daily login points
            await trackOfflineActivity(
              activityType: 'daily_login',
              value: dailyPoints,
              metadata: {
                'streak': newStreak,
                'daily_points': dailyPoints,
                'login_date': now.toIso8601String(),
              },
            );
          }
        }
      } else {
        // Create new user profile if it doesn't exist
        final newProfile = UserProfile(
          id: userId,
          handle: null,
          learnerCode: 0,
          locale: 'en',
          studyGoalDate: null,
          createdAt: now,
          updatedAt: now,
          loginStreak: 1,
          lastLoginDate: now,
        );
        await DatabaseService.updateUserProfile(newProfile.toSupabase());
      }
    } catch (e) {
      print('Error tracking daily login: $e');
    }
  }

  // Calculate daily points based on streak
  int _calculateDailyPoints(int streak) {
    if (streak >= 30) return 5; // 30+ days streak
    if (streak >= 14) return 4; // 14-29 days streak
    if (streak >= 7) return 3;  // 7-13 days streak
    if (streak >= 3) return 2;  // 3-6 days streak
    return 1;                   // 1-2 days streak
  }

  // Get user achievements
  Future<List<UserAchievement>> getUserAchievements() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return [];

    try {
      final achievementsData = await DatabaseService.getUserAchievements(userId);
      return achievementsData.map((data) => UserAchievement.fromSupabase(data)).toList();
    } catch (e) {
      print('Error getting user achievements: $e');
      return [];
    }
  }

  // Get user points and level
  Future<Map<String, dynamic>> getUserStats() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return {'points': 0, 'level': 1};

    try {
      // Try to get stats from offline database first
      final offlineStats = await OfflineDatabaseService.getGamificationStats(userId);
      if (offlineStats.isNotEmpty) {
        return offlineStats;
      }

      final userAchievements = await getUserAchievements();
      final unlockedAchievements = userAchievements.where((ua) => ua.unlocked).toList();
      
      // Calculate total points from actual achievement point values
      int totalPoints = 0;
      for (final userAchievement in unlockedAchievements) {
        try {
          // Fetch the achievement details to get the point value
          final achievementData = await DatabaseService.getAchievementById(userAchievement.achievementId);
          if (achievementData != null) {
            final achievement = Achievement.fromSupabase(achievementData);
            totalPoints += achievement.points;
          }
        } catch (e) {
          print('Error calculating points for achievement ${userAchievement.achievementId}: $e');
        }
      }
      
      final level = _calculateLevel(totalPoints);
      
      final stats = {
        'points': totalPoints,
        'level': level,
        'next_level_points': _pointsForLevel(level + 1),
        'unlocked_achievements': unlockedAchievements.length,
      };
      
      // Cache stats in offline database
      await OfflineDatabaseService.saveGamificationStats(userId, stats);
      
      return stats;
    } catch (e) {
      print('Error getting user stats: $e');
      // Try to get from offline database as fallback
      try {
        if (userId != null) {
          final offlineStats = await OfflineDatabaseService.getGamificationStats(userId);
          if (offlineStats.isNotEmpty) {
            return offlineStats;
          }
        }
      } catch (offlineError) {
        print('Error getting offline stats: $offlineError');
      }
      return {'points': 0, 'level': 1, 'unlocked_achievements': 0};
    }
  
  }

  // Get session point summary
  Future<Map<String, dynamic>> getSessionPointSummary(String sessionId) async {
    try {
      return await PointAdjustmentService().getSessionPointSummary(sessionId);
    } catch (e) {
      print('Error getting session point summary: $e');
      return {
        'totalPoints': 0,
        'totalQuestions': 0,
        'questionsWithPoints': 0,
        'adjustedQuestions': 0,
        'answers': [],
      };
    }
  }

  // Get total points for a session
  Future<int> getSessionTotalPoints(String sessionId) async {
    try {
      return await PointAdjustmentService().getSessionTotalPoints(sessionId);
    } catch (e) {
      print('Error getting session total points: $e');
      return 0;
    }
  }

  // Get point history for a specific question
  Future<List<PointAdjustment>> getQuestionPointHistory({
    required String sessionId,
    required String questionId,
  }) async {
    try {
      return await PointAdjustmentService().getQuestionPointHistory(
        sessionId: sessionId,
        questionId: questionId,
      );
    } catch (e) {
      print('Error getting question point history: $e');
      return [];
    }
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

  int _pointsForLevel(int level) {
    return level * (level + 1) * 50; // Quadratic progression
  }

  // Get all achievements from database
  Future<List<Achievement>> getAllAchievements() async {
    try {
      // Get achievements by each type and combine them
      final allAchievements = <Achievement>[];
      
      for (final type in AchievementType.values) {
        final achievementsData = await DatabaseService.getAchievementsByType(type.name);
        final achievements = achievementsData.map((data) => Achievement.fromSupabase(data)).toList();
        allAchievements.addAll(achievements);
      }
      
      return allAchievements;
    } catch (e) {
      print('Error getting all achievements: $e');
      return [];
    }
  }

  // Track offline activity for gamification
  Future<void> trackOfflineActivity({
    required String activityType,
    required int value,
    Map<String, dynamic>? metadata,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    try {
      await OfflineDatabaseService.trackOfflineActivity(
        userId: userId,
        activityType: activityType,
        value: value,
        metadata: metadata,
      );
    } catch (e) {
      print('Error tracking offline activity: $e');
    }
  }

  // Sync offline gamification data when online
  Future<void> syncOfflineGamificationData() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    try {
      final offlineActivities = await OfflineDatabaseService.getPendingOfflineActivities(userId);
      
      for (final activity in offlineActivities) {
        switch (activity['activity_type']) {
          case 'study_session':
            await trackStudySessionComplete(
              correctAnswers: activity['metadata']['correct_answers'] ?? 0,
              totalQuestions: activity['metadata']['total_questions'] ?? 0,
              category: activity['metadata']['category'] ?? '',
            );
            break;
          case 'exam_session':
            await trackExamSessionComplete(
              correctAnswers: activity['metadata']['correct_answers'] ?? 0,
              totalQuestions: activity['metadata']['total_questions'] ?? 0,
              category: activity['metadata']['category'] ?? '',
              passed: activity['metadata']['passed'] ?? false,
            );
            break;
          case 'daily_login':
            await trackDailyLogin();
            break;
        }
        
        // Mark activity as synced
        await OfflineDatabaseService.markActivityAsSynced(activity['id']);
      }
    } catch (e) {
      print('Error syncing offline gamification data: $e');
    }
  }
}