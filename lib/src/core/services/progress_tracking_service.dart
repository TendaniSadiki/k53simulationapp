import './session_database_service.dart';
import '../models/session.dart';
import '../models/question.dart';
import '../models/progress_tracking.dart';

class ProgressTrackingService {
  static Future<ProgressStats> getUserProgress(String userId) async {
    await SessionDatabaseService.database; // Initialize database connection

    // Get all user sessions
    final sessions = await SessionDatabaseService.getUserSessions(userId);

    // Get all session answers
    final allAnswers = <SessionAnswer>[];
    for (final session in sessions) {
      final answers = await SessionDatabaseService.getSessionAnswers(
        session.id,
      );
      allAnswers.addAll(answers);
    }

    // Calculate overall statistics
    final totalQuestions = allAnswers.length;
    final correctAnswers = allAnswers.where((a) => a.isCorrect).length;
    final accuracy = totalQuestions > 0 ? correctAnswers / totalQuestions : 0;
    final totalPoints = allAnswers.fold(
      0,
      (sum, answer) => sum + answer.pointsAwarded,
    );

    // Calculate category progress
    final categoryStats = await _getCategoryProgress(userId);

    // Calculate daily progress
    final dailyStats = await _getDailyProgress(userId);

    // Calculate streak
    final streak = await _calculateStreak(userId);

    return ProgressStats(
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      accuracy: accuracy.toDouble(),
      totalPoints: totalPoints,
      categoryStats: categoryStats,
      dailyStats: dailyStats,
      currentStreak: streak,
      sessionsCompleted: sessions.where((s) => s.isCompleted).length,
    );
  }

