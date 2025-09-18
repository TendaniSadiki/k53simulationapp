# Session Database Implementation Plan

## Overview
This document outlines the plan to implement a robust SQLite-based session database for the K53 app, replacing the current SharedPreferences-based session persistence.

## Current Limitations
- SharedPreferences has limited storage capacity
- No proper querying capabilities for session management
- Session data stored as JSON strings, not structured data
- No proper session cleanup or maintenance features

## Database Schema Design

### Sessions Table
```sql
CREATE TABLE sessions (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL, -- 'study' or 'exam'
    user_id TEXT,
    category TEXT,
    total_questions INTEGER,
    current_question_index INTEGER DEFAULT 0,
    correct_answers INTEGER DEFAULT 0,
    total_answered INTEGER DEFAULT 0,
    time_remaining_seconds INTEGER,
    is_paused INTEGER DEFAULT 0,
    is_completed INTEGER DEFAULT 0,
    created_at TEXT,
    updated_at TEXT,
    expires_at TEXT,
    metadata TEXT -- JSON string for additional data
);
```

### Session Questions Table
```sql
CREATE TABLE session_questions (
    session_id TEXT,
    question_id TEXT,
    question_index INTEGER,
    question_data TEXT, -- JSON string of full question data
    PRIMARY KEY (session_id, question_id),
    FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
);
```

### Session Answers Table
```sql
CREATE TABLE session_answers (
    session_id TEXT,
    question_id TEXT,
    chosen_index INTEGER,
    is_correct INTEGER,
    elapsed_ms INTEGER,
    hints_used INTEGER DEFAULT 0,
    answered_at TEXT,
    PRIMARY KEY (session_id, question_id),
    FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
);
```

## Implementation Steps

### 1. Create Session Models
```dart
// lib/src/core/models/session.dart
class Session {
  final String id;
  final SessionType type;
  final String? userId;
  final String? category;
  final int totalQuestions;
  final int currentQuestionIndex;
  final int correctAnswers;
  final int totalAnswered;
  final int timeRemainingSeconds;
  final bool isPaused;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime expiresAt;
  final Map<String, dynamic> metadata;
  
  // Constructors, toJson, fromJson methods
}

enum SessionType { study, exam }
```

### 2. Create SessionDatabaseService
```dart
// lib/src/core/services/session_database_service.dart
class SessionDatabaseService {
  static Future<void> initialize() async {
    // Add session tables to existing SQLite database
  }
  
  static Future<String> createSession(Session session, List<Question> questions) async {}
  static Future<Session?> getSession(String sessionId) async {}
  static Future<List<Session>> getUserSessions(String userId) async {}
  static Future<void> updateSession(Session session) async {}
  static Future<void> deleteSession(String sessionId) async {}
  static Future<void> recordAnswer(String sessionId, String questionId, 
      int chosenIndex, bool isCorrect, int elapsedMs) async {}
  static Future<void> cleanupExpiredSessions() async {}
}
```

### 3. Update OfflineDatabaseService
```dart
// Add session table creation to onCreate callback
await db.execute('''
  CREATE TABLE sessions(...)
''');

await db.execute('''
  CREATE TABLE session_questions(...)
''');

await db.execute('''
  CREATE TABLE session_answers(...)
''');
```

### 4. Migrate from SharedPreferences
```dart
// lib/src/core/services/session_migration_service.dart
class SessionMigrationService {
  static Future<void> migrateFromSharedPreferences() async {
    // Load existing sessions from SharedPreferences
    // Convert to new database format
    // Delete old SharedPreferences data
  }
}
```

### 5. Update ExamProvider
```dart
// Replace SharedPreferences calls with SessionDatabaseService
Future<void> saveSessionState() async {
  final session = Session(
    id: state.sessionId!,
    type: SessionType.exam,
    // ... map all state properties
  );
  
  await SessionDatabaseService.createSession(session, state.questions);
}

Future<void> loadSessionState(String sessionId) async {
  final session = await SessionDatabaseService.getSession(sessionId);
  if (session != null) {
    // Restore state from session
  }
}
```

### 6. Add Session Recovery Features
```dart
// lib/src/core/services/session_recovery_service.dart
class SessionRecoveryService {
  static Future<List<Session>> getRecoverableSessions(String userId) async {}
  static Future<bool> validateSession(Session session) async {}
  static Future<void> cleanupOldSessions() async {}
}
```

## Migration Strategy
1. **Phase 1**: Implement new database tables alongside existing SharedPreferences
2. **Phase 2**: Add migration service to convert existing sessions
3. **Phase 3**: Update all providers to use new database service
4. **Phase 4**: Remove SharedPreferences session storage

## Testing Plan
1. Unit tests for SessionDatabaseService
2. Integration tests for session persistence and recovery
3. Migration tests from SharedPreferences to SQLite
4. Performance tests for large session datasets

## Rollout Plan
1. Develop and test in isolation
2. Deploy alongside existing system
3. Gradually migrate users
4. Monitor performance and stability
5. Remove legacy code after successful migration

## Estimated Timeline
- **Week 1**: Model design and database schema
- **Week 2**: Service implementation and testing
- **Week 3**: Migration strategy and integration
- **Week 4**: Deployment and monitoring

This plan provides a comprehensive roadmap for implementing a robust session database that will enable users to resume exams even after app closure.