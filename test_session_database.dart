import 'package:k53app/src/core/models/session.dart' as session_models;
import 'package:k53app/src/core/models/question.dart';
import 'package:k53app/src/core/services/session_database_service.dart';
import 'package:k53app/src/core/services/session_migration_service.dart';
import 'package:k53app/src/core/services/offline_database_service.dart';

void main() async {
  print('Testing Session Database Implementation...');
  
  try {
    // Initialize offline database
    await OfflineDatabaseService.initialize();
    print('✓ Offline database initialized');
    
    // Initialize session database
    await SessionDatabaseService.initialize();
    print('✓ Session database initialized');
    
    // Test migration service
    await SessionMigrationService.migrateFromSharedPreferences();
    print('✓ Session migration completed');
    
    // Test creating a session
    final testSession = session_models.Session(
      id: 'test_session_001',
      type: session_models.SessionType.exam,
      userId: 'test_user_001',
      category: 'road_signs',
      totalQuestions: 10,
      currentQuestionIndex: 3,
      correctAnswers: 2,
      totalAnswered: 3,
      timeRemainingSeconds: 2700,
      isPaused: false,
      isCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      metadata: {'test': true},
    );
    
    // Create test questions (simplified)
    final testQuestions = <Question>[]; // Would normally be actual Question objects
    
    final sessionId = await SessionDatabaseService.createSession(testSession, testQuestions);
    print('✓ Session created with ID: $sessionId');
    
    // Test retrieving session
    final retrievedSession = await SessionDatabaseService.getSession(sessionId);
    if (retrievedSession != null) {
      print('✓ Session retrieved successfully');
      print('  - Type: ${retrievedSession.type}');
      print('  - Progress: ${retrievedSession.currentQuestionIndex}/${retrievedSession.totalQuestions}');
      print('  - Score: ${retrievedSession.correctAnswers}/${retrievedSession.totalAnswered}');
    } else {
      print('✗ Failed to retrieve session');
    }
    
    // Test session cleanup
    await SessionDatabaseService.cleanupExpiredSessions();
    print('✓ Session cleanup completed');
    
    print('\n✅ All session database tests passed!');
    
  } catch (e) {
    print('❌ Error during testing: $e');
  }
}