import 'package:equatable/equatable.dart';

class PointAdjustment extends Equatable {
  final String id;
  final String sessionId;
  final String questionId;
  final int originalPoints;
  final int adjustedPoints;
  final String reason;
  final DateTime adjustedAt;
  final String adjustedBy;

  const PointAdjustment({
    required this.id,
    required this.sessionId,
    required this.questionId,
    required this.originalPoints,
    required this.adjustedPoints,
    required this.reason,
    required this.adjustedAt,
    required this.adjustedBy,
  });

  int get pointDifference => adjustedPoints - originalPoints;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'question_id': questionId,
      'original_points': originalPoints,
      'adjusted_points': adjustedPoints,
      'reason': reason,
      'adjusted_at': adjustedAt.toIso8601String(),
      'adjusted_by': adjustedBy,
    };
  }

  factory PointAdjustment.fromJson(Map<String, dynamic> json) {
    return PointAdjustment(
      id: json['id'] ?? '',
      sessionId: json['session_id'] ?? '',
      questionId: json['question_id'] ?? '',
      originalPoints: json['original_points'] ?? 0,
      adjustedPoints: json['adjusted_points'] ?? 0,
      reason: json['reason'] ?? '',
      adjustedAt: DateTime.parse(json['adjusted_at'] ?? DateTime.now().toIso8601String()),
      adjustedBy: json['adjusted_by'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        questionId,
        originalPoints,
        adjustedPoints,
        reason,
        adjustedAt,
        adjustedBy,
      ];
}