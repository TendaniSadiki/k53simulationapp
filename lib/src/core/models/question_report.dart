enum ReportStatus {
  pending,
  underReview,
  resolved,
  rejected,
}

enum ReportReason {
  incorrectAnswer('Incorrect Answer'),
  confusingQuestion('Confusing Question'),
  incorrectExplanation('Incorrect Explanation'),
  duplicateQuestion('Duplicate Question'),
  offensiveContent('Offensive Content'),
  technicalIssue('Technical Issue'),
  other('Other');

  const ReportReason(this.value);
  final String value;

  String get displayText => value;

  static List<ReportReason> get selectableReasons => values;
}

class QuestionReport {
  final String id;
  final String questionId;
  final String userId;
  final ReportReason reason;
  final String? description;
  final ReportStatus status;
  final String? adminNotes;
  final DateTime reportedAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  QuestionReport({
    required this.id,
    required this.questionId,
    required this.userId,
    required this.reason,
    this.description,
    required this.status,
    this.adminNotes,
    required this.reportedAt,
    this.resolvedAt,
    this.resolvedBy,
  });

  factory QuestionReport.fromJson(Map<String, dynamic> json) {
    return QuestionReport(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      userId: json['user_id'] as String,
      reason: ReportReason.values.firstWhere(
        (e) => e.toString().split('.').last == json['reason'],
        orElse: () => ReportReason.other,
      ),
      description: json['description'],
      status: ReportStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      adminNotes: json['admin_notes'],
      reportedAt: DateTime.parse(json['reported_at'] as String),
      resolvedAt: json['resolved_at'] != null 
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      resolvedBy: json['resolved_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'user_id': userId,
      'reason': reason.toString().split('.').last,
      'description': description,
      'status': status.toString().split('.').last,
      'admin_notes': adminNotes,
      'reported_at': reportedAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'resolved_by': resolvedBy,
    };
  }

  QuestionReport copyWith({
    String? id,
    String? questionId,
    String? userId,
    ReportReason? reason,
    String? description,
    ReportStatus? status,
    String? adminNotes,
    DateTime? reportedAt,
    DateTime? resolvedAt,
    String? resolvedBy,
  }) {
    return QuestionReport(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      userId: userId ?? this.userId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      reportedAt: reportedAt ?? this.reportedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
    );
  }

  String get reasonDescription {
    switch (reason) {
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

  String get statusDescription {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending Review';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isResolved => status == ReportStatus.resolved || status == ReportStatus.rejected;
  bool get isPending => status == ReportStatus.pending;
  bool get isUnderReview => status == ReportStatus.underReview;
}