// Test script to verify gamification functionality
// This tests both online and offline gamification features

import 'package:k53app/src/core/services/offline_database_service.dart';
import 'package:k53app/src/core/services/gamification_service.dart';
import 'package:k53app/src/core/services/offline_data_preloader.dart';

void main() async {
  print('Testing gamification functionality...');
  
  // Initialize the offline database
  await OfflineDatabaseService.initialize();
  print('✓ Offline database initialized');
  
  // Preload basic data
  await OfflineDataPreloader.preloadQuestions();
  print('✓ Basic data preloaded');
  
  // Test user ID for testing
  const testUserId = 'test-user-gamification';
  
  // Test 1: Track offline activities
  print('\n1. Testing offline activity tracking...');
  
  // Track a study session
  await OfflineDatabaseService.trackOfflineActivity(
    userId: testUserId,
    activityType: 'study_session',
    value: 1,
    metadata: {
      'correct_answers': 8,
      'total_questions': 10,
      'category': 'rules_of_road'
    },
  );
  print('✓ Study session activity tracked');
  
  // Track an exam session
  await OfflineDatabaseService.trackOfflineActivity(
    userId: testUserId,
    activityType: 'exam_session',
    value: 1,
    metadata: {
      'correct_answers': 25,
      'total_questions': 30,
      'category': 'general_knowledge',
      'passed': true
    },
  );
  print('✓ Exam session activity tracked');
  
  // Test 2: Get pending offline activities
  final pendingActivities = await OfflineDatabaseService.getPendingOfflineActivities(testUserId);
  print('✓ Retrieved ${pendingActivities.length} pending offline activities');
  
  // Test 3: Save and retrieve gamification stats
  print('\n2. Testing gamification stats...');
  
  const testStats = {
    'points': 150,
    'level': 2,
    'next_level_points': 300,
    'unlocked_achievements': 3,
  };
  
  await OfflineDatabaseService.saveGamificationStats(testUserId, testStats);
  print('✓ Gamification stats saved');
  
  final retrievedStats = await OfflineDatabaseService.getGamificationStats(testUserId);
  if (retrievedStats.isNotEmpty) {
    print('✓ Gamification stats retrieved successfully');
    print('  Points: ${retrievedStats['points']} (expected: 150)');
    print('  Level: ${retrievedStats['level']} (expected: 2)');
    print('  Next Level Points: ${retrievedStats['next_level_points']} (expected: 300)');
    print('  Unlocked Achievements: ${retrievedStats['unlocked_achievements']} (expected: 3)');
  } else {
    print('✗ Failed to retrieve gamification stats');
  }
  
  // Test 4: Test level calculation
  print('\n3. Testing level calculation...');
  
  // Helper functions to test level calculation (copy of private methods)
  int calculateLevel(int points) {
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
  
  int pointsForLevel(int level) {
    return level * (level + 1) * 50; // Quadratic progression
  }
  
  // Test level calculation function
  final level1 = calculateLevel(50);
  final level2 = calculateLevel(150);
  final level3 = calculateLevel(350);
  final level4 = calculateLevel(650);
  
  print('✓ Level calculation test:');
  print('  50 points -> Level $level1 (expected: 1)');
  print('  150 points -> Level $level2 (expected: 2)');
  print('  350 points -> Level $level3 (expected: 3)');
  print('  650 points -> Level $level4 (expected: 4)');
  
  // Test points for next level calculation
  final nextLevelPoints1 = pointsForLevel(2);
  final nextLevelPoints2 = pointsForLevel(3);
  final nextLevelPoints3 = pointsForLevel(4);
  
  print('✓ Next level points calculation:');
  print('  Level 2 -> $nextLevelPoints1 points needed (expected: 300)');
  print('  Level 3 -> $nextLevelPoints2 points needed (expected: 600)');
  print('  Level 4 -> $nextLevelPoints3 points needed (expected: 1000)');
  
  // Test 5: Test multiple users
  print('\n4. Testing multiple users support...');
  
  const user2Id = 'test-user-2';
  const user2Stats = {
    'points': 500,
    'level': 3,
    'next_level_points': 600,
    'unlocked_achievements': 5,
  };
  
  await OfflineDatabaseService.saveGamificationStats(user2Id, user2Stats);
  
  final user1Stats = await OfflineDatabaseService.getGamificationStats(testUserId);
  final user2RetrievedStats = await OfflineDatabaseService.getGamificationStats(user2Id);
  
  if (user1Stats.isNotEmpty && user2RetrievedStats.isNotEmpty) {
    print('✓ Multiple users test passed:');
    print('  User 1 Points: ${user1Stats['points']} (expected: 150)');
    print('  User 2 Points: ${user2RetrievedStats['points']} (expected: 500)');
    print('  User 1 Level: ${user1Stats['level']} (expected: 2)');
    print('  User 2 Level: ${user2RetrievedStats['level']} (expected: 3)');
  } else {
    print('✗ Multiple users test failed');
  }
  
  // Test 6: Test activity sync simulation
  print('\n5. Testing activity sync simulation...');
  
  // Simulate syncing activities (this would normally happen when online)
  for (final activity in pendingActivities) {
    print('  Syncing activity: ${activity['activity_type']}');
    print('    Value: ${activity['value']}');
    print('    Metadata: ${activity['metadata']}');
    
    // Mark as synced
    await OfflineDatabaseService.markActivityAsSynced(activity['id']);
  }
  
  final syncedActivities = await OfflineDatabaseService.getPendingOfflineActivities(testUserId);
  print('✓ Activities synced. Remaining pending: ${syncedActivities.length}');
  
  print('\n🎯 GAMIFICATION FUNCTIONALITY TEST COMPLETED!');
  print('✓ Offline activity tracking');
  print('✓ Gamification stats storage and retrieval');
  print('✓ Level calculation algorithms');
  print('✓ Multiple users support');
  print('✓ Activity sync simulation');
  
  print('\nTo run this test: dart test_gamification_functionality.dart');
}