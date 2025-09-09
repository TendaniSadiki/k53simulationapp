import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/question.dart';
import '../models/user_profile.dart';
import '../models/achievement.dart';
import '../models/referral.dart';
import './supabase_service.dart';
import './database_service.dart';

class OfflineDatabaseService {
  static late Database _sqliteDb;
  static bool _isInitialized = false;

  // Initialize offline database
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize SQLite database
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'k53_questions.db');
      
      _sqliteDb = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          // Create questions table
          await db.execute('''
            CREATE TABLE questions(
              id TEXT PRIMARY KEY,
              category TEXT,
              learner_code INTEGER,
              question_text TEXT,
              options TEXT,
              correct_index INTEGER,
              explanation TEXT,
              version INTEGER,
              is_active INTEGER,
              difficulty_level INTEGER,
              image_url TEXT,
              video_url TEXT,
              audio_url TEXT,
              localized_texts TEXT,
              created_at TEXT,
              updated_at TEXT
            )
          ''');

          // Create user answers table
          await db.execute('''
            CREATE TABLE user_answers(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              session_id TEXT,
              question_id TEXT,
              chosen_index INTEGER,
              is_correct INTEGER,
              elapsed_ms INTEGER,
              hints_used INTEGER,
              created_at TEXT
            )
          ''');

          // Create pending sync operations table
          await db.execute('''
            CREATE TABLE pending_sync(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              operation_type TEXT,
              table_name TEXT,
              data TEXT,
              created_at TEXT,
              attempts INTEGER DEFAULT 0
            )
          ''');
        },
      );

      _isInitialized = true;
    } catch (e) {
      print('Error initializing offline database: $e');
    }
  }

  // Check internet connectivity
  static Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Get questions with offline-first approach
  static Future<List<Question>> getQuestions({
    String? category,
    int? learnerCode,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Try to get from local cache first
      List<Question> localQuestions = await _getQuestionsFromLocal(
        category: category,
        learnerCode: learnerCode,
        limit: limit,
        offset: offset,
      );

      if (localQuestions.isNotEmpty) {
        return localQuestions;
      }

      // If no local data and online, fetch from Supabase and cache
      if (await isConnected()) {
        final onlineQuestions = await DatabaseService.getQuestions(
          category: category,
          learnerCode: learnerCode,
          limit: limit,
          offset: offset,
        );

        // Cache the questions
        await cacheQuestions(onlineQuestions);

        return onlineQuestions;
      }

      return [];
    } catch (e) {
      print('Error getting questions offline: $e');
      return [];
    }
  }

  // Get random questions with offline support
  static Future<List<Question>> getRandomQuestions({
    required int count,
    String? category,
    int? learnerCode,
  }) async {
    try {
      // Try to get from local cache first
      List<Question> allQuestions = await _getAllQuestionsFromLocal();

      // Apply filters
      if (category != null) {
        allQuestions = allQuestions.where((q) => q.category == category).toList();
      }
      
      if (learnerCode != null) {
        allQuestions = allQuestions.where((q) => q.learnerCode == learnerCode).toList();
      }

      // Filter active questions
      allQuestions = allQuestions.where((q) => q.isActive).toList();

      if (allQuestions.length >= count) {
        allQuestions.shuffle();
        return allQuestions.take(count).toList();
      }

      // If not enough local data and online, fetch from Supabase
      if (await isConnected()) {
        final onlineQuestions = await DatabaseService.getRandomQuestions(
          count: count,
          category: category,
          learnerCode: learnerCode,
        );

        // Cache the questions
        await cacheQuestions(onlineQuestions);

        return onlineQuestions;
      }

      return allQuestions;
    } catch (e) {
      print('Error getting random questions offline: $e');
      return [];
    }
  }

  // Save user answer with offline support
  static Future<void> recordAnswer({
    required String sessionId,
    required String questionId,
    required int chosenIndex,
    required bool isCorrect,
    required int elapsedMs,
    int hintsUsed = 0,
  }) async {
    try {
      // Save to local database immediately
      await _sqliteDb.insert('user_answers', {
        'session_id': sessionId,
        'question_id': questionId,
        'chosen_index': chosenIndex,
        'is_correct': isCorrect ? 1 : 0,
        'elapsed_ms': elapsedMs,
        'hints_used': hintsUsed,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Queue for sync if online
      if (await isConnected()) {
        await DatabaseService.recordAnswer(
          sessionId: sessionId,
          questionId: questionId,
          chosenIndex: chosenIndex,
          isCorrect: isCorrect,
          elapsedMs: elapsedMs,
          hintsUsed: hintsUsed,
        );
      } else {
        // Queue for later sync
        await _queueSyncOperation(
          operationType: 'insert',
          tableName: 'answers',
          data: {
            'session_id': sessionId,
            'question_id': questionId,
            'chosen_index': chosenIndex,
            'is_correct': isCorrect,
            'elapsed_ms': elapsedMs,
            'hints_used': hintsUsed,
            'created_at': DateTime.now().toIso8601String(),
          },
        );
      }
    } catch (e) {
      print('Error recording answer offline: $e');
    }
  }

  // Sync pending operations when connectivity is restored
  static Future<void> syncPendingOperations() async {
    if (!await isConnected()) return;

    try {
      final pendingOps = await _sqliteDb.query(
        'pending_sync',
        where: 'attempts < 3', // Max 3 attempts
      );

      for (final op in pendingOps) {
        try {
          final data = json.decode(op['data'] as String) as Map<String, dynamic>;
          
          switch (op['operation_type'] as String) {
            case 'insert':
              await _syncInsertOperation(op['table_name'] as String, data);
              break;
            case 'update':
              await _syncUpdateOperation(op['table_name'] as String, data);
              break;
            case 'delete':
              await _syncDeleteOperation(op['table_name'] as String, data);
              break;
          }

          // Remove successful operation
          await _sqliteDb.delete(
            'pending_sync',
            where: 'id = ?',
            whereArgs: [op['id']],
          );
        } catch (e) {
          // Increment attempt count
          await _sqliteDb.update(
            'pending_sync',
            {'attempts': (op['attempts'] as int) + 1},
            where: 'id = ?',
            whereArgs: [op['id']],
          );
        }
      }
    } catch (e) {
      print('Error syncing pending operations: $e');
    }
  }

  // Cache questions to local storage
  static Future<void> cacheQuestions(List<Question> questions) async {
    try {
      final batch = _sqliteDb.batch();
      
      for (final question in questions) {
        batch.insert(
          'questions',
          {
            'id': question.id,
            'category': question.category,
            'learner_code': question.learnerCode,
            'question_text': question.questionText,
            'options': json.encode(question.options.map((o) => o.toJson()).toList()),
            'correct_index': question.correctIndex,
            'explanation': question.explanation,
            'version': question.version,
            'is_active': question.isActive ? 1 : 0,
            'difficulty_level': question.difficultyLevel,
            'image_url': question.imageUrl,
            'video_url': question.videoUrl,
            'audio_url': question.audioUrl,
            'localized_texts': question.localizedTexts != null 
                ? json.encode(question.localizedTexts) 
                : null,
            'created_at': question.createdAt.toIso8601String(),
            'updated_at': question.updatedAt.toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      await batch.commit();
    } catch (e) {
      print('Error caching questions: $e');
    }
  }

  // Get questions from local SQLite database
  static Future<List<Question>> _getQuestionsFromLocal({
    String? category,
    int? learnerCode,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var whereClause = 'is_active = 1';
      final whereArgs = <dynamic>[];

      if (category != null) {
        whereClause += ' AND category = ?';
        whereArgs.add(category);
      }

      if (learnerCode != null) {
        whereClause += ' AND learner_code = ?';
        whereArgs.add(learnerCode);
      }

      final results = await _sqliteDb.query(
        'questions',
        where: whereClause,
        whereArgs: whereArgs,
        limit: limit,
        offset: offset,
      );

      return results.map((row) => _questionFromLocal(row)).toList();
    } catch (e) {
      print('Error getting questions from local: $e');
      return [];
    }
  }

  // Get all questions from local database
  static Future<List<Question>> _getAllQuestionsFromLocal() async {
    try {
      final results = await _sqliteDb.query(
        'questions',
        where: 'is_active = 1',
      );

      return results.map((row) => _questionFromLocal(row)).toList();
    } catch (e) {
      print('Error getting all questions from local: $e');
      return [];
    }
  }

  // Queue sync operation for later
  static Future<void> _queueSyncOperation({
    required String operationType,
    required String tableName,
    required Map<String, dynamic> data,
  }) async {
    await _sqliteDb.insert('pending_sync', {
      'operation_type': operationType,
      'table_name': tableName,
      'data': json.encode(data),
      'created_at': DateTime.now().toIso8601String(),
      'attempts': 0,
    });
  }

  // Sync insert operations
  static Future<void> _syncInsertOperation(String tableName, Map<String, dynamic> data) async {
    switch (tableName) {
      case 'answers':
        await DatabaseService.recordAnswer(
          sessionId: data['session_id'] as String,
          questionId: data['question_id'] as String,
          chosenIndex: data['chosen_index'] as int,
          isCorrect: data['is_correct'] as bool,
          elapsedMs: data['elapsed_ms'] as int,
          hintsUsed: data['hints_used'] as int,
        );
        break;
      // Add more table sync cases as needed
    }
  }

  // Sync update operations
  static Future<void> _syncUpdateOperation(String tableName, Map<String, dynamic> data) async {
    // Implement update sync logic for different tables
  }

  // Sync delete operations
  static Future<void> _syncDeleteOperation(String tableName, Map<String, dynamic> data) async {
    // Implement delete sync logic for different tables
  }

  // Clear all offline data
  static Future<void> clearAllData() async {
    try {
      await _sqliteDb.delete('questions');
      await _sqliteDb.delete('user_answers');
      await _sqliteDb.delete('pending_sync');
    } catch (e) {
      print('Error clearing offline data: $e');
    }
  }

  // Get local database statistics
  static Future<Map<String, int>> getLocalStats() async {
    try {
      final questionCount = Sqflite.firstIntValue(
        await _sqliteDb.rawQuery('SELECT COUNT(*) FROM questions WHERE is_active = 1')
      ) ?? 0;

      final answerCount = Sqflite.firstIntValue(
        await _sqliteDb.rawQuery('SELECT COUNT(*) FROM user_answers')
      ) ?? 0;

      final pendingSyncCount = Sqflite.firstIntValue(
        await _sqliteDb.rawQuery('SELECT COUNT(*) FROM pending_sync')
      ) ?? 0;

      return {
        'questions': questionCount,
        'answers': answerCount,
        'pending_sync': pendingSyncCount,
      };
    } catch (e) {
      return {'questions': 0, 'answers': 0, 'pending_sync': 0};
    }
  }

  // Get gamification stats for user
  static Future<Map<String, dynamic>> getGamificationStats(String userId) async {
    try {
      final results = await _sqliteDb.query(
        'gamification_stats',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      if (results.isNotEmpty) {
        final row = results.first;
        return {
          'points': row['points'] as int,
          'level': row['level'] as int,
          'next_level_points': row['next_level_points'] as int,
          'unlocked_achievements': row['unlocked_achievements'] as int,
        };
      }
      return {};
    } catch (e) {
      print('Error getting gamification stats: $e');
      return {};
    }
  }

  // Save gamification stats for user
  static Future<void> saveGamificationStats(String userId, Map<String, dynamic> stats) async {
    try {
      await _sqliteDb.insert(
        'gamification_stats',
        {
          'user_id': userId,
          'points': stats['points'] ?? 0,
          'level': stats['level'] ?? 1,
          'next_level_points': stats['next_level_points'] ?? 100,
          'unlocked_achievements': stats['unlocked_achievements'] ?? 0,
          'last_updated': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving gamification stats: $e');
    }
  }

  // Track offline activity for gamification
  static Future<void> trackOfflineActivity({
    required String userId,
    required String activityType,
    required int value,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _sqliteDb.insert(
        'offline_activities',
        {
          'user_id': userId,
          'activity_type': activityType,
          'value': value,
          'metadata': metadata != null ? json.encode(metadata) : null,
          'created_at': DateTime.now().toIso8601String(),
          'is_synced': 0,
        },
      );
    } catch (e) {
      print('Error tracking offline activity: $e');
    }
  }

  // Get pending offline activities for user
  static Future<List<Map<String, dynamic>>> getPendingOfflineActivities(String userId) async {
    try {
      final results = await _sqliteDb.query(
        'offline_activities',
        where: 'user_id = ? AND is_synced = 0',
        whereArgs: [userId],
      );

      return results.map((row) {
        Map<String, dynamic>? metadata;
        if (row['metadata'] != null) {
          metadata = json.decode(row['metadata'] as String) as Map<String, dynamic>;
        }

        return {
          'id': row['id'],
          'activity_type': row['activity_type'],
          'value': row['value'],
          'metadata': metadata,
        };
      }).toList();
    } catch (e) {
      print('Error getting pending offline activities: $e');
      return [];
    }
  }

  // Mark activity as synced
  static Future<void> markActivityAsSynced(int activityId) async {
    try {
      await _sqliteDb.update(
        'offline_activities',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [activityId],
      );
    } catch (e) {
      print('Error marking activity as synced: $e');
    }
  }

  // Helper method to create Question from local database row
  static Question _questionFromLocal(Map<String, dynamic> row) {
    final optionsJson = json.decode(row['options'] as String) as List<dynamic>;
    final options = optionsJson.map((option) {
      if (option is Map<String, dynamic>) {
        return QuestionOption.fromJson(option);
      }
      return QuestionOption(text: option.toString());
    }).toList();

    Map<String, String>? localizedTexts;
    if (row['localized_texts'] != null) {
      localizedTexts = Map<String, String>.from(json.decode(row['localized_texts'] as String));
    }

    return Question(
      id: row['id'] as String,
      category: row['category'] as String,
      learnerCode: row['learner_code'] as int,
      questionText: row['question_text'] as String,
      options: options,
      correctIndex: row['correct_index'] as int,
      explanation: row['explanation'] as String,
      version: row['version'] as int,
      isActive: (row['is_active'] as int) == 1,
      difficultyLevel: row['difficulty_level'] as int,
      imageUrl: row['image_url'] as String?,
      videoUrl: row['video_url'] as String?,
      audioUrl: row['audio_url'] as String?,
      localizedTexts: localizedTexts,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  // Start listening for connectivity changes and auto-sync
  static void startConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        // We have connectivity, sync pending operations
        await syncPendingOperations();
      }
    });
  }
}