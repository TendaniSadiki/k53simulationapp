import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart' as session_models;
import '../models/question.dart';
import './session_database_service.dart';
import './session_persistence_service.dart' as persistence_service;

class SessionMigrationService {
  static Future<void> migrateFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if migration has already been done
    final migrationKey = 'session_migration_completed';
    if (prefs.getBool(migrationKey) ?? false) {
      return;
    }

    try {
      // Migrate study sessions
      final studySessionJson = prefs.getString('active_study_session');
      if (studySessionJson != null) {
        await _migrateSession(studySessionJson, session_models.SessionType.study);
        await prefs.remove('active_study_session');
      }

      // Migrate exam sessions
      final examSessionJson = prefs.getString('active_exam_session');
      if (examSessionJson != null) {
        await _migrateSession(examSessionJson, session_models.SessionType.exam);
        await prefs.remove('active_exam_session');
      }

      // Mark migration as completed
      await prefs.setBool(migrationKey, true);
      
      print('Session migration completed successfully');
    } catch (e) {
      print('Error migrating sessions: $e');
      // Don't mark as completed if migration failed
    }
  }

  static Future<void> _migrateSession(String sessionJson, session_models.SessionType type) async {
    try {
      final jsonData = json.decode(sessionJson) as Map<String, dynamic>;
      final sessionState = persistence_service.SessionState.fromJson(jsonData);
      
      // Convert to new session format
      final session = session_models.Session(
        id: sessionState.sessionId ?? _generateSessionId(),
        type: type,
        userId: null, // Will be populated from user context
        category: sessionState.questions.isNotEmpty ? sessionState.questions.first.category : null,
        totalQuestions: sessionState.questions.length,
        currentQuestionIndex: sessionState.currentQuestionIndex,
        correctAnswers: sessionState.correctAnswers,
        totalAnswered: sessionState.totalAnswered,
        timeRemainingSeconds: sessionState.additionalData['timeRemainingSeconds'] ?? 45 * 60,
        isPaused: sessionState.additionalData['isPaused'] ?? false,
        isCompleted: false, // Sessions being migrated are by definition not completed
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        metadata: {
          'migrated': true,
          'original_timestamp': sessionState.additionalData['timestamp'],
          'migration_date': DateTime.now().toIso8601String(),
        },
      );

      // Save to new database
      await SessionDatabaseService.createSession(session, sessionState.questions);

      // Migrate user answers if any
      if (sessionState.userAnswers.isNotEmpty) {
        for (final entry in sessionState.userAnswers.entries) {
          final questionId = entry.key;
          final chosenIndex = entry.value;
          
          // Find the question to check if answer was correct
          final question = sessionState.questions.firstWhere(
            (q) => q.id == questionId,
            orElse: () => sessionState.questions.first,
          );
          
          final isCorrect = question.isAnswerCorrect(chosenIndex);
          
          await SessionDatabaseService.recordAnswer(
            sessionId: session.id,
            questionId: questionId,
            chosenIndex: chosenIndex,
            isCorrect: isCorrect,
            elapsedMs: 0, // Unknown for migrated sessions
            hintsUsed: 0,
          );
        }
      }

      print('Migrated ${type.toString()} session: ${session.id}');
    } catch (e) {
      print('Error migrating session: $e');
      // Continue with other sessions even if one fails
    }
  }

  static String _generateSessionId() {
    return 'migrated_${DateTime.now().millisecondsSinceEpoch}';
  }

  static Future<bool> hasSessionsToMigrate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('active_study_session') ||
           prefs.containsKey('active_exam_session');
  }

  static Future<void> cleanupOldSessions() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Remove old session keys if they exist
    await prefs.remove('active_study_session');
    await prefs.remove('active_exam_session');
    
    // Remove migration flag to allow re-migration if needed
    await prefs.remove('session_migration_completed');
  }
}