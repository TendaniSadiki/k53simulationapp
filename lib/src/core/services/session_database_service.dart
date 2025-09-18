import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/session.dart';
import '../models/question.dart';
import './offline_database_service.dart';

class SessionDatabaseService {
  static Future<Database> get database async {
    await OfflineDatabaseService.initialize();
    return OfflineDatabaseService.database;
  }

  static Future<void> initialize() async {
    final db = await database;
    
    // Create sessions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sessions (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
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
        metadata TEXT
      )
    ''');

    // Create session_questions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS session_questions (
        session_id TEXT,
        question_id TEXT,
        question_index INTEGER,
        question_data TEXT,
        PRIMARY KEY (session_id, question_id),
        FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
      )
    ''');

    // Create session_answers table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS session_answers (
        session_id TEXT,
        question_id TEXT,
        chosen_index INTEGER,
        is_correct INTEGER,
        elapsed_ms INTEGER,
        hints_used INTEGER DEFAULT 0,
        answered_at TEXT,
        PRIMARY KEY (session_id, question_id),
        FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<String> createSession(Session session, List<Question> questions) async {
    final db = await database;
    final batch = db.batch();

    // Insert session
    batch.insert('sessions', _sessionToMap(session));

    // Insert session questions
    for (var i = 0; i < questions.length; i++) {
      final question = questions[i];
      batch.insert('session_questions', {
        'session_id': session.id,
        'question_id': question.id,
        'question_index': i,
        'question_data': json.encode(question.toJson()),
      });
    }

    await batch.commit();
    return session.id;
  }

  static Future<Session?> getSession(String sessionId) async {
    final db = await database;
    final sessionMaps = await db.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    if (sessionMaps.isEmpty) return null;

    final sessionMap = sessionMaps.first;
    final questions = await _getSessionQuestions(sessionId);
    
    return _sessionFromMap(sessionMap, questions);
  }

  static Future<List<Session>> getUserSessions(String userId) async {
    final db = await database;
    final sessionMaps = await db.query(
      'sessions',
      where: 'user_id = ? AND is_completed = 0',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    final sessions = <Session>[];
    for (final sessionMap in sessionMaps) {
      final sessionId = sessionMap['id'] as String;
      final questions = await _getSessionQuestions(sessionId);
      sessions.add(_sessionFromMap(sessionMap, questions));
    }

    return sessions;
  }

  static Future<void> updateSession(Session session) async {
    final db = await database;
    await db.update(
      'sessions',
      _sessionToMap(session),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  static Future<void> deleteSession(String sessionId) async {
    final db = await database;
    await db.delete(
      'sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  static Future<void> recordAnswer({
    required String sessionId,
    required String questionId,
    required int chosenIndex,
    required bool isCorrect,
    required int elapsedMs,
    int hintsUsed = 0,
  }) async {
    final db = await database;
    await db.insert(
      'session_answers',
      {
        'session_id': sessionId,
        'question_id': questionId,
        'chosen_index': chosenIndex,
        'is_correct': isCorrect ? 1 : 0,
        'elapsed_ms': elapsedMs,
        'hints_used': hintsUsed,
        'answered_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<SessionAnswer>> getSessionAnswers(String sessionId) async {
    final db = await database;
    final answerMaps = await db.query(
      'session_answers',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );

    return answerMaps.map((map) {
      return SessionAnswer(
        sessionId: map['session_id'] as String,
        questionId: map['question_id'] as String,
        chosenIndex: map['chosen_index'] as int,
        isCorrect: (map['is_correct'] as int) == 1,
        elapsedMs: map['elapsed_ms'] as int,
        hintsUsed: map['hints_used'] as int,
        answeredAt: DateTime.parse(map['answered_at'] as String),
      );
    }).toList();
  }

  static Future<void> cleanupExpiredSessions() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.delete(
      'sessions',
      where: 'expires_at < ? AND is_completed = 0',
      whereArgs: [now],
    );
  }

  static Future<int> getSessionCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM sessions WHERE user_id = ? AND is_completed = 0',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get session questions (public version)
  static Future<List<Question>> getSessionQuestions(String sessionId) async {
    final db = await database;
    final questionMaps = await db.query(
      'session_questions',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'question_index',
    );

    return questionMaps.map((map) {
      final questionData = json.decode(map['question_data'] as String);
      return Question.fromSupabase(questionData);
    }).toList();
  }

  // Helper methods
  static Map<String, dynamic> _sessionToMap(Session session) {
    return {
      'id': session.id,
      'type': session.type.toString(),
      'user_id': session.userId,
      'category': session.category,
      'total_questions': session.totalQuestions,
      'current_question_index': session.currentQuestionIndex,
      'correct_answers': session.correctAnswers,
      'total_answered': session.totalAnswered,
      'time_remaining_seconds': session.timeRemainingSeconds,
      'is_paused': session.isPaused ? 1 : 0,
      'is_completed': session.isCompleted ? 1 : 0,
      'created_at': session.createdAt.toIso8601String(),
      'updated_at': session.updatedAt.toIso8601String(),
      'expires_at': session.expiresAt.toIso8601String(),
      'metadata': json.encode(session.metadata),
    };
  }

  static Session _sessionFromMap(Map<String, dynamic> map, List<Question> questions) {
    return Session(
      id: map['id'] as String,
      type: SessionType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => SessionType.study,
      ),
      userId: map['user_id'],
      category: map['category'],
      totalQuestions: map['total_questions'] as int,
      currentQuestionIndex: map['current_question_index'] as int,
      correctAnswers: map['correct_answers'] as int,
      totalAnswered: map['total_answered'] as int,
      timeRemainingSeconds: map['time_remaining_seconds'] as int,
      isPaused: (map['is_paused'] as int) == 1,
      isCompleted: (map['is_completed'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      expiresAt: DateTime.parse(map['expires_at'] as String),
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(json.decode(map['metadata'] as String))
          : {},
    );
  }

  static Future<List<Question>> _getSessionQuestions(String sessionId) async {
    final db = await database;
    final questionMaps = await db.query(
      'session_questions',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'question_index',
    );

    return questionMaps.map((map) {
      final questionData = json.decode(map['question_data'] as String);
      return Question.fromSupabase(questionData);
    }).toList();
  }
}