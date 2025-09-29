import 'package:k53app/src/core/services/session_database_service.dart';
import 'package:k53app/src/core/models/session.dart';

class PointAdjustmentService {
  static final PointAdjustmentService _instance = PointAdjustmentService._internal();
  factory PointAdjustmentService() => _instance;
  PointAdjustmentService._internal();

  // Track when a user answers a question
  Future<void> recordQuestionAnswer({
    required String sessionId,
    required String questionId,
    required int chosenIndex,
    required bool isCorrect,
    required int elapsedMs,
    int hintsUsed = 0,
  }) async {
    // Award 1 point for correct answers
    final pointsAwarded = isCorrect ? 1 : 0;
    
    await SessionDatabaseService.recordAnswer(
      sessionId: sessionId,
      questionId: questionId,
      chosenIndex: chosenIndex,
      isCorrect: isCorrect,
      elapsedMs: elapsedMs,
      hintsUsed: hintsUsed,
      pointsAwarded: pointsAwarded,
      isPointAdjusted: false,
      pointHistory: pointsAwarded > 0 
          ? [PointAdjustment(
              points: pointsAwarded,
              reason: 'Correct answer',
              adjustedAt: DateTime.now(),
            )]
          : [],
    );
  }

  // Handle navigation back to previous question
  Future<void> handleNavigationBack({
    required String sessionId,
    required String questionId,
  }) async {
    // Get current answer to check if points were awarded
    final answers = await SessionDatabaseService.getSessionAnswers(sessionId);
    final targetAnswer = answers.firstWhere(
      (answer) => answer.questionId == questionId,
      orElse: () => SessionAnswer(
        sessionId: sessionId,
        questionId: questionId,
        chosenIndex: -1,
        isCorrect: false,
        elapsedMs: 0,
        answeredAt: DateTime.now(),
        pointsAwarded: 0,
      ),
    );

    // Only deduct points if points were previously awarded
    if (targetAnswer.pointsAwarded > 0) {
      await SessionDatabaseService.adjustPoints(
        sessionId: sessionId,
        questionId: questionId,
        pointsChange: -1,
        reason: 'Navigation back to previous question',
      );
    }
  }

  // Get total points for a session
  Future<int> getSessionTotalPoints(String sessionId) async {
    return await SessionDatabaseService.getSessionTotalPoints(sessionId);
  }

  // Get point history for a specific question
  Future<List<PointAdjustment>> getQuestionPointHistory({
    required String sessionId,
    required String questionId,
  }) async {
    final answers = await SessionDatabaseService.getSessionAnswers(sessionId);
    final targetAnswer = answers.firstWhere(
      (answer) => answer.questionId == questionId,
      orElse: () => SessionAnswer(
        sessionId: sessionId,
        questionId: questionId,
        chosenIndex: -1,
        isCorrect: false,
        elapsedMs: 0,
        answeredAt: DateTime.now(),
        pointsAwarded: 0,
      ),
    );

    return targetAnswer.pointHistory;
  }

  // Check if a question has had points adjusted
  Future<bool> hasPointsBeenAdjusted({
    required String sessionId,
    required String questionId,
  }) async {
    final answers = await SessionDatabaseService.getSessionAnswers(sessionId);
    final targetAnswer = answers.firstWhere(
      (answer) => answer.questionId == questionId,
      orElse: () => SessionAnswer(
        sessionId: sessionId,
        questionId: questionId,
        chosenIndex: -1,
        isCorrect: false,
        elapsedMs: 0,
        answeredAt: DateTime.now(),
        pointsAwarded: 0,
        isPointAdjusted: false,
      ),
    );

    return targetAnswer.isPointAdjusted;
  }

  // Get detailed session point summary
  Future<Map<String, dynamic>> getSessionPointSummary(String sessionId) async {
    final answers = await SessionDatabaseService.getSessionAnswers(sessionId);
    final totalPoints = await getSessionTotalPoints(sessionId);
    
    final questionsWithPoints = answers.where((answer) => answer.pointsAwarded > 0).length;
    final adjustedQuestions = answers.where((answer) => answer.isPointAdjusted).length;
    
    return {
      'totalPoints': totalPoints,
      'totalQuestions': answers.length,
      'questionsWithPoints': questionsWithPoints,
      'adjustedQuestions': adjustedQuestions,
      'answers': answers.map((answer) => {
        'questionId': answer.questionId,
        'pointsAwarded': answer.pointsAwarded,
        'isPointAdjusted': answer.isPointAdjusted,
        'pointHistory': answer.pointHistory.map((adj) => adj.toJson()).toList(),
      }).toList(),
    };
  }
}