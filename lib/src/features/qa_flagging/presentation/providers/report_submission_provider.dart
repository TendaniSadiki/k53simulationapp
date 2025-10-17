import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/question_report_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/models/question_report.dart';

final reportSubmissionProvider = StateNotifierProvider<ReportSubmissionProvider, ReportSubmissionState>((ref) {
  return ReportSubmissionProvider();
});

class ReportSubmissionState {
  final List<QuestionReport> submittedReports;
  final List<QuestionReport> pendingReports;
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final Map<String, int> reportCounts;
  final Map<String, int> categoryStats;

  ReportSubmissionState({
    this.submittedReports = const [],
    this.pendingReports = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.reportCounts = const {},
    this.categoryStats = const {},
  });

  ReportSubmissionState copyWith({
    List<QuestionReport>? submittedReports,
    List<QuestionReport>? pendingReports,
    bool? isLoading,
    String? error,
    String? successMessage,
    Map<String, int>? reportCounts,
    Map<String, int>? categoryStats,
  }) {
    return ReportSubmissionState(
      submittedReports: submittedReports ?? this.submittedReports,
      pendingReports: pendingReports ?? this.pendingReports,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
      reportCounts: reportCounts ?? this.reportCounts,
      categoryStats: categoryStats ?? this.categoryStats,
    );
  }

  int get totalSubmittedReports => submittedReports.length;
  int get totalPendingReports => pendingReports.length;
  int get totalReports => submittedReports.length + pendingReports.length;
}

class ReportSubmissionProvider extends StateNotifier<ReportSubmissionState> {
  ReportSubmissionProvider() : super(ReportSubmissionState());

  // Load user's submitted reports
  Future<void> loadUserReports(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final reports = await QuestionReportService.getUserReports(userId);
      final pendingReports = reports.where((report) => report.status == ReportStatus.pending).toList();
      final submittedReports = reports.where((report) => report.status != ReportStatus.pending).toList();

      final reportCounts = _calculateReportCounts(reports);
      final categoryStats = _calculateCategoryStats(reports);

      state = state.copyWith(
        submittedReports: submittedReports,
        pendingReports: pendingReports,
        reportCounts: reportCounts,
        categoryStats: categoryStats,
        isLoading: false,
      );

      // Track analytics
      await AnalyticsService.trackEvent(
        eventType: 'reports_loaded',
        metadata: {
          'total_reports': reports.length,
          'pending_reports': pendingReports.length,
          'submitted_reports': submittedReports.length,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load reports: $e',
      );
    }
  }

  // Submit a new question report
  Future<void> submitReport({
    required String questionId,
    required ReportReason reportType,
    required String description,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null, successMessage: null);

      final report = await QuestionReportService.submitReport(
        questionId: questionId,
        reportType: reportType,
        description: description,
        userId: userId,
        metadata: metadata,
      );

      // Add to local state
      final newPendingReports = List<QuestionReport>.from(state.pendingReports);
      newPendingReports.add(report);

      // Update report counts
      final newReportCounts = Map<String, int>.from(state.reportCounts);
      newReportCounts[reportType.toString()] = (newReportCounts[reportType.toString()] ?? 0) + 1;

      final newCategoryStats = Map<String, int>.from(state.categoryStats);
      final question = await DatabaseService.getQuestionById(questionId);
      if (question != null) {
        final category = question['category'] as String? ?? 'unknown';
        newCategoryStats[category] = (newCategoryStats[category] ?? 0) + 1;
      }

      state = state.copyWith(
        pendingReports: newPendingReports,
        reportCounts: newReportCounts,
        categoryStats: newCategoryStats,
        isLoading: false,
        successMessage: 'Report submitted successfully',
      );

      // Track analytics
      await AnalyticsService.trackEvent(
        eventType: 'report_submitted',
        metadata: {
          'question_id': questionId,
          'report_type': reportType.toString(),
          'description_length': description.length,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to submit report: $e',
      );
    }
  }

  // Update an existing report
  Future<void> updateReport({
    required String reportId,
    String? description,
    ReportReason? reportType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null, successMessage: null);

      await QuestionReportService.updateReport(
        reportId: reportId,
        description: description,
        reportType: reportType,
        metadata: metadata,
      );

      // Update local state
      final updatedPendingReports = state.pendingReports.map((report) {
        if (report.id == reportId) {
          return report.copyWith(
            description: description ?? report.description,
            reason: reportType ?? report.reason,
            description: description ?? report.description,
          );
        }
        return report;
      }).toList();

      state = state.copyWith(
        pendingReports: updatedPendingReports,
        isLoading: false,
        successMessage: 'Report updated successfully',
      );

      // Track analytics
      await AnalyticsService.trackEvent(
        eventType: 'report_updated',
        metadata: {
          'report_id': reportId,
          'has_description_update': description != null,
          'has_type_update': reportType != null,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update report: $e',
      );
    }
  }

