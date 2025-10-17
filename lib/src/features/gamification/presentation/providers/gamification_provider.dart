import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/gamification_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/database_service.dart';

final gamificationProvider = StateNotifierProvider<GamificationProvider, GamificationState>((ref) {
  return GamificationProvider();
});

class GamificationState {
  final int totalPoints;
  final int level;
  final List<GamificationAchievement> unlockedAchievements;
  final List<GamificationAchievement> availableAchievements;
  final bool isLoading;
  final String? error;
  final Map<String, int> categoryPoints;
  final int streakDays;
  final DateTime? lastActivityDate;

  GamificationState({
    this.totalPoints = 0,
    this.level = 1,
    this.unlockedAchievements = const [],
    this.availableAchievements = const [],
    this.isLoading = false,
    this.error,
    this.categoryPoints = const {},
    this.streakDays = 0,
    this.lastActivityDate,
  });

  GamificationState copyWith({
    int? totalPoints,
    int? level,
    List<GamificationAchievement>? unlockedAchievements,
    List<GamificationAchievement>? availableAchievements,
    bool? isLoading,
    String? error,
    Map<String, int>? categoryPoints,
    int? streakDays,
    DateTime? lastActivityDate,
  }) {
    return GamificationState(
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      availableAchievements: availableAchievements ?? this.availableAchievements,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      categoryPoints: categoryPoints ?? this.categoryPoints,
      streakDays: streakDays ?? this.streakDays,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }

  int get pointsToNextLevel {
    // Simple level progression: 1000 points per level
    return (level * 1000) - totalPoints;
  }

  double get levelProgress {
    final currentLevelPoints = totalPoints - ((level - 1) * 1000);
    return currentLevelPoints / 1000;
  }

  bool get hasNewAchievements {
    return unlockedAchievements.any((achievement) => achievement.isNew);
  }

  int get achievementCount => unlockedAchievements.length;
  int get totalAchievements => availableAchievements.length;
}

class GamificationAchievement {
  final String id;
  final String title;
  final String description;
  final int points;
  final AchievementType type;
  final int targetValue;
  final int currentProgress;
  final bool isUnlocked;
  final bool isNew;
  final DateTime? unlockedAt;

  GamificationAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.type,
    required this.targetValue,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.isNew = false,
    this.unlockedAt,
  });

  double get progressPercentage {
    return currentProgress / targetValue;
  }

  bool get isInProgress => !isUnlocked && currentProgress > 0;

  GamificationAchievement copyWith({
    String? id,
    String? title,
    String? description,
    int? points,
    AchievementType? type,
    int? targetValue,
    int? currentProgress,
    bool? isUnlocked,
    bool? isNew,
    DateTime? unlockedAt,
  }) {
    return GamificationAchievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      points: points ?? this.points,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isNew: isNew ?? this.isNew,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

enum AchievementType {
  studyStreak,
  perfectScore,
  categoryMaster,
  speedDemon,
  persistence,
  social,
}

class GamificationProvider extends StateNotifier<GamificationState> {
  GamificationProvider() : super(GamificationState());

  // Load user gamification data
  Future<void> loadUserData(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Load user profile for points and level
      final userProfile = await DatabaseService.getUserProfile(userId);
      if (userProfile != null) {
        final totalPoints = userProfile['total_points'] as int? ?? 0;
        final level = userProfile['level'] as int? ?? 1;
        final streakDays = userProfile['streak_days'] as int? ?? 0;
        final lastActivity = userProfile['last_activity'] as String?;

        // Load achievements
        final unlockedAchievements = await _loadUnlockedAchievements(userId);
        final availableAchievements = await _loadAvailableAchievements();

        state = state.copyWith(
          totalPoints: totalPoints,
          level: level,
          streakDays: streakDays,
          lastActivityDate: lastActivity != null ? DateTime.parse(lastActivity) : null,
          unlockedAchievements: unlockedAchievements,
          availableAchievements: availableAchievements,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load user data: $e',
      );
    }
  }

  // Award points for an activity
  Future<void> awardPoints({
    required String userId,
    required int points,
    required String activityType,
    String? category,
    String? sessionId,
  }) async {
    try {
      // Update local state
      final newTotalPoints = state.totalPoints + points;
      final newLevel = _calculateLevel(newTotalPoints);

      // Update category points
      final newCategoryPoints = Map<String, int>.from(state.categoryPoints);
      if (category != null) {
        newCategoryPoints[category] = (newCategoryPoints[category] ?? 0) + points;
      }

      state = state.copyWith(
        totalPoints: newTotalPoints,
        level: newLevel,
        categoryPoints: newCategoryPoints,
      );

      // Update database
      await GamificationService().awardGamingPoints(
        points: points,
        reason: activityType,
        metadata: {
          'category': category,
          'session_id': sessionId,
        },
      );

      // Check for achievements
      await _checkAchievements(userId, activityType, points);

      // Track analytics
      await AnalyticsService.trackGamificationEvent(
        eventType: 'points_awarded',
        points: points,
        metadata: {
          'activity_type': activityType,
          'category': category,
          'session_id': sessionId,
        },
      );

    } catch (e) {
      state = state.copyWith(
        error: 'Failed to award points: $e',
      );
    }
  }

  // Unlock an achievement
  Future<void> unlockAchievement({
    required String userId,
    required String achievementId,
  }) async {
    try {
      final achievement = state.availableAchievements.firstWhere(
        (a) => a.id == achievementId,
      );

      final unlockedAchievement = achievement.copyWith(
        isUnlocked: true,
        isNew: true,
        unlockedAt: DateTime.now(),
      );

      // Update unlocked achievements list
      final newUnlockedAchievements = List<GamificationAchievement>.from(state.unlockedAchievements);
      newUnlockedAchievements.add(unlockedAchievement);

      // Remove from available achievements
      final newAvailableAchievements = state.availableAchievements
          .where((a) => a.id != achievementId)
          .toList();

      state = state.copyWith(
        unlockedAchievements: newUnlockedAchievements,
        availableAchievements: newAvailableAchievements,
      );

      // Award points for achievement
      await awardPoints(
        userId: userId,
        points: achievement.points,
        activityType: 'achievement_unlocked',
      );

      // Track analytics
      await AnalyticsService.trackGamificationEvent(
        eventType: 'achievement_unlocked',
        points: achievement.points,
        achievementId: achievementId,
        metadata: {
          'achievement_title': achievement.title,
          'achievement_type': achievement.type.toString(),
        },
      );

    } catch (e) {
      state = state.copyWith(
        error: 'Failed to unlock achievement: $e',
      );
    }
  }

  // Update streak
  Future<void> updateStreak(String userId) async {
    try {
      final today = DateTime.now();
      final lastActivity = state.lastActivityDate;

      int newStreakDays = state.streakDays;

      if (lastActivity != null) {
        final yesterday = today.subtract(const Duration(days: 1));
        if (lastActivity.isAtSameMomentAs(yesterday)) {
          // Continue streak
          newStreakDays++;
        } else if (!lastActivity.isAtSameMomentAs(today)) {
          // Reset streak
          newStreakDays = 1;
        }
      } else {
        // First activity
        newStreakDays = 1;
      }

      state = state.copyWith(
        streakDays: newStreakDays,
        lastActivityDate: today,
      );

      // Update database
      await DatabaseService.updateUserProfile({
        'id': userId,
        'streak_days': newStreakDays,
        'last_activity': today.toIso8601String(),
      });

      // Check for streak achievements
      await _checkStreakAchievements(userId, newStreakDays);

    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update streak: $e',
      );
    }
  }

  // Mark achievements as seen
  void markAchievementsAsSeen() {
    final updatedAchievements = state.unlockedAchievements
        .map((achievement) => achievement.copyWith(isNew: false))
        .toList();

    state = state.copyWith(
      unlockedAchievements: updatedAchievements,
    );
  }

  // Get leaderboard data
  Future<List<Map<String, dynamic>>> getLeaderboard({
    String? category,
    int limit = 10,
  }) async {
    try {
      // This would typically query a leaderboard table
      // For now, return mock data
      return [
        {
          'user_id': 'user1',
          'username': 'TopLearner',
          'total_points': 5000,
          'level': 5,
          'rank': 1,
        },
        {
          'user_id': 'user2',
          'username': 'QuickStudy',
          'total_points': 4500,
          'level': 4,
          'rank': 2,
        },
        {
          'user_id': 'user3',
          'username': 'RoadMaster',
          'total_points': 4000,
          'level': 4,
          'rank': 3,
        },
      ];
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load leaderboard: $e',
      );
      return [];
    }
  }

  // Helper methods
  int _calculateLevel(int totalPoints) {
    return (totalPoints / 1000).floor() + 1;
  }

  Future<List<GamificationAchievement>> _loadUnlockedAchievements(String userId) async {
    try {
      final userAchievements = await DatabaseService.getUserAchievements(userId);
      return userAchievements.map((data) {
        return GamificationAchievement(
          id: data['achievement_id'] as String,
          title: data['title'] as String? ?? 'Unknown Achievement',
          description: data['description'] as String? ?? '',
          points: data['points'] as int? ?? 0,
          type: AchievementType.values.firstWhere(
            (type) => type.toString() == data['type'],
            orElse: () => AchievementType.studyStreak,
          ),
          targetValue: data['target_value'] as int? ?? 0,
          currentProgress: data['progress'] as int? ?? 0,
          isUnlocked: true,
          unlockedAt: data['unlocked_at'] != null 
              ? DateTime.parse(data['unlocked_at'] as String)
              : null,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<GamificationAchievement>> _loadAvailableAchievements() async {
    // Return predefined achievements
    return [
      GamificationAchievement(
        id: 'first_study',
        title: 'First Steps',
        description: 'Complete your first study session',
        points: 100,
        type: AchievementType.studyStreak,
        targetValue: 1,
      ),
      GamificationAchievement(
        id: 'perfect_score',
        title: 'Perfect Score',
        description: 'Get 100% correct in a study session',
        points: 250,
        type: AchievementType.perfectScore,
        targetValue: 1,
      ),
      GamificationAchievement(
        id: 'streak_7',
        title: 'Weekly Warrior',
        description: 'Maintain a 7-day study streak',
        points: 500,
        type: AchievementType.studyStreak,
        targetValue: 7,
      ),
      GamificationAchievement(
        id: 'category_master',
        title: 'Category Master',
        description: 'Master all questions in a category',
        points: 300,
        type: AchievementType.categoryMaster,
        targetValue: 1,
      ),
      GamificationAchievement(
        id: 'speed_demon',
        title: 'Speed Demon',
        description: 'Answer 10 questions in under 2 minutes',
        points: 200,
        type: AchievementType.speedDemon,
        targetValue: 10,
      ),
    ];
  }

  Future<void> _checkAchievements(String userId, String activityType, int points) async {
    // Check various achievement conditions
    await _checkStudyAchievements(userId, activityType);
    await _checkPointsAchievements(userId);
    await _checkCategoryAchievements(userId);
  }

  Future<void> _checkStudyAchievements(String userId, String activityType) async {
    if (activityType == 'study_completed') {
      // Check for first study achievement
      final firstStudy = state.availableAchievements
          .firstWhere((a) => a.id == 'first_study' && !a.isUnlocked);
      
      if (firstStudy.id.isNotEmpty) {
        await unlockAchievement(
          userId: userId,
          achievementId: firstStudy.id,
        );
      }
    }
  }

  Future<void> _checkPointsAchievements(String userId) async {
    // Check for points-based achievements
    if (state.totalPoints >= 1000) {
      final pointsAchievement = state.availableAchievements
          .firstWhere((a) => a.id == 'points_1000' && !a.isUnlocked);
      
      if (pointsAchievement.id.isNotEmpty) {
        await unlockAchievement(
          userId: userId,
          achievementId: pointsAchievement.id,
        );
      }
    }
  }

  Future<void> _checkCategoryAchievements(String userId) async {
    // Check for category mastery achievements
    for (final category in state.categoryPoints.keys) {
      if (state.categoryPoints[category]! >= 1000) {
        final categoryAchievement = state.availableAchievements
            .firstWhere((a) => a.id == '${category}_master' && !a.isUnlocked);
        
        if (categoryAchievement.id.isNotEmpty) {
          await unlockAchievement(
            userId: userId,
            achievementId: categoryAchievement.id,
          );
        }
      }
    }
  }

  Future<void> _checkStreakAchievements(String userId, int streakDays) async {
    if (streakDays >= 7) {
      final streakAchievement = state.availableAchievements
          .firstWhere((a) => a.id == 'streak_7' && !a.isUnlocked);
      
      if (streakAchievement.id.isNotEmpty) {
        await unlockAchievement(
          userId: userId,
          achievementId: streakAchievement.id,
        );
      }
    }
  }
}