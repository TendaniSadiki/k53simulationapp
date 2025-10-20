import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/question.dart';
import 'supabase_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Get questions from Supabase
  Future<List<Question>> getQuestions({
    String? category,
    int? learnerCode,
    int limit = 100,
    bool includeInactive = false,
  }) async {
    try {
      var query = SupabaseService.client
          .from('questions')
          .select()
          .limit(limit);

      final response = await query;

      // Convert to Question objects
      final questions = response
          .map((item) => Question.fromSupabase(item as Map<String, dynamic>))
          .toList();

      // Apply filtering in code
      var filteredQuestions = questions;

      if (category != null) {
        filteredQuestions = filteredQuestions.where((q) => q.category == category).toList();
      }

      if (learnerCode != null) {
        filteredQuestions = filteredQuestions.where((q) => q.learnerCode == learnerCode).toList();
      }

      if (!includeInactive) {
        filteredQuestions = filteredQuestions.where((q) => q.isActive).toList();
      }

      return filteredQuestions;
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  // Get a single question by ID
  Future<Question?> getQuestion(String questionId) async {
    try {
      final response = await SupabaseService.client
          .from('questions')
          .select()
          .eq('id', questionId)
          .single();

      return Question.fromSupabase(response as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching question $questionId: $e');
      return null;
    }
  }

  // Get random questions
  Future<List<Question>> getRandomQuestions({
    int count = 10,
    String? category,
    int? learnerCode,
  }) async {
    try {
      // Get all questions first (we'll randomize in code for now)
      final allQuestions = await getQuestions(
        category: category,
        learnerCode: learnerCode,
        limit: 200, // Get more than needed to ensure good randomization
      );

      // Shuffle and take the requested count
      allQuestions.shuffle();
      return allQuestions.take(count).toList();
    } catch (e) {
      print('Error fetching random questions: $e');
      return [];
    }
  }

  // Get questions by difficulty
  Future<List<Question>> getQuestionsByDifficulty({
    required int difficulty,
    String? category,
    int? learnerCode,
    int limit = 50,
  }) async {
    try {
      var query = SupabaseService.client
          .from('questions')
          .select()
          .eq('difficulty', difficulty)
          .eq('is_active', true)
          .limit(limit);

      final response = await query;

      // Apply additional filtering in code
      var questions = response
          .map((item) => Question.fromSupabase(item as Map<String, dynamic>))
          .toList();

      if (category != null) {
        questions = questions.where((q) => q.category == category).toList();
      }

      if (learnerCode != null) {
        questions = questions.where((q) => q.learnerCode == learnerCode).toList();
      }

      return questions;
    } catch (e) {
      print('Error fetching questions by difficulty: $e');
      return [];
    }
  }

  // Update question statistics
  Future<void> updateQuestionStats({
    required String questionId,
    required bool isCorrect,
  }) async {
    try {
      // Get current question
      final question = await getQuestion(questionId);
      if (question == null) return;

      // Update statistics
      await SupabaseService.client.from('questions').update({
        'times_answered': question.timesAnswered + 1,
        'times_correct': isCorrect
            ? question.timesCorrect + 1
            : question.timesCorrect,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', questionId);
    } catch (e) {
      print('Error updating question stats: $e');
    }
  }

  // Report a question
  Future<bool> reportQuestion({
    required String questionId,
    required String reason,
    String? description,
    String severity = 'medium',
  }) async {
    try {
      // Get current question
      final question = await getQuestion(questionId);
      if (question == null) return false;

      // Update report count and status
      await SupabaseService.client.from('questions').update({
        'report_count': question.reportCount + 1,
        'is_reported': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', questionId);

      // Create a report record (if you have a reports table)
      try {
        await SupabaseService.client.from('question_reports').insert({
          'question_id': questionId,
          'reason': reason,
          'description': description,
          'severity': severity,
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        print('Note: question_reports table might not exist: $e');
      }

      return true;
    } catch (e) {
      print('Error reporting question: $e');
      return false;
    }
  }

  // Get user progress
  Future<Map<String, dynamic>> getUserProgress(String userId) async {
    try {
      // This would typically query a user_progress table
      // For now, return a basic structure
      return {
        'total_questions_answered': 0,
        'correct_answers': 0,
        'accuracy': 0.0,
        'categories': {},
      };
    } catch (e) {
      print('Error fetching user progress: $e');
      return {};
    }
  }

  // Get category statistics
  Future<Map<String, dynamic>> getCategoryStats() async {
    try {
      final response = await SupabaseService.client
          .from('questions')
          .select('category, times_answered, times_correct');

      final stats = <String, Map<String, dynamic>>{};

      for (final item in response) {
        final category = item['category'] as String;
        final timesAnswered = (item['times_answered'] as num?)?.toInt() ?? 0;
        final timesCorrect = (item['times_correct'] as num?)?.toInt() ?? 0;

        if (!stats.containsKey(category)) {
          stats[category] = {
            'total_questions': 0,
            'times_answered': 0,
            'times_correct': 0,
          };
        }

        stats[category]!['total_questions'] =
            (stats[category]!['total_questions'] as int) + 1;
        stats[category]!['times_answered'] =
            (stats[category]!['times_answered'] as int) + timesAnswered;
        stats[category]!['times_correct'] =
            (stats[category]!['times_correct'] as int) + timesCorrect;
      }

      // Calculate accuracy for each category
      for (final category in stats.keys) {
        final data = stats[category]!;
        final answered = data['times_answered'] as int;
        final correct = data['times_correct'] as int;
        data['accuracy'] = answered > 0 ? correct / answered : 0.0;
      }

      return {'categories': stats};
    } catch (e) {
      print('Error fetching category stats: $e');
      return {'categories': {}};
    }
  }

  // Search questions
  Future<List<Question>> searchQuestions(String query) async {
    try {
      final response = await SupabaseService.client
          .from('questions')
          .select()
          .textSearch('question_text', query)
          .limit(20);

      return response
          .map((item) => Question.fromSupabase(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching questions: $e');
      return [];
    }
  }

  // Get popular questions (most answered)
  Future<List<Question>> getPopularQuestions({
    int limit = 10,
    String? category,
  }) async {
    try {
      var query = SupabaseService.client
          .from('questions')
          .select()
          .order('times_answered', ascending: false)
          .limit(limit);

      final response = await query;

      // Apply category filter in code
      var questions = response
          .map((item) => Question.fromSupabase(item as Map<String, dynamic>))
          .toList();

      if (category != null) {
        questions = questions.where((q) => q.category == category).toList();
      }

      return questions;
    } catch (e) {
      print('Error fetching popular questions: $e');
      return [];
    }
  }

  // Additional methods that other services expect
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching user profile: $e');
      
      // If the error is due to UUID type mismatch, try alternative approach
      if (e.toString().contains('invalid input syntax for type bigint')) {
        print('⚠️ UUID type mismatch detected, trying alternative query...');
        try {
          // Try to get profile by email instead
          final user = SupabaseService.client.auth.currentUser;
          if (user?.email != null) {
            final response = await SupabaseService.client
                .from('profiles')
                .select()
                .eq('email', user!.email!)
                .single();
            return response as Map<String, dynamic>?;
          }
        } catch (e2) {
          print('Alternative profile query also failed: $e2');
        }
      }
      
      return null;
    }
  }

  static Future<void> updateUserProfile(Map<String, dynamic> profile) async {
    try {
      print('📝 Creating/updating user profile with complete data');
      print('   - User ID: ${profile['id']}');
      print('   - Email: ${profile['email']}');
      print('   - Full Name: ${profile['full_name']}');
      
      // Use upsert to handle both insert and update scenarios
      await SupabaseService.client
          .from('profiles')
          .upsert(profile);
      
      print('✅ User profile created/updated successfully: ${profile['id']}');
    } catch (e) {
      print('❌ Failed to create/update user profile: $e');
      print('💡 The profile may have been created by the database trigger automatically');
    }
  }

  static Future<List<Map<String, dynamic>>> getAchievementsByType(String type) async {
    try {
      final response = await SupabaseService.client
          .from('achievements')
          .select()
          .eq('type', type);

      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching achievements by type: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getUserAchievement(String userId, String achievementId) async {
    try {
      final response = await SupabaseService.client
          .from('user_achievements')
          .select()
          .eq('user_id', userId)
          .eq('achievement_id', achievementId)
          .single();

      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching user achievement: $e');
      return null;
    }
  }

  static Future<void> unlockAchievement(String userId, String achievementId) async {
    try {
      await SupabaseService.client.from('user_achievements').insert({
        'user_id': userId,
        'achievement_id': achievementId,
        'unlocked_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error unlocking achievement: $e');
    }
  }

  static Future<void> trackAchievementUnlocked(String userId, String achievementId) async {
    try {
      await SupabaseService.client.from('achievement_events').insert({
        'user_id': userId,
        'achievement_id': achievementId,
        'event_type': 'unlocked',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking achievement unlocked: $e');
    }
  }

  static Future<void> updateAchievementProgress(String userId, String achievementId, int progress) async {
    try {
      await SupabaseService.client.from('user_achievements').update({
        'progress': progress,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId).eq('achievement_id', achievementId);
    } catch (e) {
      print('Error updating achievement progress: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getUserAchievements(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('user_achievements')
          .select()
          .eq('user_id', userId);

      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching user achievements: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getAchievementById(String achievementId) async {
    try {
      final response = await SupabaseService.client
          .from('achievements')
          .select()
          .eq('id', achievementId)
          .single();

      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching achievement by id: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserStats(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .single();

      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching user stats: $e');
      return null;
    }
  }

  static Future<void> updateUserStats(Map<String, dynamic> stats) async {
    try {
      await SupabaseService.client
          .from('user_stats')
          .update(stats)
          .eq('user_id', stats['user_id']);
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }

  static Future<DateTime?> getLastLogin(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('user_sessions')
          .select('last_login')
          .eq('user_id', userId)
          .single();

      final lastLogin = response['last_login'] as String?;
      return lastLogin != null ? DateTime.parse(lastLogin) : null;
    } catch (e) {
      print('Error fetching last login: $e');
      return null;
    }
  }

  static Future<void> trackReferralShare(String userId) async {
    try {
      await SupabaseService.client.from('referral_events').insert({
        'user_id': userId,
        'event_type': 'share',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking referral share: $e');
    }
  }

  static Future<void> trackShareEvent(String userId, String contentType) async {
    try {
      await SupabaseService.client.from('share_events').insert({
        'user_id': userId,
        'content_type': contentType,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking share event: $e');
    }
  }

  static Future<Map<String, dynamic>?> createReferral(String referrerId, String referredEmail) async {
    try {
      final response = await SupabaseService.client.from('referrals').insert({
        'referrer_id': referrerId,
        'referred_email': referredEmail,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Error creating referral: $e');
      return null;
    }
  }

  static Future<void> trackReferralCompletion(String referralId) async {
    try {
      await SupabaseService.client.from('referrals').update({
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', referralId);
    } catch (e) {
      print('Error tracking referral completion: $e');
    }
  }

  static Future<Map<String, dynamic>> getReferralStats(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('referrals')
          .select()
          .eq('referrer_id', userId);

      final total = response.length;
      final completed = response.where((r) => r['status'] == 'completed').length;

      return {
        'total_referrals': total,
        'completed_referrals': completed,
        'pending_referrals': total - completed,
      };
    } catch (e) {
      print('Error fetching referral stats: $e');
      return {
        'total_referrals': 0,
        'completed_referrals': 0,
        'pending_referrals': 0,
      };
    }
  }

  static Future<List<Map<String, dynamic>>> getUserReferrals(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('referrals')
          .select()
          .eq('referrer_id', userId)
          .order('created_at', ascending: false);

      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching user referrals: $e');
      return [];
    }
  }

  static Future<String?> createSession(Map<String, dynamic> sessionData) async {
    try {
      final response = await SupabaseService.client
          .from('sessions')
          .insert(sessionData)
          .select('id')
          .single();

      return response['id'] as String?;
    } catch (e) {
      print('Error creating session: $e');
      return null;
    }
  }

  static Future<void> updateSession(String sessionId, Map<String, dynamic> updates) async {
    try {
      await SupabaseService.client
          .from('sessions')
          .update(updates)
          .eq('id', sessionId);
    } catch (e) {
      print('Error updating session: $e');
    }
  }
}
