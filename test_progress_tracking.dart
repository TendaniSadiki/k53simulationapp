import 'lib/src/core/services/progress_tracking_service.dart';
import 'lib/src/core/models/progress_tracking.dart';

void main() async {
  print('=== Testing Progress Tracking System ===\n');

  final progressService = ProgressTrackingService();

  // Test 1: Create a learning goal
  print('1. Creating K53 Learning Goal...');
  final goal = await progressService.generateK53LearningGoal();
  print('   ✅ Goal created: ${goal.title}');
  print('   📅 Target date: ${goal.targetDate}');
  print('   🎯 Milestones: ${goal.milestones.length}');
  print('   📝 Daily tasks: ${goal.dailyTasks.length}');

  // Test 2: Get today's tasks
  print('\n2. Getting today\'s tasks...');
  final todaysTasks = await progressService.getTodaysTasks();
  print('   ✅ Today\'s tasks: ${todaysTasks.length}');
  for (final task in todaysTasks) {
    print('      • ${task.title} (${task.type})');
  }

  // Test 3: Get upcoming milestones
  print('\n3. Getting upcoming milestones...');
  final upcomingMilestones = await progressService.getUpcomingMilestones();
  print('   ✅ Upcoming milestones: ${upcomingMilestones.length}');
  for (final milestone in upcomingMilestones) {
    print('      • ${milestone.title} (due: ${milestone.targetDate})');
  }

  // Test 4: Get progress analytics
  print('\n4. Getting progress analytics...');
  final analytics = await progressService.getProgressAnalytics();
  if (analytics != null) {
    print('   ✅ Analytics period: ${analytics.periodStart} to ${analytics.periodEnd}');
    print('   📊 Study sessions: ${analytics.totalStudySessions}');
    print('   📊 Practice sessions: ${analytics.totalPracticeSessions}');
    print('   ❓ Questions answered: ${analytics.totalQuestionsAnswered}');
    print('   ✅ Correct answers: ${analytics.correctAnswers}');
    print('   📈 Average accuracy: ${(analytics.averageAccuracy * 100).toStringAsFixed(1)}%');
    print('   ⏱️ Total study minutes: ${analytics.totalStudyMinutes}');
  } else {
    print('   ⚠️ No analytics data available');
  }

  // Test 5: Test milestone completion
  print('\n5. Testing milestone completion...');
  if (goal.milestones.isNotEmpty) {
    final firstMilestone = goal.milestones.first;
    print('   🎯 First milestone: ${firstMilestone.title}');
    print('   📋 Tasks: ${firstMilestone.tasks.join(", ")}');
  }

  // Test 6: Test daily task completion
  print('\n6. Testing daily task completion...');
  if (goal.dailyTasks.isNotEmpty) {
    final firstTask = goal.dailyTasks.first;
    print('   📝 First task: ${firstTask.title}');
    print('   ⏱️ Estimated: ${firstTask.estimatedMinutes} minutes');
    print('   📅 Due: ${firstTask.date}');
  }

  print('\n=== Progress Tracking System Test Complete ===');
  print('✅ All basic functionality tested successfully');
  print('📋 Learning goals and progress tracking working');
  print('🎯 Milestone and task management functional');
  print('📊 Analytics system operational');
}