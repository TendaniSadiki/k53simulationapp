import 'dart:convert';
import 'package:http/http.dart' as http;

class VercelApiService {
  // Update this URL after deploying to Vercel
  static const String baseUrl = 'https://your-k53-api.vercel.app';
  
  // Get all questions with optional filters
  static Future<List<Map<String, dynamic>>> getQuestions({
    String? category,
    int? limit,
    int? difficulty,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/questions');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['questions']);
        }
      }
      
      print('❌ Vercel API getQuestions failed: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Vercel API getQuestions error: $e');
      return [];
    }
  }
  
  // Get question by ID
  static Future<Map<String, dynamic>?> getQuestionById(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/questions/$id');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Map<String, dynamic>.from(data['question']);
        }
      }
      
      print('❌ Vercel API getQuestionById failed: ${response.statusCode}');
      return null;
    } catch (e) {
      print('❌ Vercel API getQuestionById error: $e');
      return null;
    }
  }
  
  // Get questions by category
  static Future<List<Map<String, dynamic>>> getQuestionsByCategory(String category) async {
    try {
      final uri = Uri.parse('$baseUrl/questions/category/$category');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['questions']);
        }
      }
      
      print('❌ Vercel API getQuestionsByCategory failed: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Vercel API getQuestionsByCategory error: $e');
      return [];
    }
  }
  
  // Submit answer and get result
  static Future<Map<String, dynamic>?> submitAnswer({
    required String questionId,
    required int chosenAnswer,
    String? sessionId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/submit-answer');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'questionId': questionId,
          'chosenAnswer': chosenAnswer,
          'sessionId': sessionId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Map<String, dynamic>.from(data);
        }
      }
      
      print('❌ Vercel API submitAnswer failed: ${response.statusCode}');
      return null;
    } catch (e) {
      print('❌ Vercel API submitAnswer error: $e');
      return null;
    }
  }
  
  // Get all categories
  static Future<List<String>> getCategories() async {
    try {
      final uri = Uri.parse('$baseUrl/categories');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<String>.from(data['categories']);
        }
      }
      
      print('❌ Vercel API getCategories failed: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Vercel API getCategories error: $e');
      return [];
    }
  }
  
  // Test API connectivity
  static Future<bool> testConnection() async {
    try {
      final uri = Uri.parse('$baseUrl/');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Vercel API connection test: SUCCESS');
        print('   Message: ${data['message']}');
        return true;
      }
      
      print('❌ Vercel API connection test failed: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Vercel API connection test error: $e');
      return false;
    }
  }
  
  // Enhanced hybrid question service that tries Vercel first, then fallbacks
  static Future<List<Map<String, dynamic>>> getQuestionsHybrid({
    String? category,
    int? limit,
    bool forceOffline = false,
  }) async {
    // If forced offline or Vercel fails, use local data
    if (forceOffline) {
      return await _getLocalQuestions(category: category, limit: limit);
    }
    
    try {
      // Try Vercel API first
      final vercelQuestions = await getQuestions(
        category: category,
        limit: limit,
      );
      
      if (vercelQuestions.isNotEmpty) {
        print('✅ Using Vercel API questions: ${vercelQuestions.length}');
        return vercelQuestions;
      }
      
      // Fallback to local questions
      print('⚠️ Vercel API returned empty, using local questions');
      return await _getLocalQuestions(category: category, limit: limit);
      
    } catch (e) {
      print('❌ Vercel API failed, using local questions: $e');
      return await _getLocalQuestions(category: category, limit: limit);
    }
  }
  
  // Local fallback questions (would come from Hive or assets)
  static Future<List<Map<String, dynamic>>> _getLocalQuestions({
    String? category,
    int? limit,
  }) async {
    // This would be replaced with actual local data storage
    // For now, return empty list - the hybrid service will handle this
    return [];
  }
}