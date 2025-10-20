import 'package:supabase_flutter/supabase_flutter.dart';
import 'database_service.dart';

class SessionPointsService {
  static final SessionPointsService _instance = SessionPointsService._internal();
  factory SessionPointsService() => _instance;
  SessionPointsService._internal();

  // Calculate and award points for a study session
  static Future<void> awardSessionPoints({
    required String userId,
    required int correctAnswers,
    required int totalQuestions,
    required String sessionType,
    int timeSpentSeconds = 0,
    int difficulty = 1,
  }) async {
    try {
      // Get current user profile
      final profile = await DatabaseService.getUserProfile(userId);
      if (profile == null) return;

      int currentPoints = (profile['total_points'] as int?) ?? 0;
      int currentLevel = (profile['level'] as int?) ?? 1;

      // Calculate base points
      int basePoints = _calculateBasePoints(correctAnswers, totalQuestions);
      
      // Add bonus points for session type
      int bonusPoints = _calculateBonusPoints(sessionType, difficulty, timeSpentSeconds);
      
      // Calculate total points for this session
      int sessionPoints = basePoints + bonusPoints;
      
      // Update total points
      int newTotalPoints = currentPoints + sessionPoints;
      
      // Check for level up
      final levelUpResult = _checkLevelUp(currentLevel, newTotalPoints);
      final newLevel = levelUpResult['level'] as int;
      final leveledUp = levelUpResult['leveled_up'] as bool;

      // Update user profile
      await DatabaseService.updateUserProfile({
        'id': userId,
        'total_points': newTotalPoints,
        'level': newLevel,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Log session results
      print('🎯 Session completed:');
      print('   - Correct: $correctAnswers/$totalQuestions');
      print('   - Base Points: $basePoints');
      print('   - Bonus Points: $bonusPoints');
      print('   - Total Session Points: $sessionPoints');
      print('   - New Total Points: $newTotalPoints');
      print('   - Level: $newLevel ${leveledUp ? '(LEVEL UP! 🎉)' : ''}');

      // Check for point-based achievements
      await _checkPointAchievements(userId, newTotalPoints);

    } catch (e) {
      print('❌ Error awarding session points: $e');
    }
  }

  // Calculate base points based on correct answers
  static int _calculateBasePoints(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return 0;
    
    final accuracy = correctAnswers / totalQuestions;
    
    if (accuracy >= 0.9) return 50; // Excellent (90%+)
    if (accuracy >= 0.7) return 30; // Good (70%+)
    if (accuracy >= 0.5) return 20; // Average (50%+)
    if (accuracy >= 0.3) return 10; // Below average (30%+)
    return 5; // Poor (<30%)
  }

  // Calculate bonus points based on session type and difficulty
  static int _calculateBonusPoints(String sessionType, int difficulty, int timeSpentSeconds) {
    int bonus = 0;
    
    // Session type bonus
    switch (sessionType.toLowerCase()) {
      case 'exam':
        bonus += 25;
        break;
      case 'practice':
        bonus += 15;
        break;
      case 'study':
        bonus += 10;
        break;
      default:
        bonus += 5;
    }
    
    // Difficulty bonus
    bonus += difficulty * 5;
    
    // Time efficiency bonus (faster completion = more points)
    if (timeSpentSeconds > 0) {
      final timeEfficiency = 300 / timeSpentSeconds; // 5 minutes reference
      if (timeEfficiency > 1.5) bonus += 15; // Very fast
      else if (timeEfficiency > 1.0) bonus += 10; // Fast
      else if (timeEfficiency > 0.5) bonus += 5; // Normal
    }
    
    return bonus;
  }

  // Check if user should level up
  static Map<String, dynamic> _checkLevelUp(int currentLevel, int totalPoints) {
    final requiredPoints = _getRequiredPointsForLevel(currentLevel + 1);
    
    if (totalPoints >= requiredPoints) {
      return {
        'level': currentLevel + 1,
        'leveled_up': true,
      };
    }
    
    return {
      'level': currentLevel,
      'leveled_up': false,
    };
  }

  // Get required points for each level
  static int _getRequiredPointsForLevel(int level) {
    switch (level) {
      case 1: return 0;   // Starting level
      case 2: return 100; // Level 2
      case 3: return 300; // Level 3
      case 4: return 600; // Level 4
      case 5: return 1000; // Level 5
      case 6: return 1500; // Level 6
      case 7: return 2100; // Level 7
      case 8: return 2800; // Level 8
      case 9: return 3600; // Level 9
      case 10: return 4500; // Level 10
      default: return (level - 1) * 500; // Higher levels
    }
  }

  // Check and award point-based achievements
  static Future<void> _checkPointAchievements(String userId, int totalPoints) async {
    try {
      final pointAchievements = [
        {'points': 100, 'achievement': 'points_100', 'title': 'First 100 Points'},
        {'points': 500, 'achievement': 'points_500', 'title': '500 Points Club'},
        {'points': 1000, 'achievement': 'points_1000', 'title': 'Point Master'},
        {'points': 2500, 'achievement': 'points_2500', 'title': 'Point Champion'},
        {'points': 5000, 'achievement': 'points_5000', 'title': 'Point Legend'},
      ];

      for (final achievement in pointAchievements) {
        final achievementPoints = achievement['points'] as int;
        final achievementId = achievement['achievement'] as String;
        
        if (totalPoints >= achievementPoints) {
          // Check if user already has this achievement
          final userAchievement = await DatabaseService.getUserAchievement(userId, achievementId);
          
          if (userAchievement == null) {
            // Award achievement
            await DatabaseService.unlockAchievement(userId, achievementId);
            
            // Add achievement bonus points
            final currentProfile = await DatabaseService.getUserProfile(userId);
            if (currentProfile != null) {
              final currentPoints = (currentProfile['total_points'] as int?) ?? 0;
              final bonusPoints = achievementPoints ~/ 10; // 10% of target points
              
              await DatabaseService.updateUserProfile({
                'id': userId,
                'total_points': currentPoints + bonusPoints,
                'updated_at': DateTime.now().toIso8601String(),
              });
              
              print('🏆 Point achievement unlocked: ${achievement['title']} (+$bonusPoints bonus points)');
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error checking point achievements: $e');
    }
  }

  // Get level progression information
  static Future<Map<String, dynamic>> getLevelProgress(String userId) async {
    try {
      final profile = await DatabaseService.getUserProfile(userId);
      if (profile == null) {
        return {
          'current_level': 1,
          'current_points': 0,
          'next_level_points': 100,
          'progress_percentage': 0.0,
          'points_to_next_level': 100,
        };
      }

      final currentLevel = (profile['level'] as int?) ?? 1;
      final currentPoints = (profile['total_points'] as int?) ?? 0;
      final nextLevelPoints = _getRequiredPointsForLevel(currentLevel + 1);
      final currentLevelPoints = _getRequiredPointsForLevel(currentLevel);
      
      final pointsInCurrentLevel = currentPoints - currentLevelPoints;
      final pointsToNextLevel = nextLevelPoints - currentPoints;
      final progressPercentage = pointsInCurrentLevel / (nextLevelPoints - currentLevelPoints);

      return {
        'current_level': currentLevel,
        'current_points': currentPoints,
        'next_level_points': nextLevelPoints,
        'progress_percentage': progressPercentage.clamp(0.0, 1.0),
        'points_to_next_level': pointsToNextLevel,
        'points_in_current_level': pointsInCurrentLevel,
      };
    } catch (e) {
      print('❌ Error getting level progress: $e');
      return {
        'current_level': 1,
        'current_points': 0,
        'next_level_points': 100,
        'progress_percentage': 0.0,
        'points_to_next_level': 100,
      };
    }
  }

  // Award points for specific actions
  static Future<void> awardActionPoints({
    required String userId,
    required String action,
    int points = 10,
  }) async {
    try {
      final profile = await DatabaseService.getUserProfile(userId);
      if (profile == null) return;

      final currentPoints = (profile['total_points'] as int?) ?? 0;
      final newTotalPoints = currentPoints + points;

      await DatabaseService.updateUserProfile({
        'id': userId,
        'total_points': newTotalPoints,
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('🎯 Action points awarded: $action (+$points points)');
      print('   - New total: $newTotalPoints points');

      // Check for level up after action points
      final currentLevel = (profile['level'] as int?) ?? 1;
      final levelUpResult = _checkLevelUp(currentLevel, newTotalPoints);
      final newLevel = levelUpResult['level'] as int;
      final leveledUp = levelUpResult['leveled_up'] as bool;

      if (leveledUp) {
        await DatabaseService.updateUserProfile({
          'id': userId,
          'level': newLevel,
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('🎉 LEVEL UP! New level: $newLevel');
      }

    } catch (e) {
      print('❌ Error awarding action points: $e');
    }
  }
}