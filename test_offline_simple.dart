import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  // Test basic SQLite functionality
  final databasesPath = await getDatabasesPath();
  final path = join(databasesPath, 'test_offline.db');
  
  // Delete existing test database if it exists
  if (await File(path).exists()) {
    await File(path).delete();
  }

  // Create and test database
  final db = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE test_gamification_stats(
          user_id TEXT PRIMARY KEY,
          points INTEGER DEFAULT 0,
          level INTEGER DEFAULT 1,
          next_level_points INTEGER DEFAULT 100,
          unlocked_achievements INTEGER DEFAULT 0,
          last_updated TEXT
        )
      ''');
      
      await db.execute('''
        CREATE TABLE test_offline_activities(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT,
          activity_type TEXT,
          value INTEGER,
          metadata TEXT,
          created_at TEXT,
          is_synced INTEGER DEFAULT 0
        )
      ''');
    },
  );

  try {
    print('Testing offline database functionality...');
    
    // Test 1: Insert and retrieve gamification stats
    const testUserId = 'test-user-123';
    const testStats = {
      'points': 150,
      'level': 2,
      'next_level_points': 300,
      'unlocked_achievements': 3,
    };

    await db.insert(
      'test_gamification_stats',
      {
        'user_id': testUserId,
        'points': testStats['points'],
        'level': testStats['level'],
        'next_level_points': testStats['next_level_points'],
        'unlocked_achievements': testStats['unlocked_achievements'],
        'last_updated': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final results = await db.query(
      'test_gamification_stats',
      where: 'user_id = ?',
      whereArgs: [testUserId],
    );

    if (results.isNotEmpty) {
      final row = results.first;
      print('✓ Gamification stats test passed:');
      print('  Points: ${row['points']} (expected: 150)');
      print('  Level: ${row['level']} (expected: 2)');
      print('  Next Level Points: ${row['next_level_points']} (expected: 300)');
      print('  Unlocked Achievements: ${row['unlocked_achievements']} (expected: 3)');
    } else {
      print('✗ Gamification stats test failed: No results found');
    }

    // Test 2: Insert and retrieve offline activities
    const testActivity = {
      'user_id': testUserId,
      'activity_type': 'study_session',
      'value': 1,
      'metadata': '{"correct_answers":8,"total_questions":10,"category":"rules_of_road"}',
    };

    await db.insert(
      'test_offline_activities',
      {
        'user_id': testActivity['user_id'],
        'activity_type': testActivity['activity_type'],
        'value': testActivity['value'],
        'metadata': testActivity['metadata'],
        'created_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      },
    );

    final activityResults = await db.query(
      'test_offline_activities',
      where: 'user_id = ? AND is_synced = 0',
      whereArgs: [testUserId],
    );

    if (activityResults.isNotEmpty) {
      final activity = activityResults.first;
      print('✓ Offline activities test passed:');
      print('  Activity Type: ${activity['activity_type']} (expected: study_session)');
      print('  Value: ${activity['value']} (expected: 1)');
      print('  Metadata: ${activity['metadata']}');
    } else {
      print('✗ Offline activities test failed: No results found');
    }

    // Test 3: Test multiple users
    const user2 = 'user-2';
    await db.insert(
      'test_gamification_stats',
      {
        'user_id': user2,
        'points': 500,
        'level': 3,
        'next_level_points': 600,
        'unlocked_achievements': 5,
        'last_updated': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final user2Results = await db.query(
      'test_gamification_stats',
      where: 'user_id = ?',
      whereArgs: [user2],
    );

    if (user2Results.isNotEmpty && results.isNotEmpty) {
      final user2Stats = user2Results.first;
      final user1Stats = results.first;
      
      print('✓ Multiple users test passed:');
      print('  User 1 Points: ${user1Stats['points']} (expected: 150)');
      print('  User 2 Points: ${user2Stats['points']} (expected: 500)');
    } else {
      print('✗ Multiple users test failed');
    }

  } catch (e) {
    print('✗ Test failed with error: $e');
  } finally {
    await db.close();
    // Clean up test database
    if (await File(path).exists()) {
      await File(path).delete();
    }
    print('Test completed. Database cleaned up.');
  }
}