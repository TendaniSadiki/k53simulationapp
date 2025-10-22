import 'package:supabase_flutter/supabase_flutter.dart';
import 'database_service.dart';

class LoginStreakService {
  static final LoginStreakService _instance = LoginStreakService._internal();
  factory LoginStreakService() => _instance;
  LoginStreakService._internal();

  // Track user login and update streak
  static Future<void> trackLogin(String userId) async {
    try {
      // Get user profile to check last login
      final profile = await DatabaseService.getUserProfile(userId);
      if (profile == null) return;

      final now = DateTime.now();
      final lastLoginStr = profile['last_login'] as String?;
      
      DateTime? lastLogin;
      if (lastLoginStr != null) {
        lastLogin = DateTime.parse(lastLoginStr);
      }

      int currentStreak = (profile['login_streak'] as int?) ?? 0;
      int totalPoints = (profile['total_points'] as int?) ?? 0;

      // Check if this is consecutive day login
      if (lastLogin != null) {
        final daysSinceLastLogin = now.difference(lastLogin).inDays;
        
        if (daysSinceLastLogin == 1) {
          // Consecutive day - increment streak
          currentStreak++;
          
          // Award points for consecutive login
          final streakPoints = _calculateStreakPoints(currentStreak);
          totalPoints += streakPoints;
          
          print('🎯 Login streak updated: $currentStreak days (+$streakPoints points)');
        } else if (daysSinceLastLogin > 1) {
          // Streak broken - reset to 1
          currentStreak = 1;
          print('🔄 Login streak reset: 1 day (streak broken)');
        }
        // If same day, don't update streak
      } else {
        // First login - start streak
        currentStreak = 1;
        print('🎉 First login - streak started: 1 day');
      }

      // Update user profile with new streak and points
      await DatabaseService.updateUserProfile({
        'id': userId,
        'login_streak': currentStreak,
        'total_points': totalPoints,
        'last_login': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      // Check for streak achievements
      await _checkStreakAchievements(userId, currentStreak);

    } catch (e) {
      print('❌ Error tracking login streak: $e');
    }
  }

  // Calculate points based on streak length
  static int _calculateStreakPoints(int streak) {
    if (streak >= 30) return 50; // 30+ days streak
    if (streak >= 14) return 25; // 14+ days streak
    if (streak >= 7) return 15;  // 7+ days streak
    if (streak >= 3) return 10;  // 3+ days streak
    return 5; // Daily login bonus
  }

  // Check and award streak achievements
  static Future<void> _checkStreakAchievements(String userId, int streak) async {
    try {
      // Define streak achievements
      final streakAchievements = [
        {'days': 3, 'achievement': 'streak_3_days', 'points': 25},
        {'days': 7, 'achievement': 'streak_7_days', 'points': 50},
        {'days': 14, 'achievement': 'streak_14_days', 'points': 100},
        {'days': 30, 'achievement': 'streak_30_days', 'points': 250},
      ];

      for (final achievement in streakAchievements) {
        final achievementDays = achievement['days'] as int;
        if (streak >= achievementDays) {
          // Check if user already has this achievement
          final userAchievement = await DatabaseService.getUserAchievement(
            userId,
            achievement['achievement'] as String
          );
          
          if (userAchievement == null) {
            // Award achievement
            await DatabaseService.unlockAchievement(
              userId, 
              achievement['achievement'] as String
            );
            
            // Add achievement points
            final currentProfile = await DatabaseService.getUserProfile(userId);
            if (currentProfile != null) {
              final currentPoints = (currentProfile['total_points'] as int?) ?? 0;
              final achievementPoints = achievement['points'] as int;
              
              await DatabaseService.updateUserProfile({
                'id': userId,
                'total_points': currentPoints + achievementPoints,
                'updated_at': DateTime.now().toIso8601String(),
              });
              
              print('🏆 Streak achievement unlocked: ${achievement['achievement']} (+${achievement['points']} points)');
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error checking streak achievements: $e');
    }
  }

  // Get current streak information
  static Future<Map<String, dynamic>> getStreakInfo(String userId) async {
    try {
      final profile = await DatabaseService.getUserProfile(userId);
      if (profile == null) {
        return {
          'current_streak': 0,
          'next_streak_bonus': 5,
          'days_to_next_milestone': 3,
          'milestone_points': 25,
        };
      }

      final currentStreak = (profile['total_points'] as int?) ?? 0;
      final lastLoginStr = profile['last_login'] as String?;
      
      DateTime? lastLogin;
      if (lastLoginStr != null) {
        lastLogin = DateTime.parse(lastLoginStr);
      }

      // Calculate next milestone
      final nextMilestone = _getNextStreakMilestone(currentStreak);
      final daysToNextMilestone = nextMilestone['days'] - currentStreak;

      return {
        'current_streak': currentStreak,
        'next_streak_bonus': _calculateStreakPoints(currentStreak + 1),
        'days_to_next_milestone': daysToNextMilestone > 0 ? daysToNextMilestone : 0,
        'milestone_points': nextMilestone['points'],
        'last_login': lastLogin,
        'is_streak_active': _isStreakActive(lastLogin),
      };
    } catch (e) {
      print('❌ Error getting streak info: $e');
      return {
        'current_streak': 0,
        'next_streak_bonus': 5,
        'days_to_next_milestone': 3,
        'milestone_points': 25,
        'is_streak_active': false,
      };
    }
  }

  // Get next streak milestone
  static Map<String, dynamic> _getNextStreakMilestone(int currentStreak) {
    final milestones = [
      {'days': 3, 'points': 25},
      {'days': 7, 'points': 50},
      {'days': 14, 'points': 100},
      {'days': 30, 'points': 250},
    ];

    for (final milestone in milestones) {
      final milestoneDays = milestone['days'] as int;
      if (currentStreak < milestoneDays) {
        return milestone;
      }
    }

    // If all milestones achieved, return the highest one
    return {'days': 30, 'points': 250};
  }

  // Check if streak is still active (logged in today)
  static bool _isStreakActive(DateTime? lastLogin) {
    if (lastLogin == null) return false;
    
    final now = DateTime.now();
    return now.difference(lastLogin).inDays == 0;
  }

  // Reset streak if user misses a day
  static Future<void> resetStreak(String userId) async {
    try {
      await DatabaseService.updateUserProfile({
        'id': userId,
        'login_streak': 0,
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('🔄 Login streak reset for user: $userId');
    } catch (e) {
      print('❌ Error resetting streak: $e');
    }
  }
}