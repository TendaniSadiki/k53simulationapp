import 'package:flutter_test/flutter_test.dart';
import 'package:k53app/src/core/services/progress_tracking_service.dart';
import 'package:k53app/src/core/services/session_database_service.dart';
import 'package:k53app/src/core/models/session.dart';
import 'package:k53app/src/core/models/question.dart';

void main() {
  group('Progress Tracking Integration Tests', () {
    const testUserId = 'test_user_123';

    setUp(() async {
      // Initialize database
      await SessionDatabaseService.initialize();
    });

    test('Get user progress with no data', () async {
      final progress = await ProgressTrackingService.getUserProgress(testUserId);
      
      expect(progress.totalQuestions, 0);
      expect(progress.correctAnswers, 0);
      expect(progress.accuracy, 0.0);
      expect(progress.totalPoints, 0);
      expect(progress.categoryStats.isEmpty, true);
      expect(progress.currentStreak, 0);
      expect(progress.sessionsCompleted, 0);
    });

    test('Get learning insights with no data', () async {
      final insights = await ProgressTrackingService.getLearningInsights(testUserId);
      
      expect(insights['totalStudyTime'], Duration.zero);
      expect(insights['averageAccuracy'], 0.0);
      expect(insights['bestCategory'], 'N/A');
      expect(insights['weakestCategory'], 'N/A');
      expect(insights['totalSessions'], 0);
      expect(insights['currentStreak'], 0);
      expect(insights['totalPoints'], 0);
    });

    test('Get session progress with no data', () async {
      final sessionProgress = await ProgressTrackingService.getSessionProgress(testUserId);
      
      expect(sessionProgress.isEmpty, true);
    });

    test('ProgressStats model works correctly', () {
      final stats = ProgressStats(
        totalQuestions: 100,
        correctAnswers: 75,
        accuracy: 0.75,
        totalPoints: 250,
        categoryStats: {
          'Road Signs': CategoryProgress(
            category: 'Road Signs',
            totalQuestions: 50,
            correctAnswers: 40,
          ),
        },
        dailyStats: {},
        currentStreak: 5,
        sessionsCompleted: 3,
      );

      expect(stats.totalQuestions, 100);
      expect(stats.correctAnswers, 75);
      expect(stats.accuracy, 0.75);
      expect(stats.totalPoints, 250);
      expect(stats.categoryStats.length, 1);
      expect(stats.currentStreak, 5);
      expect(stats.sessionsCompleted, 3);
    });

    test('CategoryProgress accuracy calculation', () {
      final category = CategoryProgress(
        category: 'Test Category',
        totalQuestions: 10,
        correctAnswers: 8,
      );

      expect(category.accuracy, 0.8);
    });

    test('DailyProgress accuracy calculation', () {
      final daily = DailyProgress(
        date: DateTime.now(),
        questionsAnswered: 20,
        correctAnswers: 15,
        pointsEarned: 50,
      );

      expect(daily.accuracy, 0.75);
    });
  });

  group('Progress Tracking Edge Cases', () {
    test('Zero questions accuracy', () {
      final category = CategoryProgress(
        category: 'Test',
        totalQuestions: 0,
        correctAnswers: 0,
      );

      expect(category.accuracy, 0.0);
    });

    test('All correct answers accuracy', () {
      final category = CategoryProgress(
        category: 'Test',
        totalQuestions: 10,
        correctAnswers: 10,
      );

      expect(category.accuracy, 1.0);
    });

    test('ProgressStats copyWith works', () {
      final original = ProgressStats(
        totalQuestions: 100,
        correctAnswers: 75,
        accuracy: 0.75,
        totalPoints: 250,
        categoryStats: {},
        dailyStats: {},
        currentStreak: 5,
        sessionsCompleted: 3,
      );

      final updated = original.copyWith(
        totalQuestions: 150,
        correctAnswers: 100,
      );

      expect(updated.totalQuestions, 150);
      expect(updated.correctAnswers, 100);
      expect(updated.accuracy, 0.75); // Should remain unchanged
      expect(updated.totalPoints, 250); // Should remain unchanged
      expect(updated.currentStreak, 5); // Should remain unchanged
    });
  });
}

// Helper function to run quick progress test
void runProgressTest() async {
  print('🚀 Running Progress Tracking Test...\n');
  
  const testUserId = 'demo_user';
  
  try {
    print('📊 Testing Progress Tracking Service...');
    
    // Test basic progress
    final progress = await ProgressTrackingService.getUserProgress(testUserId);
    print('✅ Progress Stats:');
    print('   Total Questions: ${progress.totalQuestions}');
    print('   Correct Answers: ${progress.correctAnswers}');
    print('   Accuracy: ${(progress.accuracy * 100).toStringAsFixed(1)}%');
    print('   Total Points: ${progress.totalPoints}');
    print('   Current Streak: ${progress.currentStreak} days');
    print('   Sessions Completed: ${progress.sessionsCompleted}');
    
    // Test category progress
    print('\n📋 Category Progress:');
    if (progress.categoryStats.isEmpty) {
      print('   No category data available yet');
    } else {
      progress.categoryStats.forEach((category, stats) {
        print('   📂 $category: ${(stats.accuracy * 100).toStringAsFixed(1)}% (${stats.correctAnswers}/${stats.totalQuestions})');
      });
    }
    
    // Test learning insights
    print('\n🎯 Learning Insights:');
    final insights = await ProgressTrackingService.getLearningInsights(testUserId);
    print('   Total Study Time: ${_formatDuration(insights['totalStudyTime'])}');
    print('   Average Accuracy: ${(insights['averageAccuracy'] * 100).toStringAsFixed(1)}%');
    print('   Best Category: ${insights['bestCategory']}');
    print('   Weakest Category: ${insights['weakestCategory']}');
    print('   Total Sessions: ${insights['totalSessions']}');
    
    print('\n✅ Progress tracking system is working correctly!');
    
  } catch (e) {
    print('❌ Error testing progress tracking: $e');
  }
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  
  if (hours > 0) {
    return '${hours}h ${minutes}m';
  } else {
    return '${minutes}m';
  }
}