  static Future<Map<String, CategoryProgress>> _getCategoryProgress(
    String userId,
  ) async {
    await SessionDatabaseService.database; // Initialize database connection

    // Get all session answers with their questions
    final sessions = await SessionDatabaseService.getUserSessions(userId);
    final categoryStats = <String, CategoryProgress>{};

    for (final session in sessions) {
      final answers = await SessionDatabaseService.getSessionAnswers(
        session.id,
      );
      final questions = await SessionDatabaseService.getSessionQuestions(
        session.id,
      );

      for (final answer in answers) {
        final question = questions.firstWhere(
          (q) => q.id == answer.questionId,
          orElse: () => Question(
            id: '',
            category: 'Unknown',
            learnerCode: 0,
            questionText: '',
            options: [],
            correctIndex: 0,
            explanation: '',
            version: 1,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        final category = question.category;
        if (!categoryStats.containsKey(category)) {
          categoryStats[category] = CategoryProgress(
            category: category,
            totalQuestions: 0,
            correctAnswers: 0,
          );
        }

        final stats = categoryStats[category]!;
        categoryStats[category] = stats.copyWith(
          totalQuestions: stats.totalQuestions + 1,
          correctAnswers: stats.correctAnswers + (answer.isCorrect ? 1 : 0),
        );
      }
    }

    return categoryStats;
  }

  static Future<Map<DateTime, DailyProgress>> _getDailyProgress(
    String userId,
  ) async {
    await SessionDatabaseService.database; // Initialize database connection
    final dailyStats = <DateTime, DailyProgress>{};

    // Get all session answers grouped by date
    final sessions = await SessionDatabaseService.getUserSessions(userId);

    for (final session in sessions) {
      final answers = await SessionDatabaseService.getSessionAnswers(
        session.id,
      );

      for (final answer in answers) {
        final date = DateTime(
          answer.answeredAt.year,
          answer.answeredAt.month,
          answer.answeredAt.day,
        );

        if (!dailyStats.containsKey(date)) {
          dailyStats[date] = DailyProgress(
            date: date,
            questionsAnswered: 0,
            correctAnswers: 0,
            pointsEarned: 0,
          );
        }

        final stats = dailyStats[date]!;
        dailyStats[date] = stats.copyWith(
          questionsAnswered: stats.questionsAnswered + 1,
          correctAnswers: stats.correctAnswers + (answer.isCorrect ? 1 : 0),
          pointsEarned: stats.pointsEarned + answer.pointsAwarded,
        );
      }
    }

    return dailyStats;
  }

  static Future<int> _calculateStreak(String userId) async {
    final dailyStats = await _getDailyProgress(userId);
    final dates = dailyStats.keys.toList()..sort();

    if (dates.isEmpty) return 0;

    // Check consecutive days from today backwards
    var streak = 0;
    var currentDate = DateTime.now();

    while (true) {
      final dateKey = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );

      if (dates.any(
        (date) =>
            date.year == dateKey.year &&
            date.month == dateKey.month &&
            date.day == dateKey.day,
      )) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  static Future<List<SessionProgress>> getSessionProgress(String userId) async {
    final sessions = await SessionDatabaseService.getUserSessions(userId);
    final sessionProgress = <SessionProgress>[];

    for (final session in sessions) {
      final answers = await SessionDatabaseService.getSessionAnswers(
        session.id,
      );
      final totalPoints = await SessionDatabaseService.getSessionTotalPoints(
        session.id,
      );

      sessionProgress.add(
        SessionProgress(
          session: session,
          totalPoints: totalPoints,
          answers: answers,
        ),
      );
    }

    return sessionProgress;
  }

  static Future<Map<String, dynamic>> getLearningInsights(String userId) async {
    final progress = await getUserProgress(userId);
    final sessions = await getSessionProgress(userId);

    // Calculate insights
    final totalStudyTime = sessions.fold<Duration>(Duration.zero, (
      total,
      session,
    ) {
      final sessionDuration = session.answers.fold<Duration>(
        Duration.zero,
        (sum, answer) => sum + Duration(milliseconds: answer.elapsedMs),
      );
      return total + sessionDuration;
    });

    final averageAccuracy = progress.accuracy;
    final bestCategory = progress.categoryStats.entries
        .where((entry) => entry.value.totalQuestions >= 5)
        .fold<MapEntry<String, CategoryProgress>?>(null, (best, current) {
          final currentAccuracy = current.value.accuracy;
          final bestAccuracy = best?.value.accuracy ?? 0;
          return currentAccuracy > bestAccuracy ? current : best;
        });

    final weakestCategory = progress.categoryStats.entries
        .where((entry) => entry.value.totalQuestions >= 5)
        .fold<MapEntry<String, CategoryProgress>?>(null, (weakest, current) {
          final currentAccuracy = current.value.accuracy;
          final weakestAccuracy = weakest?.value.accuracy ?? 1.0;
          return currentAccuracy < weakestAccuracy ? current : weakest;
        });

    return {
      'totalStudyTime': totalStudyTime,
      'averageAccuracy': averageAccuracy,
      'bestCategory': bestCategory?.key ?? 'N/A',
      'bestCategoryAccuracy': bestCategory?.value.accuracy ?? 0,
      'weakestCategory': weakestCategory?.key ?? 'N/A',
      'weakestCategoryAccuracy': weakestCategory?.value.accuracy ?? 0,
      'totalSessions': sessions.length,
      'currentStreak': progress.currentStreak,
      'totalPoints': progress.totalPoints,
    };
  }

  // Learning Goals Operations
  Future<List<LearningGoal>> getUserLearningGoals() async {
    try {
      // For now, return empty list - in production, this would fetch from database
      // This method should be implemented to fetch actual user goals from the database
      return [];
    } catch (e) {
      // Error getting user learning goals: $e
      return [];
    }
  }

  Future<ProgressAnalytics?> getProgressAnalytics() async {
    try {
      // For now, return null - in production, this would calculate analytics
      // This method should be implemented to calculate actual progress analytics
      return null;
    } catch (e) {
      // Error getting progress analytics: $e
      return null;
    }
  }

  Future<LearningGoal> generateK53LearningGoal() async {
    // Generate a sample K53 learning goal
    final now = DateTime.now();
    final targetDate = now.add(const Duration(days: 30));

    return LearningGoal(
      id: 'k53_goal_${now.millisecondsSinceEpoch}',
      title: 'K53 Learner\'s License Preparation',
      description:
          'Complete comprehensive preparation for K53 learner\'s license test covering all road signs, rules, and vehicle controls',
      targetDate: targetDate,
      createdAt: now,
      updatedAt: now,
      status: GoalStatus.active,
      milestones: [
        Milestone(
          id: 'milestone_1',
          title: 'Road Signs Mastery',
          description: 'Learn and memorize all road signs and their meanings',
          targetDate: now.add(const Duration(days: 7)),
          type: MilestoneType.knowledge,
        ),
        Milestone(
          id: 'milestone_2',
          title: 'Rules of the Road',
          description: 'Understand and apply all traffic rules and regulations',
          targetDate: now.add(const Duration(days: 14)),
          type: MilestoneType.knowledge,
        ),
        Milestone(
          id: 'milestone_3',
          title: 'Practice Tests',
          description: 'Complete multiple practice tests with 80%+ accuracy',
          targetDate: now.add(const Duration(days: 21)),
          type: MilestoneType.practice,
        ),
        Milestone(
          id: 'milestone_4',
          title: 'Final Review',
          description: 'Review weak areas and take final assessment',
          targetDate: targetDate,
          type: MilestoneType.assessment,
        ),
      ],
      dailyTasks: [
        DailyTask(
          id: 'daily_1',
          title: 'Study Road Signs',
          description: 'Review 10 new road signs daily',
          date: now,
          type: TaskType.study,
          estimatedMinutes: 30,
        ),
        DailyTask(
          id: 'daily_2',
          title: 'Practice Questions',
          description: 'Complete 20 practice questions',
          date: now,
          type: TaskType.practice,
          estimatedMinutes: 20,
        ),
      ],
    );
  }

  Future<void> createLearningGoal({
    required String title,
    required String description,
    required DateTime targetDate,
    List<Milestone> milestones = const [],
    List<DailyTask> dailyTasks = const [],
  }) async {
    try {
      // For now, just log - in production, this would save to database
      // Creating learning goal: $title
      // Description: $description
      // Target Date: $targetDate
      // Milestones: ${milestones.length}
      // Daily Tasks: ${dailyTasks.length}
      
      // This method should be implemented to save the goal to the database
      // await DatabaseService.saveLearningGoal(userId, goalData);
    } catch (e) {
      // Error creating learning goal: $e
    }
  }

  Future<List<DailyTask>> getTodaysTasks() async {
    try {
      // For now, return empty list - in production, this would fetch today's tasks
      return [];
    } catch (e) {
      // Error getting today's tasks: $e
      return [];
    }
  }

  Future<List<Milestone>> getUpcomingMilestones() async {
    try {
      // For now, return empty list - in production, this would fetch upcoming milestones
      return [];
    } catch (e) {
      // Error getting upcoming milestones: $e
      return [];
    }
  }
}

class ProgressStats {
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;
  final int totalPoints;
  final Map<String, CategoryProgress> categoryStats;
  final Map<DateTime, DailyProgress> dailyStats;
  final int currentStreak;
  final int sessionsCompleted;

  const ProgressStats({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
    required this.totalPoints,
    required this.categoryStats,
    required this.dailyStats,
    required this.currentStreak,
    required this.sessionsCompleted,
  });

  ProgressStats copyWith({
    int? totalQuestions,
    int? correctAnswers,
    double? accuracy,
    int? totalPoints,
    Map<String, CategoryProgress>? categoryStats,
    Map<DateTime, DailyProgress>? dailyStats,
    int? currentStreak,
    int? sessionsCompleted,
  }) {
    return ProgressStats(
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      accuracy: accuracy ?? this.accuracy,
      totalPoints: totalPoints ?? this.totalPoints,
      categoryStats: categoryStats ?? this.categoryStats,
      dailyStats: dailyStats ?? this.dailyStats,
      currentStreak: currentStreak ?? this.currentStreak,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
    );
  }
}

class CategoryProgress {
  final String category;
  final int totalQuestions;
  final int correctAnswers;

  const CategoryProgress({
    required this.category,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  double get accuracy =>
      totalQuestions > 0 ? correctAnswers / totalQuestions : 0;

  CategoryProgress copyWith({
    String? category,
    int? totalQuestions,
    int? correctAnswers,
  }) {
    return CategoryProgress(
      category: category ?? this.category,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
    );
  }
}

class DailyProgress {
  final DateTime date;
  final int questionsAnswered;
  final int correctAnswers;
  final int pointsEarned;

  const DailyProgress({
    required this.date,
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.pointsEarned,
  });

  double get accuracy =>
      questionsAnswered > 0 ? correctAnswers / questionsAnswered : 0;

  DailyProgress copyWith({
    DateTime? date,
    int? questionsAnswered,
    int? correctAnswers,
    int? pointsEarned,
  }) {
    return DailyProgress(
      date: date ?? this.date,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      pointsEarned: pointsEarned ?? this.pointsEarned,
    );
  }
}

class SessionProgress {
  final Session session;
  final int totalPoints;
  final List<SessionAnswer> answers;

  const SessionProgress({
    required this.session,
    required this.totalPoints,
    required this.answers,
  });

  double get accuracy => session.totalAnswered > 0
      ? session.correctAnswers / session.totalAnswered
      : 0;
  Duration get totalTime => answers.fold<Duration>(
    Duration.zero,
    (sum, answer) => sum + Duration(milliseconds: answer.elapsedMs),
  );
}
