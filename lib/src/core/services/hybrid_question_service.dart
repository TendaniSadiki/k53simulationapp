import 'package:hive/hive.dart';
import './supabase_service.dart';

class HybridQuestionService {
  static const String _questionsBoxName = 'cached_questions';
  static const String _lastSyncKey = 'last_sync';
  static const Duration _cacheDuration = Duration(hours: 24);

  static Future<void> initialize() async {
    // Questions box will be created automatically when needed
  }

  // Get questions - try Supabase first, fallback to cache
  static Future<List<Map<String, dynamic>>> getQuestions({
    String? category,
    int? limit,
    bool forceRefresh = false,
  }) async {
    try {
      // Try to get from Supabase first
      if (!forceRefresh && await _isCacheValid()) {
        final cachedQuestions = await _getCachedQuestions(category: category, limit: limit);
        if (cachedQuestions.isNotEmpty) {
          print('✅ Using cached questions');
          return cachedQuestions;
        }
      }

      // Fetch from Supabase
      final supabaseQuestions = await _fetchFromSupabase(category: category, limit: limit);
      
      // Cache the results
      if (supabaseQuestions.isNotEmpty) {
        await _cacheQuestions(supabaseQuestions);
        print('✅ Fetched ${supabaseQuestions.length} questions from Supabase');
        return supabaseQuestions;
      }

      // Fallback to cached questions even if cache is old
      final fallbackQuestions = await _getCachedQuestions(category: category, limit: limit);
      if (fallbackQuestions.isNotEmpty) {
        print('⚠️ Using fallback cached questions');
        return fallbackQuestions;
      }

      // Final fallback to pre-loaded questions
      return await _getPreloadedQuestions();
      
    } catch (e) {
      print('❌ Hybrid question service error: $e');
      // Fallback to cached or pre-loaded questions
      final fallbackQuestions = await _getCachedQuestions(category: category, limit: limit);
      if (fallbackQuestions.isNotEmpty) {
        return fallbackQuestions;
      }
      return await _getPreloadedQuestions();
    }
  }

  // Fetch questions from Supabase
  static Future<List<Map<String, dynamic>>> _fetchFromSupabase({
    String? category,
    int? limit,
  }) async {
    try {
      // Get all questions first, then filter in code (simpler approach)
      var query = SupabaseService.client
          .from('questions')
          .select('*')
          .order('id', ascending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      var questions = List<Map<String, dynamic>>.from(response);

      // Apply category filter in code (more reliable than complex queries)
      if (category != null) {
        questions = questions.where((q) => q['category'] == category).toList();
      }

      return questions;
    } catch (e) {
      print('❌ Supabase fetch failed: $e');
      rethrow;
    }
  }

  // Get cached questions
  static Future<List<Map<String, dynamic>>> _getCachedQuestions({
    String? category,
    int? limit,
  }) async {
    try {
      final box = await Hive.openBox(_questionsBoxName);
      final allQuestions = <Map<String, dynamic>>[];
      
      for (final key in box.keys) {
        if (key != _lastSyncKey) {
          final question = Map<String, dynamic>.from(box.get(key));
          allQuestions.add(question);
        }
      }

      // Filter by category if specified
      var filteredQuestions = allQuestions;
      if (category != null) {
        filteredQuestions = allQuestions
            .where((q) => q['category'] == category)
            .toList();
      }

      // Apply limit if specified
      if (limit != null && filteredQuestions.length > limit) {
        filteredQuestions = filteredQuestions.sublist(0, limit);
      }

      return filteredQuestions;
    } catch (e) {
      print('❌ Cache read failed: $e');
      return [];
    }
  }

  // Cache questions
  static Future<void> _cacheQuestions(List<Map<String, dynamic>> questions) async {
    try {
      final box = await Hive.openBox(_questionsBoxName);
      
      // Clear old cache
      await box.clear();
      
      // Store questions with their IDs as keys
      for (final question in questions) {
        final id = question['id']?.toString() ?? 'unknown_${questions.indexOf(question)}';
        await box.put(id, question);
      }
      
      // Store last sync time
      await box.put(_lastSyncKey, DateTime.now().toIso8601String());
      
      print('✅ Cached ${questions.length} questions');
    } catch (e) {
      print('❌ Cache write failed: $e');
    }
  }

  // Check if cache is still valid
  static Future<bool> _isCacheValid() async {
    try {
      final box = await Hive.openBox(_questionsBoxName);
      final lastSync = box.get(_lastSyncKey);
      
      if (lastSync == null) return false;
      
      final lastSyncTime = DateTime.parse(lastSync);
      final now = DateTime.now();
      final difference = now.difference(lastSyncTime);
      
      return difference < _cacheDuration;
    } catch (e) {
      return false;
    }
  }

  // Pre-loaded questions as final fallback
  static Future<List<Map<String, dynamic>>> _getPreloadedQuestions() async {
    // This would contain hardcoded basic questions
    // For now, return empty list - the offline data preloader should handle this
    return [];
  }

  // Force refresh cache from Supabase
  static Future<void> refreshCache() async {
    try {
      final questions = await _fetchFromSupabase();
      await _cacheQuestions(questions);
    } catch (e) {
      print('❌ Cache refresh failed: $e');
    }
  }

  // Get question by ID with fallbacks
  static Future<Map<String, dynamic>?> getQuestionById(String id) async {
    try {
      // Try cache first
      final box = await Hive.openBox(_questionsBoxName);
      final cachedQuestion = box.get(id);
      if (cachedQuestion != null) {
        return Map<String, dynamic>.from(cachedQuestion);
      }

      // Try Supabase
      final response = await SupabaseService.client
          .from('questions')
          .select('*')
          .eq('id', id)
          .single();
      
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('❌ Get question by ID failed: $e');
      return null;
    }
  }
}