  // Delete a report
  Future<void> deleteReport(String reportId) async {
    try {
      state = state.copyWith(isLoading: true, error: null, successMessage: null);

      await QuestionReportService.deleteReport(reportId);

      // Remove from local state
      final newPendingReports = state.pendingReports.where((report) => report.id != reportId).toList();
      final newSubmittedReports = state.submittedReports.where((report) => report.id != reportId).toList();

      state = state.copyWith(
        pendingReports: newPendingReports,
        submittedReports: newSubmittedReports,
        isLoading: false,
        successMessage: 'Report deleted successfully',
      );

      // Track analytics
      await AnalyticsService.trackEvent(
        eventType: 'report_deleted',
        metadata: {
          'report_id': reportId,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete report: $e',
      );
    }
  }

  // Get report by ID
  QuestionReport? getReportById(String reportId) {
    try {
      final pendingReport = state.pendingReports.firstWhere((report) => report.id == reportId);
      return pendingReport;
    } catch (e) {
      try {
        final submittedReport = state.submittedReports.firstWhere((report) => report.id == reportId);
        return submittedReport;
      } catch (e) {
        return null;
      }
    }
  }

  // Get reports by question ID
  List<QuestionReport> getReportsByQuestionId(String questionId) {
    final pendingReports = state.pendingReports.where((report) => report.questionId == questionId).toList();
    final submittedReports = state.submittedReports.where((report) => report.questionId == questionId).toList();
    return [...pendingReports, ...submittedReports];
  }

  // Get reports by type
  List<QuestionReport> getReportsByType(ReportReason reportType) {
    final pendingReports = state.pendingReports.where((report) => report.reason == reportType).toList();
    final submittedReports = state.submittedReports.where((report) => report.reason == reportType).toList();
    return [...pendingReports, ...submittedReports];
  }

  // Search reports
  List<QuestionReport> searchReports(String query) {
    if (query.isEmpty) {
      return [...state.pendingReports, ...state.submittedReports];
    }

    final lowerQuery = query.toLowerCase();
    final allReports = [...state.pendingReports, ...state.submittedReports];

    return allReports.where((report) {
      return (report.description?.toLowerCase() ?? '').contains(lowerQuery) ||
             report.reason.toString().toLowerCase().contains(lowerQuery) ||
             report.questionId.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Clear success message
  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Get report statistics
  Map<String, dynamic> getReportStats() {
    final totalReports = state.totalReports;
    final pendingReports = state.totalPendingReports;
    final submittedReports = state.totalSubmittedReports;

    final mostCommonType = state.reportCounts.entries.isNotEmpty
        ? state.reportCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'none';

    final mostCommonCategory = state.categoryStats.entries.isNotEmpty
        ? state.categoryStats.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'none';

    return {
      'total_reports': totalReports,
      'pending_reports': pendingReports,
      'submitted_reports': submittedReports,
      'most_common_type': mostCommonType,
      'most_common_category': mostCommonCategory,
      'report_type_distribution': state.reportCounts,
      'category_distribution': state.categoryStats,
    };
  }

  // Validate report description
  bool isValidDescription(String description) {
    if (description.isEmpty) return false;
    if (description.length < 10) return false;
    if (description.length > 1000) return false;
    return true;
  }

  // Get report type display name
  String getReportTypeDisplayName(ReportReason reportType) {
    switch (reportType) {
      case ReportReason.incorrectAnswer:
        return 'Incorrect Answer';
      case ReportReason.confusingQuestion:
        return 'Confusing Question';
      case ReportReason.incorrectExplanation:
        return 'Incorrect Explanation';
      case ReportReason.duplicateQuestion:
        return 'Duplicate Question';
      case ReportReason.offensiveContent:
        return 'Offensive Content';
      case ReportReason.technicalIssue:
        return 'Technical Issue';
      case ReportReason.other:
        return 'Other';
    }
  }

  // Get report status display name
  String getReportStatusDisplayName(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }

  // Get report status color
  String getReportStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'orange';
      case ReportStatus.underReview:
        return 'blue';
      case ReportStatus.resolved:
        return 'green';
      case ReportStatus.rejected:
        return 'red';
    }
  }

  // Helper methods
  Map<String, int> _calculateReportCounts(List<QuestionReport> reports) {
    final counts = <String, int>{};
    
    for (final report in reports) {
      final typeKey = report.reportType.toString();
      counts[typeKey] = (counts[typeKey] ?? 0) + 1;
    }
    
    return counts;
  }

  Map<String, int> _calculateCategoryStats(List<QuestionReport> reports) {
    final stats = <String, int>{};
    
    for (final report in reports) {
      // This would need to fetch the question category from the database
      // For now, we'll use a placeholder
      final category = 'unknown';
      stats[category] = (stats[category] ?? 0) + 1;
    }
    
    return stats;
  }

  // Check if user has reported a question
  bool hasUserReportedQuestion(String userId, String questionId) {
    final userReports = [...state.pendingReports, ...state.submittedReports]
        .where((report) => report.userId == userId && report.questionId == questionId)
        .toList();
    
    return userReports.isNotEmpty;
  }

  // Get user's report for a specific question
  QuestionReport? getUserReportForQuestion(String userId, String questionId) {
    try {
      return [...state.pendingReports, ...state.submittedReports]
          .firstWhere((report) => report.userId == userId && report.questionId == questionId);
    } catch (e) {
      return null;
    }
  }

  // Get recent reports (last 7 days)
  List<QuestionReport> getRecentReports() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final allReports = [...state.pendingReports, ...state.submittedReports];
    
    return allReports.where((report) => report.createdAt.isAfter(weekAgo)).toList();
  }

  // Get reports requiring attention (pending for more than 3 days)
  List<QuestionReport> getReportsRequiringAttention() {
    const threeDaysAgo = Duration(days: 3);
    final cutoffDate = DateTime.now().subtract(threeDaysAgo);
    
    return state.pendingReports.where((report) => report.createdAt.isBefore(cutoffDate)).toList();
  }
}