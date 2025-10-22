import 'package:k53app/src/core/models/question_report.dart';
import './supabase_service.dart';

class AdminReportService {
  static final _client = SupabaseService.client;

  /// Get all reported questions
  static Future<List<QuestionReport>> getAllReports() async {
    try {
      final response = await _client
          .from('question_reports')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => QuestionReport.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting all reports: $e');
      return [];
    }
  }

  /// Get pending reports
  static Future<List<QuestionReport>> getPendingReports() async {
    try {
      final response = await _client
          .from('question_reports')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => QuestionReport.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting pending reports: $e');
      return [];
    }
  }

  /// Get resolved reports
  static Future<List<QuestionReport>> getResolvedReports() async {
    try {
      final response = await _client
          .from('question_reports')
          .select()
          .eq('status', 'resolved')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => QuestionReport.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting resolved reports: $e');
      return [];
    }
  }

  /// Get report statistics
  static Future<Map<String, dynamic>> getReportStatistics() async {
    try {
      final allReports = await getAllReports();
      
      final totalCount = allReports.length;
      final pendingCount = allReports.where((r) => r.status == ReportStatus.pending).length;
      final resolvedCount = allReports.where((r) => r.status == ReportStatus.resolved).length;
      final rejectedCount = allReports.where((r) => r.status == ReportStatus.rejected).length;

      // Calculate recent reports (last 7 days)
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentCount = allReports.where((r) => r.reportedAt.isAfter(weekAgo)).length;

      // Calculate reports by reason
      final reasonCounts = <String, int>{};
      for (final report in allReports) {
        final reason = report.reason.value;
        reasonCounts[reason] = (reasonCounts[reason] ?? 0) + 1;
      }

      return {
        'total_reports': totalCount,
        'pending_reports': pendingCount,
        'resolved_reports': resolvedCount,
        'rejected_reports': rejectedCount,
        'recent_reports': recentCount,
        'by_reason': reasonCounts,
      };
    } catch (e) {
      print('Error getting report statistics: $e');
      return {
        'total_reports': 0,
        'pending_reports': 0,
        'resolved_reports': 0,
        'rejected_reports': 0,
        'recent_reports': 0,
        'by_reason': {},
      };
    }
  }

  /// Update report status (admin functionality)
  static Future<bool> updateReportStatus({
    required String reportId,
    required ReportStatus newStatus,
    String? adminNotes,
    String? resolvedBy,
  }) async {
    try {
      final updateData = {
        'status': newStatus.toString().split('.').last,
        'admin_notes': adminNotes,
      };

      // Add resolved information if status is resolved or rejected
      if (newStatus == ReportStatus.resolved || newStatus == ReportStatus.rejected) {
        updateData['resolved_at'] = DateTime.now().toIso8601String();
        updateData['resolved_by'] = resolvedBy;
      }

      await _client
          .from('question_reports')
          .update(updateData)
          .eq('id', reportId);

      return true;
    } catch (e) {
      print('Error updating report status: $e');
      return false;
    }
  }

  /// Get reports for a specific question
  static Future<List<QuestionReport>> getReportsForQuestion(String questionId) async {
    try {
      final response = await _client
          .from('question_reports')
          .select()
          .eq('question_id', questionId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => QuestionReport.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting reports for question: $e');
      return [];
    }
  }

  /// Get frequently reported questions
  static Future<List<Map<String, dynamic>>> getFrequentlyReportedQuestions() async {
    try {
      final allReports = await getAllReports();
      
      // Count reports per question
      final questionCounts = <String, int>{};
      for (final report in allReports) {
        final questionId = report.questionId;
        questionCounts[questionId] = (questionCounts[questionId] ?? 0) + 1;
      }

      // Sort by count and get top 10
      final sortedQuestions = questionCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedQuestions.take(10).map((entry) => {
        'question_id': entry.key,
        'report_count': entry.value,
      }).toList();
    } catch (e) {
      print('Error getting frequently reported questions: $e');
      return [];
    }
  }

  /// Delete a report (admin functionality)
  static Future<bool> deleteReport(String reportId) async {
    try {
      await _client
          .from('question_reports')
          .delete()
          .eq('id', reportId);

      return true;
    } catch (e) {
      print('Error deleting report: $e');
      return false;
    }
  }

  /// Check if user has admin privileges
  static Future<bool> hasAdminPrivileges(String userId) async {
    try {
      final response = await _client
          .from('user_roles')
          .select('role')
          .eq('user_id', userId)
          .eq('role', 'admin')
          .single();

      return response != null;
    } catch (e) {
      // If no admin role found or other error, return false
      return false;
    }
  }

  /// Get user report history
  static Future<List<QuestionReport>> getUserReportHistory(String userId) async {
    try {
      final response = await _client
          .from('question_reports')
          .select()
          .eq('reporter_user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => QuestionReport.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting user report history: $e');
      return [];
    }
  }
}